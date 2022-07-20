//
//  LoginVCWrapper.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct LoginVCWrapper: UIViewControllerRepresentable {
    @Binding var courses: [Course]
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> LoginViewController {
        return LoginViewController(delegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
        print("update")
    }
    
    typealias UIViewControllerType = LoginViewController
 
    
    class Coordinator: NSObject, LoginViewControllerDelegate {
        func sakaiAuthenticatedWithCourses(_ courses: [Course]) {
            parent.courses = courses
        }
        
        
        var parent: LoginVCWrapper

                init(_ parent: LoginVCWrapper) {
                    self.parent = parent
                }
    }
    
}

//struct LoginVCWrapper_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginVCWrapper()
//    }
//}
