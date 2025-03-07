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
    var isMini: Bool
    
    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)
        let lastDay = lastEntryDate(entries) // Get the last recorded date

        Chart {
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime),
                    y: .value("Stool #", indexedEntry.index)
                )
                .symbolSize(bubbleSize(indexedEntry.entry.volume, isMini))
                .foregroundStyle(miniColor(entry: indexedEntry.entry, isMini: isMini, lastDay: lastDay))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange())
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
    
    private func miniColor(entry : StoolEntry, isMini : Bool, lastDay : String) -> Color{
        return isMini ? (dateString(entry.dateTime) == lastDay ? .brown: Color(.greyChart)) : stoolColor(entry.color)
    }
    
    /// Determines the last recorded date as a string
    private func lastEntryDate(_ entries: [StoolEntry]) -> String {
        guard let lastEntry = entries.max(by: { $0.dateTime < $1.dateTime }) else {
            return ""
        }
        return dateString(lastEntry.dateTime)
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
                        
                        Image(systemName: "chevron.right")
                            .accessibilityLabel("Next page")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .fontWeight(.semibold)
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
            .opacity(0.8)
    }
}
