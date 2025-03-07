//
//  FeedCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import Charts
import SwiftUI
// swiftlint:disable closure_body_length

struct FeedChart: View {
    let entries: [FeedEntry]
    var isMini: Bool
    
    var body: some View {
        let indexedEntries = indexEntriesPerDay(entries)
        
        Chart {
            ForEach(indexedEntries, id: \.entry.id) { indexedEntry in
                PointMark(
                    x: .value("Date", indexedEntry.entry.dateTime),
                    y: .value("Feed #", indexedEntry.index)
                )
                .symbolSize(bubbleSize(indexedEntry.entry))
                .foregroundStyle(feedColor(indexedEntry.entry.feedType))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange())
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
    
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
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func bubbleSize(_ entry: FeedEntry) -> Double {
        switch entry.feedType {
        case .directBreastfeeding:
            guard let duration = entry.feedTimeInMinutes else { return 30 }
            switch duration {
            case 0..<5: return isMini ? 30 : 100
            case 5..<10: return isMini ? 60 : 200
            case 10..<20: return isMini ? 90 : 350
            default: return isMini ? 120 : 600
            }
        case .bottle:
            guard let volume = entry.feedVolumeInML else { return 30 }
            switch volume {
            case 15..<30: return isMini ? 30 : 100
            case 30..<60: return isMini ? 60 : 200
            case 60..<90: return isMini ? 90 : 350
            default: return isMini ? 120 : 600
            }
        }
    }
    
    private func feedColor(_ type: FeedType) -> Color {
        switch type {
        case .directBreastfeeding: return .pink
        case .bottle: return .purple
        }
    }
}

struct FeedsSummaryView: View {
    let entries: [FeedEntry]
    
    private var lastEntry: FeedEntry? {
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
        NavigationLink(destination: FeedsView(entries: entries)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)
                
                VStack {
                    HStack {
                        Image(systemName: "flame.fill")
                            .accessibilityLabel("Flame")
                            .font(.title3)
                            .foregroundColor(.pink)
                        
                        Text("Feeds")
                            .font(.title3.bold())
                            .foregroundColor(.pink)
                        
                        Spacer()
                    }
                    .padding()
                    
                    if let entry = lastEntry {
                        Spacer()
                        
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

struct MiniFeedChart: View {
    let entries: [FeedEntry]
    
    var body: some View {
        FeedChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
            .opacity(0.5)
    }
}
