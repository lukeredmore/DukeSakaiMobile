//
//  AnnouncementsNavigationView.swift
//  DukeSakai
//
//  Created by Luke Redmore on 7/22/22.
//

import SwiftUI

struct AnnouncementsNavigationView: View {
    var courseNameFollowsAuthorName: Bool, annoucements: [Announcement]
    @State private var tappedAnnoucement: Announcement? = nil
    
    @ViewBuilder
    static func build(_ item: [Announcement], hasMultipleCourses: Bool) -> some View {
        if item.isEmpty {
            Text("No announcements found")
        } else {
            AnnouncementsNavigationView(courseNameFollowsAuthorName: hasMultipleCourses, annoucements: item)
        }
    }
    
    var body: some View {
        List(annoucements, id: \.title) { item in
            Button {
                tappedAnnoucement = item
            } label: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(item.author)\(courseNameFollowsAuthorName ? " (\(item.courseTitle))" : "")").font(.headline)
                        Spacer()
                        Text(item.timePostedString)
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(UIColor.systemGray3))
                    }
                    Text(item.title)
                        .font(.subheadline)
                    Text(item.body
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "<[^>]+>" , with: " ", options: .regularExpression, range: nil)
                        .replacingOccurrences(of: "  ", with: " ")
                        .substring(from: 1)
                    )
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(Color(UIColor.systemGray))
                    
                }
            }
        }
        .background(NavigationLink(destination: tapDestination,
                                   isActive: Binding(get: { tappedAnnoucement != nil },
                                                     set: { _,_ in tappedAnnoucement = nil })) { EmptyView() })
        .listStyle(PlainListStyle())
    }
    
    @ViewBuilder
    var tapDestination: some View {
        if let tapped = tappedAnnoucement {
            AnnoucementDetailView(text: tapped.body)
                .navigationTitle(tapped.title)
        }
    }
}

//struct AnnouncementsNavigationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnnouncementsNavigationView()
//    }
//}
