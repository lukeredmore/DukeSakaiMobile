//
//  AuthContentView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/20/22.
//

import SwiftUI

struct AuthDecider: View {
    @State private var authState = AuthState.idle
    
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
    
    private func authenticate() { Task {
        let scene = await UIApplication.shared.connectedScenes.first as! UIWindowScene
        do {
            let courses = try await Authenticator.restoreSession(scene: scene)
            authState = .loggedIn(courses: courses)
        } catch {
            print(error)
            switch error {
            case AuthenticationError.noAccessToken,
                AuthenticationError.couldNotRefreshAccessToken:
                authState = .newUser
            case AuthenticationError.unknown:
                print("Unknown auth error")
            default:
                print("Unknown error")
            }
        }
    }}
    
    @ViewBuilder
    var decider: some View {
        switch authState {
        case .idle, .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .onAppear {
                    if case .idle = authState {
                        authenticate()
                    }
                }
        case .newUser:
            StartPage { result in
                authState = .loading
                UserDefaults.shared.set(result.accessToken, forKey: "accessToken")
                UserDefaults.shared.set(result.sessionToken, forKey: "sessionToken")
                authenticate()
            }
        case .loggedIn(let courses):
            CollectionsLoader(courseIds: courses) { Task { /*logout method*/
                authState = .loading
                await Authenticator.logout()
                authState = .newUser
            }}
        }
    }
}

struct AuthDecider_Previews: PreviewProvider {
    static var previews: some View {
        AuthDecider()
    }
}
