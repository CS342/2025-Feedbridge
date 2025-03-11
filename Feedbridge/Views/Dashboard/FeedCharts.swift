//
//  FeedCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import Charts
import SwiftUI
/// View displaying a summary of feed data.
struct FeedsSummaryView: View {
    let entries: [FeedEntry]
    let babyId: String

    private var lastEntry: FeedEntry? {
        entries.max(by: { $0.dateTime < $1.dateTime })
    }

    private var formattedTime: String {
        formatDate(lastEntry?.dateTime)
    }

    var body: some View {
        NavigationLink(destination: FeedsView(entries: entries, babyId: babyId)) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// Creates a summary card view.
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

    /// Creates the header view for the summary card.
    private func header() -> some View {
        HStack {
            Image(systemName: "flame.fill")
                .accessibilityLabel("Flame")
                .font(.title3)
                .foregroundColor(.pink)

            Text("Feeds")
                .font(.title3.bold())
                .foregroundColor(.pink)

            Spacer()

            Image(systemName: "chevron.right")
                .accessibilityLabel("Next page")
                .foregroundColor(.gray)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding()
    }

    /// Displays entry details such as feed type and volume/time.
    private func entryDetails(_ entry: FeedEntry) -> some View {
        HStack {
            if entry.feedType == .bottle, let volume = entry.feedVolumeInML {
                Text("Bottle: \(volume) ml")
                    .font(.title2)
                    .foregroundColor(.primary)
            } else if entry.feedType == .directBreastfeeding, let time = entry.feedTimeInMinutes {
                Text("Breastfeeding: \(time) min")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Spacer()
            MiniFeedChart(entries: entries)
                .frame(width: 60, height: 40)
        }
        .padding([.bottom, .horizontal])
    }
}

/// Mini chart view for feed data.
struct MiniFeedChart: View {
    let entries: [FeedEntry]

    var body: some View {
        FeedChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}

/// Chart view displaying feed data with mini or full-size options.
struct FeedChart: View {
    let entries: [FeedEntry]
    var isMini: Bool

    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)
        let lastDay = lastEntryDate(entries)

        Chart {
            chartEntries(from: indexedEntries, lastDay: lastDay)
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange())
        .if(!isMini) { view in
            view.chartYAxisLabel("Feed Count")
        }
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }

    /// Creates chart entries with styling based on the mini flag and last day.
    private func chartEntries(from indexedEntries: [(entry: FeedEntry, index: Int)], lastDay: String) -> some ChartContent {
        ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
            PointMark(
                x: .value("Date", indexedEntry.entry.dateTime, unit: .day),
                y: .value("Feed #", indexedEntry.index)
            )
            .symbolSize(bubbleSize(indexedEntry.entry))
            .foregroundStyle(miniColor(entry: indexedEntry.entry, isMini: isMini, lastDay: lastDay))
        }
    }

    /// Determines color for the chart point based on the entry type.
    private func miniColor(entry: FeedEntry, isMini: Bool, lastDay: String) -> Color {
        isMini ? (dateString(entry.dateTime) == lastDay ? .pink : Color(.greyChart)) : feedColor(entry.feedType, entry.milkType)
    }

    /// Finds the last recorded feed entry date.
    private func lastEntryDate(_ entries: [FeedEntry]) -> String {
        guard let lastEntry = entries.max(by: { $0.dateTime < $1.dateTime }) else {
            return ""
        }
        return dateString(lastEntry.dateTime)
    }

    /// Indexes entries for each day and assigns sequential indices.
    private func indexEntriesPerDay(_ entries: [FeedEntry]) -> [(entry: FeedEntry, index: Int)] {
        let sortedEntries = entries.sorted(by: { $0.dateTime < $1.dateTime })
        var dailyIndex: [String: Int] = [:]

        return sortedEntries.map { entry in
            let dayKey = dateString(entry.dateTime)
            let index = (dailyIndex[dayKey] ?? 0) + 1
            dailyIndex[dayKey] = index
            return (entry, index)
        }
    }

    /// Determines bubble size based on feed type (breastfeeding or bottle).
    private func bubbleSize(_ entry: FeedEntry) -> Double {
        switch entry.feedType {
        case .directBreastfeeding:
            guard let duration = entry.feedTimeInMinutes else {
                return 30
            }
            switch duration {
            case 0..<10: return isMini ? 30 : 100
            case 10..<20: return isMini ? 60 : 300
            default: return isMini ? 100 : 650
            }
        case .bottle:
            guard let volume = entry.feedVolumeInML else {
                return 30
            }
            switch volume {
            case 0..<10: return isMini ? 30 : 100
            case 10..<30: return isMini ? 60 : 300
            default: return isMini ? 100 : 650
            }
        }
    }

    /// Assigns colors based on feed type and milk type.
    private func feedColor(_ type: FeedType, _ milk: MilkType?) -> Color {
        switch type {
        case .directBreastfeeding:
            return .pink
        case .bottle:
            switch milk {
            case .breastmilk:
                return .purple
            default:
                return .blue
            }
        }
    }
}
