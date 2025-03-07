//
//  StoolsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI
struct StoolsView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [StoolEntry]

    var body: some View {
        NavigationStack {
                StoolChart(entries: entries, isMini: false)
                .frame(height: 300)
                .padding()
            stoolEntriesList
        }
        .navigationTitle("Stools")
    }

    private var stoolEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
