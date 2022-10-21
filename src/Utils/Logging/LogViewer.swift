//
//  LogViewer.swift
//  DukeSakai
//
//  Created by Luke Redmore on 10/21/22.
//

import CoreData
import SwiftUI

struct LogViewer: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.date, order: .reverse)
    ]) var logEntries: FetchedResults<LogEntry>
    @Environment(\.presentationMode) private var presentationMode
    @State private var confirmDelete = false
    
    let fmt = DateFormatter()
    
    var body: some View {
        NavigationView {
            List(logEntries) { entry in
                VStack(alignment: .leading) {
                    HStack {
                        Text(entry.source ?? "")
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.subheadline)
                        Spacer()
                        Text(fmt.string(from: entry.date ?? Date(timeIntervalSince1970: 0)))
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.subheadline)
                    }
                    Text(entry.msg ?? "NO MSG"
                        .replacingOccurrences(of: "\n", with: "")
                        .replacingOccurrences(of: "<[^>]+>" , with: " ", options: .regularExpression, range: nil)
                        .replacingOccurrences(of: "  ", with: " ")
                    )
                }
            }
            .listStyle(.plain)
            .onAppear {
                fmt.dateFormat = "d MMM yyyy HH:mm:ss.SSS"
            }
            .navigationBarTitle("Logs", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        confirmDelete = true
                    } label: {
                        Image(systemName: "trash")
                            .tint(Color.red)
                    }
                    
                }
            }
        }.confirmationDialog("Are you sure you want to delete all logs?", isPresented: $confirmDelete, titleVisibility: .visible) {
            SwiftUI.Button("Delete", role: .destructive) {
                CoreDataManager.shared.clearLogs()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
