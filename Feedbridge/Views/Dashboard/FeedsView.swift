//
//  FeedsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

/// View displaying detailed feed chart and a list of feed entries.
struct FeedsView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [FeedEntry]
    let babyId: String

    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?

    // Use the latest data from viewModel if available
    private var currentEntries: [FeedEntry] {
        if let baby = viewModel?.baby {
            return baby.feedEntries.feedEntries
        }
        return entries
    }

    var body: some View {
        NavigationStack {
            FeedChart(entries: currentEntries, isMini: false)
                .frame(height: 300)
                .padding()
            feedEntriesList
        }
        .navigationTitle("Feeds")
    }

    /// List of feed entries sorted by date, displaying feed type and volume/time.
    private var feedEntriesList: some View {
        List(currentEntries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                feedEntryView(entry: entry)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                try await standard.deleteFeedEntry(babyId: babyId, entryId: entry.id ?? "")
                                self.entries.removeAll { $0.id == entry.id }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }

    /// Generates the appropriate feed entry view based on feed type.
    @ViewBuilder
    private func feedEntryView(entry: FeedEntry) -> some View {
        if entry.feedType == .bottle, let volume = entry.feedVolumeInML {
            Text("Bottle (\(entry.milkType == .breastmilk ? "Breastmilk" : "Formula"))")
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(volume) ml")
                .font(.subheadline)
        } else if entry.feedType == .directBreastfeeding, let time = entry.feedTimeInMinutes {
            Text("Breastfeeding")
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(time) min")
                .font(.subheadline)
        }
    }
}
