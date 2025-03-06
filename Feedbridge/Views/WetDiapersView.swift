//
//  WetDiapersView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI
struct WetDiapersView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [WetDiaperEntry]

    var body: some View {
        NavigationView {
            VStack {
                WetDiaperChart(entries: entries, isMini: false)
                    .chartYScale(domain: [0, 3])
                    .frame(height: 300)
                    .padding()
                wetDiaperEntriesList
            }
            .navigationTitle("Wet Diapers")
        }
    }

    // List of Wet Diaper Entries
    private var wetDiaperEntriesList: some View {
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
