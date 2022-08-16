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
    @State private var authState: AuthState = .idle
    
    struct Background: View {
        struct BackgroundView: UIViewControllerRepresentable {
            func makeUIViewController(context: Context) -> UIViewController {
                let sb = UIStoryboard(name: "Launch Screen", bundle: nil)
                return sb.instantiateInitialViewController() ?? UIViewController()
            }
            func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
            
            typealias UIViewControllerType = UIViewController
        }
        
        var body: some View {
            BackgroundView().edgesIgnoringSafeArea([.top, .bottom, .leading, .trailing])
        }
    }
    
    var body: some View {
        ZStack {
            Background()
            decider
        }
    }
    
    @ViewBuilder
    var decider: some View {
        if case .loggedIn(let courses) = authState {
            CollectionsLoader(courseIds: courses) { Task { /*logout method*/
                authState = .loggingOut
                await Authenticator.logout()
                authState = .noAccessToken
            }}
        } else if case .noAccessToken = authState {
            StartPage { result in
                UserDefaults.standard.set(result.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(result.sessionToken, forKey: "sessionToken")
                authState = .invalidSession(refreshSessionRequest: Authenticator.buildSakaiAccessRequest(accessToken: result.accessToken))
            }
        } else if case .loggingOut = authState {
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
        } else { ZStack {
            if case .invalidSession(let request) = authState {
                CookieMonster(request: request) { courses in
                    guard let courses = courses else {
                        //TODO: handle flow, its likely this user has a netId but doesn't use Sakai
                        print("This user doens't use Sakai?")
                        Task {
                            await Authenticator.logout()
                            authState = .noAccessToken
                        }
                        return
                    }
                    print("Session is now valid after authenticated in WKWebView, logging in")
                    authState = .loggedIn(courses: courses)
                }
            }
            
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .onAppear { Task {
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
                }}
        }}
    }
}

struct AuthDecider_Previews: PreviewProvider {
    static var previews: some View {
        AuthDecider()
    }
}
