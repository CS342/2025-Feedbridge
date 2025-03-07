//
//  WetDiaperCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import Charts
import SwiftUI

// swiftlint:disable closure_body_length
struct WetDiaperChart: View {
    let entries: [WetDiaperEntry]
    var isMini: Bool
    @State private var scrollPosition: Date? // Tracks the initial scroll position


    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)

        Chart {
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime, unit: .day),
                    y: .value("Diaper #", indexedEntry.index) // Use the sequential index
                )
                .symbolSize(bubbleSize(indexedEntry.entry.volume, isMini))
                .foregroundStyle(diaperColor(indexedEntry.entry.color))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange()) // Restrict initial view to last 7 days
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }

    /// Assigns a sequential index to each entry within its respective day
    private func indexEntriesPerDay(_ entries: [WetDiaperEntry]) -> [(entry: WetDiaperEntry, index: Int)] {
        let sortedEntries = entries.sorted(by: { $0.dateTime < $1.dateTime })
        var dailyIndex: [String: Int] = [:]

        return sortedEntries.map { entry in
            let dayKey = dateString(entry.dateTime)
            let index = (dailyIndex[dayKey] ?? 0) + 1
            dailyIndex[dayKey] = index
            return (entry, index)
        }
    }

    /// Formats a date into a string (e.g., "2025-03-06") for grouping
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func bubbleSize(_ volume: DiaperVolume, _ isMini: Bool) -> Double {
        switch volume {
        case .light: return isMini ? 30 : 100
        case .medium:  return isMini ? 60 : 300
        case .heavy: return isMini ? 100 : 650
        }
    }

    private func diaperColor(_ color: WetDiaperColor) -> Color {
        switch color {
        case .yellow: return .yellow
        case .pink: return Color(.pinkDiaper)
        case .redTinged: return .red
        }
    }
}

struct WetDiapersSummaryView: View {
    let entries: [WetDiaperEntry]
    
    private var lastEntry: WetDiaperEntry? {
        entries.sorted(by: { $0.dateTime > $1.dateTime }).first
    }
    
    private var formattedTime: String {
        guard let date = lastEntry?.dateTime else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationLink(destination: WetDiapersView(entries: entries)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)
                
                VStack {
                    HStack {
                        Image(systemName: "drop.fill")
                            .accessibilityLabel("Wet Diaper Drop")
                            .font(.title3)
                            .foregroundColor(.indigo)
                        
                        Text("Wet Diapers")
                            .font(.title3.bold())
                            .foregroundColor(.indigo)
                        
                        Spacer()
                    }
                    .padding()
                    
                    if let entry = lastEntry {
                        Spacer()
                        
                        HStack {
                            Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Spacer()
                            MiniWetDiaperChart(entries: entries)
                                .frame(width: 60, height: 40)
                                .opacity(0.5)
                        }
                        .padding([.bottom, .horizontal])
                    } else {
                        Text("No data added")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .frame(height: 120)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MiniWetDiaperChart: View {
    let entries: [WetDiaperEntry]
    
    var body: some View {
        WetDiaperChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
    }
}
