//  StoolCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI

// swiftlint:disable closure_body_length
struct StoolChart: View {
    let entries: [StoolEntry]
    // Flag to determine whether it's a mini chart or a full chart
    var isMini: Bool
    
    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)

        Chart {
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime),
                    y: .value("Stool #", indexedEntry.index)
                )
                .symbolSize(bubbleSize(indexedEntry.entry.volume, isMini))
                .foregroundStyle(stoolColor(indexedEntry.entry.color))
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
    
    /// Formats a date into a string (e.g., "2025-03-06") for grouping
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func bubbleSize(_ volume: StoolVolume, _ isMini: Bool) -> Double {
        switch volume {
        case .light: return isMini ? 30 : 100
        case .medium:  return isMini ? 60 : 300
        case .heavy: return isMini ? 100 : 650
        }
    }

    
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

struct StoolsSummaryView: View {
    let entries: [StoolEntry]
    
    private var lastEntry: StoolEntry? {
        entries.sorted(by: { $0.dateTime > $1.dateTime }).first
    }
    
    private var formattedTime: String {
        guard let date = lastEntry?.dateTime else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationLink(destination: StoolsView(entries: entries)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)
                
                VStack {
                    HStack {
                        Image(systemName: "drop.fill")
                            .accessibilityLabel("Stool Drop")
                            .font(.title3)
                            .foregroundColor(.brown)
                        
                        Text("Stools")
                            .font(.title3.bold())
                            .foregroundColor(.brown)
                        
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
                            MiniStoolChart(entries: entries)
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

struct MiniStoolChart: View {
    let entries: [StoolEntry]
    
    var body: some View {
        StoolChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
    }
}
