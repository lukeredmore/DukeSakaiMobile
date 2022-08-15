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
    
    static func create(withCourse course: Course) -> SakaiEnvironment {
        let env = SakaiEnvironment()
        env.selectedCollection = CourseCollection(collectionName: course.name, courses: [course])
        return env
    }
    
    func toggleCourseInFavorites(_ course: Course) {
        print("Toggling \(course.name) in favorites")
        var favoriteIds : [String] = UserDefaults.standard.array(forKey: "favorite-course-ids") as? [String] ?? []
        
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
        UserDefaults.standard.set(favoriteIds, forKey: "favorite-course-ids")
    }
    
    func createInitialEnv(courseIds: [String]) async {
        do {
            print("Creating Environment")
            let courses = await CoursesRetriever().initialCourses(courseIds: courseIds) //try await CoursesRetriever.getCourses(for: courseIds)
            let group = CoursesRetriever.groupCourses(courses: courses)
            DispatchQueue.main.async {
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
    
    
    class CoursesRetriever: NSObject, LoginViewControllerDelegate {
        lazy var loginVc = LoginViewController(delegate: self)
        
        var continuation: CheckedContinuation<[Course], Never>? = nil
        
        func sakaiAuthenticatedWithCourses(_ courses: [Course]) {
            if (courses.count == sites.count) {
                print("Got all course objects, returning to set up collections and show home screen")
                self.continuation?.resume(returning: courses)
                self.continuation = nil
            }
        }
        

        // This is a very poorly engineered attempt to hack existing fucntionality because my rewrite isn't working (Invalid data, then cancelling the rest)
        func initialCourses(courseIds: [String]) async -> [Course] {
            return await withCheckedContinuation { continuation in
                self.continuation = continuation
                DispatchQueue.main.async {
                    sites = courseIds
                    self.loginVc.initialCourses()
                }
            }
        }
        

        static func getCourses(for siteIds: [String]) async throws -> [Course] {
            print("Loading courses for all siteIds")
            
            let courses = try await withThrowingTaskGroup(of: Course.self) { taskGroup -> [Course] in
                for siteId in siteIds {
                    taskGroup.addTask {
                        return try await getCourse(for: siteId)
                    }
                }
                
                var allCourses = [Course]()
                for try await course in taskGroup {
                    allCourses.append(course)
                }
                return allCourses
            }
            
            print("Loaded \(courses.count) courses belong to the user")
            return courses
        }
        
        private static func getCourse(for siteId: String) async throws -> Course {
            do {
                
                
                let url = try Networking.createSakaiURL(siteId: siteId,
                                                        endpoint: "site",
                                                        options: ["n": "200", "d": "3000"],
                                                        siteSpecific: false)
                print("Getting course from url: \(url.absoluteString)")
                let json = try await Networking.json(from: url)
                //            print(json)
                return Course(name: try json.get("title"),
                              siteId: siteId,
                              term: try json.get("type") != "project" ? json.get(["props", "term"]) : "project",
                              instructor: try json.get(["siteOwner", "userDisplayName"]),
                              lastModified: try json.get("lastModified"),
                              created: try json.get("createdDate"))
            } catch {
                print("Error in getting course \(siteId): \(error)")
                throw error
            }
        }
        
        static func groupCourses(courses: [Course]) -> (termCollections: [CourseCollection], favoritesCollection: CourseCollection) {
            print("Aggregating courses into collections")
            let termCollections = organizeCoursesByTerm(courses: courses)
            
            let favorites = UserDefaults.standard.array(forKey: "favorite-course-ids") as? [String] ?? []
            let favoriteCourses = courses.filter { course in
                favorites.contains(course.siteId)
            }
            let favoritesCollection = CourseCollection(collectionName: "Favorites", courses: favoriteCourses)
            
            return (termCollections, favoritesCollection)
        }
        
        private static func organizeCoursesByTerm(courses: [Course]) -> [CourseCollection] {
            var coursesByTerm = [String : [Course]]()
            for course in courses {
                coursesByTerm[course.term, default: []].append(course)
            }
            
            var collectionsToReturn = [CourseCollection]()
            for (term, courses) in coursesByTerm {
                if term == "Project" { continue }
                collectionsToReturn.append(CourseCollection(collectionName: term, courses: courses))
            }
            collectionsToReturn = collectionsToReturn.sorted { a, b in
                a.courses[0].created > b.courses[0].created
            }
            if let project = coursesByTerm["Project"] {
                collectionsToReturn.append(CourseCollection(collectionName: "Projects", courses: project))
            }
            return collectionsToReturn
        }
    }
}


