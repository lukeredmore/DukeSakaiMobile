//
//  CourseRetriever.swift
//  DukeSakai
//
//  Created by Luke Redmore on 8/14/22.
//

import Foundation

class SakaiEnvironment: ObservableObject {
    @Published var selectedCollection = CourseCollection()
    @Published var termCollections = [CourseCollection]()
    @Published var favoritesCollection = CourseCollection()
    @Published var collectionPickerShown = false
    @Published var logout: () -> Void = {}
    @Published var selectedTab = 3
    
    static func create(withCourse course: Course) -> SakaiEnvironment {
        let env = SakaiEnvironment()
        env.selectedCollection = CourseCollection(collectionName: course.name, courses: [course])
        return env
    }
    
    func toggleCourseInFavorites(_ course: Course) {
        print("Toggling \(course.name) in favorites")
        var favoriteIds : [String] = UserDefaults.shared.array(forKey: "favorite-course-ids") as? [String] ?? []
        
        var favs = favoritesCollection.courses
        if let current = favs.firstIndex(where: { $0 == course }) {
            favs.remove(at: current)
            favoriteIds = favoriteIds.filter { $0 != course.siteId }
            self.favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favs)
        } else {
            favoriteIds.append(course.siteId)
            favs.append(course)
            self.favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favs)
        }
        if self.selectedCollection.collectionName == "Favorites" {
            if favoritesCollection.courses.isEmpty {
                self.selectedCollection = termCollections[0]
            } else {
                self.selectedCollection = favoritesCollection
            }
        }
        UserDefaults.shared.set(favoriteIds, forKey: "favorite-course-ids")
    }
    
    func createInitialEnv(courseIds: [String], logout: @escaping () -> Void) async {
        do {
            print("Creating Environment")
            let courses = try await CoursesRetriever.getCourses(for: courseIds)
            let group = CoursesRetriever.groupCourses(courses: courses)
            DispatchQueue.main.async {
                self.logout = logout
                self.termCollections = group.termCollections
                self.favoritesCollection = group.favoritesCollection
                self.selectedCollection = self.favoritesCollection.courses.isEmpty ? self.termCollections[0] : self.favoritesCollection
            }
            
        } catch {
            print("Error creating env")
            print(error)
            print(error.localizedDescription)
        }
    }
}


