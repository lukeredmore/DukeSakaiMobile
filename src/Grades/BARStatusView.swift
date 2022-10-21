//
//  BARStatusView.swift
//  ShareExtension
//
//  Created by Luke Redmore on 8/26/22.
//

import SwiftUI

struct BARStatusView: View {
    let defaults = UserDefaults.shared
    let timeArray = UserDefaults.shared.value(forKey: "refresh-times") as? [Double] ?? [Double]()
    
    private func dateString(fromSeconds seconds: Double) -> String {
        let interval = TimeInterval(seconds)
        let date = Date(timeIntervalSince1970: interval)
        return date.ISO8601Format()
    }
    
    var body: some View {
        if timeArray.count == 0 {
            Text("No refresh times found")
        } else {
            List(timeArray, id: \.self) { time in
                HStack {
                    Text(dateString(fromSeconds: time))
                    Spacer()
                    Text(defaults.value(forKey: "refresh-times-\(time)") as? String ?? "Unknown")
                }
            }
        }
    }
}
