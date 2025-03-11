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

    var body: some View {
        NavigationStack {
            StoolChart(entries: entries, isMini: false)
                .frame(height: 300)
                .padding()
            stoolEntriesList
        }
        .navigationTitle("Stools")
    }

    /// List of stool entries sorted by date, showing volume, color, and time.
    private var stoolEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .swipeActions {
                        Button(role: .destructive) { Task {
                            print("Delete stool entry with id: \(entry.id ?? "")")
                        print("Baby: \(babyId)")
                            try await standard.deleteStoolEntry(babyId: babyId, entryId: entry.id ?? "")
                            self.entries.removeAll { $0.id == entry.id }
                        } } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}
