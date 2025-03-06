//  StoolCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
import Charts

// swiftlint:disable closure_body_length
struct StoolChart: View {
    let entries: [StoolEntry]
    // Flag to determine whether it's a mini chart or a full chart
    var isMini: Bool
    
    var body: some View {
        Chart {
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                BarMark(
                    x: .value("Date", entry.dateTime),
                    y: .value("Volume", stoolVolumeValue(entry.volume))
                )
                .foregroundStyle(stoolColor(entry.color))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
    
    private func stoolVolumeValue(_ volume: StoolVolume) -> Int {
        switch volume {
        case .light: return 1
        case .medium: return 2
        case .heavy: return 3
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
