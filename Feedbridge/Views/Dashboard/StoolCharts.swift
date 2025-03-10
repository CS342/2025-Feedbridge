//
//  StoolCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI
/// View displaying a summary of stool entries.
struct StoolsSummaryView: View {
    let entries: [StoolEntry]

    private var lastEntry: StoolEntry? {
        entries.max(by: { $0.dateTime < $1.dateTime })
    }

    private var formattedTime: String {
        formatDate(lastEntry?.dateTime)
    }

    var body: some View {
        NavigationLink(destination: StoolsView(entries: entries)) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Creates a summary card for stool entries.
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
                    Text("No data added")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .frame(height: 120)
    }

    /// Header for the summary card
    private func header() -> some View {
        HStack {
            Image(systemName: "drop.fill")
                .accessibilityLabel("Stool Drop")
                .font(.title3)
                .foregroundColor(.brown)

            Text("Stools")
                .font(.title3.bold())
                .foregroundColor(.brown)

            Spacer()

            Image(systemName: "chevron.right")
                .accessibilityLabel("Next page")
                .foregroundColor(.gray)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
    }

    /// Displays the details of a single stool entry
    private func entryDetails(_ entry: StoolEntry) -> some View {
        HStack {
            Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                .font(.title2)
                .foregroundColor(.primary)
            Spacer()
            MiniStoolChart(entries: entries)
                .frame(width: 60, height: 40)
        }
        .padding([.bottom, .horizontal])
    }
}

/// Mini chart view for stool entries.
struct MiniStoolChart: View {
    let entries: [StoolEntry]

    var body: some View {
        StoolChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}

/// View for displaying stool entries as a chart.
struct StoolChart: View {
    let entries: [StoolEntry]
    var isMini: Bool

    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)
        let lastDay = lastEntryDate(entries) // Get the last recorded date

        Chart {
            // Generate chart points for each stool entry
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime, unit: .day),
                    y: .value("Stool #", indexedEntry.index)
                )
                .symbolSize(bubbleSize(indexedEntry.entry.volume, isMini))
                .foregroundStyle(miniColor(entry: indexedEntry.entry, isMini: isMini, lastDay: lastDay))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange())
        .if(!isMini) { view in
            view.chartYAxisLabel("Stool Count")
        }
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }

    /// Returns color based on whether the chart is mini and if it is the last day.
    private func miniColor(entry: StoolEntry, isMini: Bool, lastDay: String) -> Color {
        isMini ? (dateString(entry.dateTime) == lastDay ? .brown : Color(.greyChart)) : stoolColor(entry.color)
    }

    /// Determines the last recorded date as a string
    private func lastEntryDate(_ entries: [StoolEntry]) -> String {
        guard let lastEntry = entries.max(by: { $0.dateTime < $1.dateTime }) else {
            return ""
        }
        return dateString(lastEntry.dateTime)
    }

    /// Indexes each stool entry by day and assigns a sequential index
    private func indexEntriesPerDay(_ entries: [StoolEntry]) -> [(entry: StoolEntry, index: Int)] {
        let sortedEntries = entries.sorted(by: { $0.dateTime < $1.dateTime })
        var dailyIndex: [String: Int] = [:]

        return sortedEntries.map { entry in
            let dayKey = dateString(entry.dateTime)
            let index = (dailyIndex[dayKey] ?? 0) + 1
            dailyIndex[dayKey] = index
            return (entry, index)
        }
    }

    /// Returns bubble size based on stool volume.
    private func bubbleSize(_ volume: StoolVolume, _ isMini: Bool) -> Double {
        switch volume {
        case .light: return isMini ? 30 : 100
        case .medium:  return isMini ? 60 : 300
        case .heavy: return isMini ? 100 : 650
        }
    }

    /// Maps stool color to a specific chart color.
    private func stoolColor(_ color: StoolColor) -> Color {
        switch color {
        case .black: return .black
        case .darkGreen: return .green
        case .green: return .mint
        case .brown: return .brown
        case .yellow: return .yellow
        case .beige: return .orange
        }
    }
}
