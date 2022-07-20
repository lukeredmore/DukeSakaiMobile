//
//  LoginView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct LoginView: View {
    @State private var showingLoginVC = true
    @Binding var courses: [Course]
    var body: some View {
        Button("Login") {
            showingLoginVC = true
        }.sheet(isPresented: $showingLoginVC) {
            LoginVCWrapper(courses: $courses)
        }
        .onChange(of: courses) { cr in
            if cr.isEmpty {
                print("No courses found, with I could throw")
            } else {
                showingLoginVC = false
            }

        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
