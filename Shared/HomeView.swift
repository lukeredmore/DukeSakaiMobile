//
//  HomeView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/18/22.
//

import SwiftUI

struct HomeView: View {
    @Binding var courses: [Course]
    @State private var showHamburgerMenu = true
    @State private var selectedCourse: Course? = nil
    
    init(courses: Binding<[Course]>) {
        _courses = Binding(projectedValue: courses)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    @ViewBuilder
    var home : some View {
        if let course = selectedCourse {
            HomeTabView(showMenu: $showHamburgerMenu, course: course)
        } else {
            ProgressView()
        }
    }
    
    var body: some View {
        let drag = DragGesture()
            .onEnded {
                if $0.translation.width < -100 {
                    withAnimation {
                        self.showHamburgerMenu = false
                    }
                }
            }
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    home
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.showHamburgerMenu ? geometry.size.width/1.5 : 0)
                        .disabled(self.showHamburgerMenu ? true : false)
                    if self.showHamburgerMenu {
                        HamburgerView(courses: courses,
                                      selectedCourse: $selectedCourse,
                                      isOpen: $showHamburgerMenu)
                            .frame(width: geometry.size.width/1.5)
//                            .frame(maxWidth: .infinity)   // 2
                                .background(Color.blue)
                            .transition(.move(edge: .leading))
                    }
                }
                .gesture(drag)
            }.navigationBarTitle(selectedCourse?.name ?? "", displayMode: .inline)
                .navigationBarItems(leading: (
                    Button(action: {
                        withAnimation {
                            self.showHamburgerMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                ))
                .navigationBarHidden(false)
            
        }.navigationBarBackButtonHidden(true)
            .navigationBarTitle("")
            .navigationBarHidden(true)
//            .onChange(of: courses) {crs in
//                selectedCourseId = crs[0].siteId
//
//            }
        
        //        VStack {
        //            ForEach(courses, id: \.name) { course in
        //                Text("\(course.name)")
        //            }
        //
        
        //        }
    }
    
}
struct HomeView_Previews: PreviewProvider {
    
    static let testCourses = [Course(name: "Course 1",
                                     siteId: "abcde",
                                     term: "Spring 2022",
                                     instructor: "Redmore",
                                     lastModified: 122212),
                              Course(name: "Course 2",
                                     siteId: "fghij",
                                     term: "Fall 2022",
                                     instructor: "Bash",
                                     lastModified: 4249234)]
    static var previews: some View {
        HomeView(courses: .constant(testCourses))
    }
}
