//
//  WetDiaperCharts.swift
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

/// Displays the summary view for wet diaper entries.
struct WetDiapersSummaryView: View {
    let entries: [WetDiaperEntry]
    let babyId: String

    // Optional viewModel for real-time data
    var viewModel: DashboardViewModel?

    private var currentEntries: [WetDiaperEntry] {
        // Use viewModel data if available, otherwise fall back to passed entries
        if let baby = viewModel?.baby {
            return baby.wetDiaperEntries.wetDiaperEntries
        }
        return entries
    }

    private var lastEntry: WetDiaperEntry? {
        currentEntries.max(by: { $0.dateTime < $1.dateTime })
    }

    var body: some View {
        NavigationLink(
            destination: WetDiapersView(entries: currentEntries, babyId: babyId, viewModel: viewModel)
        ) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Creates the main summary card
    private func summaryCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .opacity(0.8)

            VStack {
                header()
                if let entry = lastEntry {
                    Spacer()
                    entryDetails(entry)
                } else {
                    noDataText()
                }
            }
        }
        .frame(height: 120)
    }

    /// Creates the header section with the icon and title
    private func header() -> some View {
        HStack {
            Image(systemName: "drop.fill")
                .accessibilityLabel("Wet Diaper Drop")
                .font(.title3)
                .foregroundColor(.orange)

            Text("Voids")
                .font(.title3.bold())
                .foregroundColor(.orange)

            Spacer()

            Image(systemName: "chevron.right")
                .accessibilityLabel("Next page")
                .foregroundColor(.gray)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
    }

    /// Displays the last recorded wet diaper entry
    private func entryDetails(_ entry: WetDiaperEntry) -> some View {
        HStack {
            Text(wetDiaperText(entry))
                .font(.title3)
                .foregroundColor(.primary)
            Spacer()
            MiniWetDiaperChart(entries: currentEntries)
        }
        .padding([.bottom, .horizontal])
    }

    /// Formats the wet diaper text (volume and color)
    private func wetDiaperText(_ entry: WetDiaperEntry) -> String {
        "\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)"
    }

    /// Displays a placeholder when no data is available
    private func noDataText() -> some View {
        Text("No data added")
            .foregroundColor(.gray)
            .padding()
    }
}

/// Displays a mini chart of wet diaper entries.
struct MiniWetDiaperChart: View {
    let entries: [WetDiaperEntry]

    var body: some View {
        WetDiaperChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}

/// Displays a chart of wet diaper entries, with the ability to show a mini version for summaries.
struct WetDiaperChart: View {
    let entries: [WetDiaperEntry]
    var isMini: Bool

    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)  // Index entries by day
        let lastDay = lastEntryDate(entries)  // Get the last recorded date

        Chart {
            // Loop through each entry and plot it
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime, unit: .day),  // Set the x-axis to the day
                    y: .value("Diaper #", indexedEntry.index)  // Set the y-axis as a sequential index
                )
                .symbolSize(bubbleSize(indexedEntry.entry.volume, isMini))  // Adjust bubble size based on volume and chart type
                .foregroundStyle(miniColor(entry: indexedEntry.entry, isMini: isMini, lastDay: lastDay))  // Set color based on diaper data
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)  // Hide X-axis on mini chart
        .chartYAxis(isMini ? .hidden : .visible)  // Hide Y-axis on mini chart
        .chartXScale(domain: last7DaysRange())  // Set the X-axis range for the last 7 days
        .if(!isMini) { view in
            view.chartYAxisLabel("Void Count")
        }
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)  // Make the chart background transparent
        }
    }

    /// Determines the color of the point based on the entry's color and whether it's a mini chart.
    private func miniColor(entry: WetDiaperEntry, isMini: Bool, lastDay: String) -> Color {
        isMini
            ? (dateString(entry.dateTime) == lastDay ? .orange : Color(.greyChart))
            : diaperColor(entry.color)
    }

    /// Get the last recorded date as a string.
    private func lastEntryDate(_ entries: [WetDiaperEntry]) -> String {
        guard let lastEntry = entries.max(by: { $0.dateTime < $1.dateTime }) else {
            return ""
        }
        return dateString(lastEntry.dateTime)
    }

    /// Assigns a sequential index to each entry within its respective day.
    private func indexEntriesPerDay(_ entries: [WetDiaperEntry]) -> [(
        entry: WetDiaperEntry, index: Int
    )] {
        let sortedEntries = entries.sorted(by: { $0.dateTime < $1.dateTime })
        var dailyIndex: [String: Int] = [:]

        // Loop through sorted entries and assign an index based on the day
        return sortedEntries.map { entry in
            let dayKey = dateString(entry.dateTime)
            let index = (dailyIndex[dayKey] ?? 0) + 1
            dailyIndex[dayKey] = index
            return (entry, index)
        }
    }

    /// Returns a bubble size based on diaper volume and whether it's a mini chart.
    private func bubbleSize(_ volume: DiaperVolume, _ isMini: Bool) -> Double {
        switch volume {
        case .light: return isMini ? 30 : 100
        case .medium: return isMini ? 60 : 300
        case .heavy: return isMini ? 100 : 650
        }
    }

    /// Returns the color for the diaper entry based on its color.
    private func diaperColor(_ color: WetDiaperColor) -> Color {
        switch color {
        case .yellow: return .yellow
        case .pink: return Color(.pinkDiaper)
        case .redTinged: return .red
        }
    }
}
