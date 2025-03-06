//
//  WetDiapersView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import SwiftUI
import Charts

struct WetDiapersView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [WetDiaperEntry]

    var body: some View {
        NavigationView {
            VStack {
                fullWetDiaperChart
                wetDiaperEntriesList
            }
            .navigationTitle("Wet Diapers")
        }
    }

    // Full Wet Diaper Chart
    private var fullWetDiaperChart: some View {
        Chart {
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                BarMark(
                    x: .value("Date", entry.dateTime),
                    y: .value("Volume", diaperVolumeValue(entry.volume))
                )
                .foregroundStyle(diaperColor(entry.color))
            }
        }
        .chartYScale(domain: [0, 3]) // Set the Y-axis scale range from 0 to 3
        .frame(height: 300)
        .padding()
    }

    // Function to convert diaper volume to a numeric value
    private func diaperVolumeValue(_ volume: DiaperVolume) -> Int {
        switch volume {
        case .light: return 1
        case .medium: return 2
        case .heavy: return 3
        }
    }

    // Function to assign a color to the diaper
    private func diaperColor(_ color: WetDiaperColor) -> Color {
        switch color {
        case .yellow: return .yellow
        case .pink: return .pink
        case .redTingled: return .red
        }
    }

    // List of Wet Diaper Entries
    private var wetDiaperEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(entry.dateTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct DailyAverageWetDiaperVolume: Identifiable {
    let id = UUID()
    let date: Date
    let averageVolume: Double
}

