//
//  HamburgerView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/19/22.
//

import SwiftUI

struct HamburgerView: View {
    var courses: [Course]
    @Binding var selectedCourse: Course?
    @Binding var isOpen: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                ForEach(courses, id: \.siteId) { course in
                    HStack {
                        Image(systemName: "star\(course == selectedCourse ? ".fill" : "")")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                        Text(course.name)
                            .foregroundColor(.gray)
                            .font(.headline)
                    }.onTapGesture {
                        selectedCourse = course
                        withAnimation {
                            isOpen = false
                        }
                        
                        
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 12)
                    
                }
                Spacer()
            }.frame(maxWidth: .infinity)
        }
//        .safeAreaInset(edge: .top, spacing: 50.0) {
//            Spacer().frame(height: 0.0)
//        }
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        
//            .edgesIgnoringSafeArea(.all)
//            .listRowInsets(EdgeInsets(top: 50.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
    }
}

//struct HamburgerView_Previews: PreviewProvider {
//    static var previews: some View {
////        HamburgerView(courses: HomeView_Previews.testCourses, selectedCourse: .constant(), isOpen: .constant(true))
//    }
//}
