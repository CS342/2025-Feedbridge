//
//  WeightsView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 3/3/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

/// Represents a day's average weight.
struct DailyAverageWeight: Identifiable {
    let id = UUID()
    let date: Date
    let averageWeight: Double
}

/// Displays the detailed weight entries and charts for a user.
struct WeightsView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [WeightEntry]

    let babyId: String

    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?

    @AppStorage(UserDefaults.weightUnitPreference) var weightUnitPreference: WeightUnit = .kilograms

    // Use the latest data from viewModel if available
    private var currentEntries: [WeightEntry] {
        if let baby = viewModel?.baby {
            return baby.weightEntries.weightEntries
        }
        return entries
    }

    var body: some View {
        NavigationStack {
            WeightChart(
                entries: currentEntries, isMini: false, weightUnitPreference: $weightUnitPreference
            )
            .frame(height: 300)
            .padding()
            weightEntriesList
        }
        .navigationTitle("Weights")
    }

    /// Displays a list of weight entries sorted by most recent.
    private var weightEntriesList: some View {
        List(currentEntries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                // Display the formatted date of the entry
                Text(entry.dateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.gray)

                // Weight entry with correct unit
                Text(
                    "\(weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value, specifier: "%.2f") \(weightUnitPreference == .kilograms ? "kg" : "lb")"
                )
                .font(.headline)
            }.swipeActions {
                Button(role: .destructive) {
                    Task {
                        print("Delete weight entry with id: \(entry.id ?? "")")
                        print("Baby: \(babyId)")
                        try await standard.deleteWeightEntry(babyId: babyId, entryId: entry.id ?? "")
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
