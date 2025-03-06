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
    // Flag to determine whether it's a mini chart or a full chart
    var isMini: Bool
    
    var body: some View {
        Chart {
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                BarMark(
                    x: .value("Date", entry.dateTime),
                    y: .value("Volume", diaperVolumeValue(entry.volume))
                )
                .foregroundStyle(diaperColor(entry.color))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
    
    // Convert DiaperVolume to a numeric value for the Y-axis
    private func diaperVolumeValue(_ volume: DiaperVolume) -> Int {
        switch volume {
        case .light: return 1
        case .medium: return 2
        case .heavy: return 3
        }
    }
    
    // Convert WetDiaperColor to a SwiftUI Color
    private func diaperColor(_ color: WetDiaperColor) -> Color {
        switch color {
        case .yellow: return .yellow
        case .pink: return .pink
        case .redTingled: return .red
        }
    }
}

struct WetDiapersSummaryView: View {
    let entries: [WetDiaperEntry]
    
    private var lastEntry: WetDiaperEntry? {
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
                            .foregroundColor(.blue)
                        
                        Text("Wet Diapers")
                            .font(.title3.bold())
                            .foregroundColor(.blue)
                        
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
