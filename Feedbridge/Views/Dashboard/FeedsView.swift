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

    var body: some View {
        NavigationStack {
            FeedChart(entries: entries, isMini: false)
                .frame(height: 300)
                .padding()
            feedEntriesList
        }
        .navigationTitle("Feeds")
    }

    /// Creates the list of feed entries, displaying their type and volume/time.
    private var feedEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                if entry.feedType == .bottle, let volume = entry.feedVolumeInML {
                    // Displays bottle feeding information based on milk type
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
                    // Displays breastfeeding time
                    Text("Breastfeeding: \(time) min")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                // Displays the formatted feed entry date
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .swipeActions {
                        Button(role: .destructive) { Task {
                            print("Delete feed entry with id: \(entry.id ?? "")")
                        print("Baby: \(babyId)")
                            try await standard.deleteFeedEntry(babyId: babyId, entryId: entry.id ?? "")
                            self.entries.removeAll { $0.id == entry.id }
                        } } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
