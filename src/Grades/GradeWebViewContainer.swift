//
//  GradeWebViewContainer.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/30/22.
//

import SwiftUI

struct GradeWebViewContainer: View {
    @EnvironmentObject var env : SakaiEnvironment
    
    var course: Course? {
        env.selectedCollection.courses.first
    }
    
    @ViewBuilder
    var decider: some View {
        if let gradebookUrl = course?.gradebookUrl {
            GradeWebView(urlString: gradebookUrl)
        } else {
            Text("The instructor has not set up a gradebook for this course")
                .padding()
                .multilineTextAlignment(.center)
        }
    }
    
    var body: some View {
        CollectionPickerWrapper() {
            decider.onAppear {
                if env.selectedCollection.courses.count <= 1 { return }
                
                let course = env.selectedCollection.courses.first!
                let singleCourseCollection = CourseCollection(collectionName: course.name, courses: [course])
                env.selectedCollection = singleCourseCollection
            }
        }
    }
}

struct GradeWebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        GradeWebViewContainer()
    }
}
