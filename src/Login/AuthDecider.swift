//
//  AuthContentView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI
import AuthenticationServices
import WebKit


struct AuthDecider: View {
    @State private var showingSheet = false
        
//    let SIGN_IN_URL_STRING = "https://oauth.oit.duke.edu/oidc/authorize?response_type=code&client_id=dukesakaimobile&state=your_opaque_state&redirect_uri=dukesakaimobile://callback"
    
    @State private var authState: AuthState = .idle
    
    func logout() {
        print("would log out if i could")
        Task {
            await Authenticator.validateSakaiSession()
        }
        
//        UserDefaults.standard.removeObject(forKey: "accessToken")
//        UserDefaults.standard.removeObject(forKey: "sessionToken")
//        authState = .noAccessToken
    }
    
    
    var body: some View {
        
        if case .loggedIn(let courses) = authState {
            CollectionCoordinatorView(courseIds: courses)
        } else if case .noAccessToken = authState {
            Button("Login") {
                showingSheet = true
            }
            .sheet(isPresented: $showingSheet) {
                AuthWebView() { result in
                    showingSheet = false
                    if let result = result {
                    UserDefaults.standard.set(result.accessToken, forKey: "accessToken")
                    UserDefaults.standard.set(result.sessionToken, forKey: "sessionToken")
                        authState = .invalidSession(refreshSessionRequest: Authenticator.buildSakaiAccessRequest(accessToken: result.accessToken))
                    } else {
                        //TODO: handle auth flow canceled
                    }
                }
                .interactiveDismissDisabled()
            }
        } else {
            ZStack {
                if case .invalidSession(let request) = authState {
                    CookieMonster(request: request) { courses in
                        guard let courses = courses else {
                            //TODO: handle flow, its likely this user has a netId but doesn't use Sakai
                            logout()
                            return
                        }
                        print("Session is now valid after authenticated in WKWebView, logging in")
                        authState = .loggedIn(courses: courses)
                    }
                }
                
                ProgressView()
                    .onAppear {
                        Task {
                            CookieMonster.loadSessionCookiesIntoURLSession()
                            if let courses = await Authenticator.validateSakaiSession() {
                                print("Valid Sakai session loaded, logging in")
                                authState = .loggedIn(courses: courses)
                            } else if let existingAccessToken = UserDefaults.standard.string(forKey: "accessToken"),
                                      let existingSessionToken = UserDefaults.standard.string(forKey: "sessionToken") {
                                print("Restored session is invalid, but we have an access token saved, lets validate it and use that")
                                let tokenValid = Authenticator.validateAccessToken(existingAccessToken)
                                var accessToken = existingAccessToken
                                if !tokenValid {
                                    print("Access token is expired, refreshing it")
                                    do {
                                        accessToken = try await Authenticator.refreshAccessToken(accessToken: existingAccessToken,
                                                                                                sessionToken: existingSessionToken)
                                    } catch {
                                        print("Couldn't refresh access token, logging out: ")
                                        print(error)
                                        authState = .noAccessToken
                                    }
                                }
                                print("Building new session with valid accessToken")
                                let request = Authenticator.buildSakaiAccessRequest(accessToken: accessToken)
                                authState = .invalidSession(refreshSessionRequest: request)
                            } else {
                                print("Looks like a new user")
                                authState = .noAccessToken
                            }
                        }
                    }
            }
        }
    }
}





struct AuthDecider_Previews: PreviewProvider {
    static var previews: some View {
        AuthDecider()
    }
}
