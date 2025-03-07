//
//  FeedCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import Charts
import SwiftUI
struct FeedChart: View {
    let entries: [FeedEntry]
    // Flag to determine whether it's a mini chart or a full chart
    var isMini: Bool
    
    var body: some View {
        Chart {
            // Grouped points for Bottle Feeds
            let bottleEntries = entries
                .filter { $0.feedType == .bottle }
                .sorted(by: { $0.dateTime < $1.dateTime })

            if !bottleEntries.isEmpty {
                if !isMini {
                    ForEach(bottleEntries) { entry in
                        PointMark(
                            x: .value("Time", entry.dateTime),
                            y: .value("Volume (ml)", entry.feedVolumeInML ?? 0)
                        )
                        .symbol {
                            Circle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: 6)
                        }
                    }
                }
                ForEach(bottleEntries) { entry in
                            LineMark(
                                x: .value("Time", entry.dateTime),
                                y: .value("Volume (ml)", entry.feedVolumeInML ?? 0)
                            )
                            .foregroundStyle(.blue)
                        }
            }

            // Grouped points for Breastfeeding
            let breastfeedingEntries = entries
                .filter { $0.feedType == .directBreastfeeding }
                .sorted(by: { $0.dateTime < $1.dateTime })

            if !breastfeedingEntries.isEmpty {
                if !isMini {
                    ForEach(breastfeedingEntries) { entry in
                        PointMark(
                            x: .value("Time", entry.dateTime),
                            y: .value("Duration (min)", entry.feedTimeInMinutes ?? 0)
                        )
                        .symbol {
                            Rectangle()
                                .fill(Color.pink.opacity(0.6))
                                .frame(width: 6, height: 6)
                        }
                    }
                    ForEach(breastfeedingEntries) { entry in
                        LineMark(
                            x: .value("Time", entry.dateTime),
                            y: .value("Duration (min)", entry.feedTimeInMinutes ?? 0)
                        )
                        .foregroundStyle(.pink)
                    }
                }
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
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
