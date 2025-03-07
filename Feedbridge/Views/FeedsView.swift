//
//  feedsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI
struct FeedsView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [FeedEntry]
    
    var body: some View {
        NavigationStack {
                FeedChart(entries: entries, isMini: false)
                .frame(height: 300)
                .padding()
                feedEntriesList
        }
        .navigationTitle("Feeds")
    }

    private var feedEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text(entry.feedType == .bottle ? "Bottle Feed: \(entry.feedVolumeInML ?? 0) ml" : "Breastfeeding: \(entry.feedTimeInMinutes ?? 0) min")
                    .font(.headline)
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
