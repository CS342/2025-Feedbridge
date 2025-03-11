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

    /// The full weight chart with points for individual entries and a line for averaged weights.
    private var fullWeightChart: some View {
        Chart {
            let averagedEntries = averageWeightsPerDay()

            // Plot individual weight entries
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                let day = Calendar.current.startOfDay(for: entry.dateTime)
                PointMark(
                    x: .value("Date", day),
                    y: .value(
                        weightUnitPreference == .kilograms ? "Weight (kg)" : "Weight (lb)",
                        weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value
                    )
                )
                .foregroundStyle(.gray)
                .symbol {
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 8)
                }
            }

            // Plot averaged weight data
            ForEach(averagedEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value(
                        weightUnitPreference == .kilograms ? "Weight (kg)" : "Weight (lb)", entry.averageWeight
                    )
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.indigo)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .frame(height: 300)
        .padding()
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

    /// Averages the weights per day
    private func averageWeightsPerDay() -> [DailyAverageWeight] {
        let grouped = Dictionary(grouping: currentEntries) { entry in
            Calendar.current.startOfDay(for: entry.dateTime)
        }

        var dailyAverages: [DailyAverageWeight] = []

        // Calculate average weight per day
        for (date, entries) in grouped {
            let totalWeight = entries.reduce(0) { result, entry in
                result
                    + (weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value)
            }
            let averageWeight = totalWeight / Double(entries.count)
            dailyAverages.append(DailyAverageWeight(date: date, averageWeight: averageWeight))
        }

        return dailyAverages.sorted { $0.date < $1.date }
    }
}
