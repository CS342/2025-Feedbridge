//
//  StoolsView.swift
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

/// View displaying stool entries in a list and chart.
struct StoolsView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [StoolEntry]
    let babyId: String

    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?

    // Use the latest data from viewModel if available
    private var currentEntries: [StoolEntry] {
        if let baby = viewModel?.baby {
            return baby.stoolEntries.stoolEntries
        }
        return entries
    }

    var body: some View {
        NavigationStack {
            StoolChart(entries: currentEntries, isMini: false)
                .frame(height: 300)
                .padding()
            stoolEntriesList
        }
        .navigationTitle("Stools")
    }

    /// List of stool entries sorted by date, showing volume, color, and time.
    private var stoolEntriesList: some View {
        List(currentEntries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                print("Delete stool entry with id: \(entry.id ?? "")")
                                print("Baby: \(babyId)")
                                try await standard.deleteStoolEntry(babyId: babyId, entryId: entry.id ?? "")
                                // Remove from local state
                                self.entries.removeAll { $0.id == entry.id }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
