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
                if entry.feedType == .bottle, let volume = entry.feedVolumeInML {
                    if entry.milkType == .breastmilk {
                        Text("Bottle (Breastmilk): \(volume) ml")
                            .font(.headline)
                            .foregroundColor(.primary)
                    } else {
                        Text("Bottle (Formula): \(volume) ml")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                } else if entry.feedType == .directBreastfeeding, let time = entry.feedTimeInMinutes {
                    Text("Breastfeeding: \(time) min")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}
