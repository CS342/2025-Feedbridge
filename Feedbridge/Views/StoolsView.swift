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
        NavigationView {
            VStack {
                StoolChart(entries: entries, isMini: false)
                    .chartYScale(domain: [0, 3]) // Set the Y-axis scale range from 0 to 3
                    .frame(height: 300)
                    .padding()
                stoolEntriesList
            }
            .navigationTitle("Stools")
        }
    }

    private var stoolEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                Text(entry.dateTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
