//
//  StoolsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
import Charts
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct StoolsView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [StoolEntry]

    var body: some View {
        NavigationView {
            VStack {
                fullStoolChart
                stoolEntriesList
            }
            .navigationTitle("Stools")
        }
    }

    private var fullStoolChart: some View {
        Chart {
            let groupedEntries = groupStoolEntriesByDay()
            
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                let day = Calendar.current.startOfDay(for: entry.dateTime)
                PointMark(
                    x: .value("Date", day),
                    y: .value("Volume", stoolVolumeValue(entry.volume))
                )
                .foregroundStyle(.gray)
                .symbol {
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 8)
                }
            }
            
            ForEach(groupedEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Average Volume", entry.averageVolume)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.cyan)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .frame(height: 300)
        .padding()
    }

    private var stoolEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) Volume")
                    .font(.headline)
                Text("\(entry.color.rawValue.capitalized) Color")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(entry.dateTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    private func groupStoolEntriesByDay() -> [DailyAverageStoolVolume] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.dateTime)
        }

        return grouped.map { (date, entries) in
            let totalVolume = entries.reduce(0) { $0 + stoolVolumeValue($1.volume) }
            let averageVolume = totalVolume / Double(entries.count)
            return DailyAverageStoolVolume(date: date, averageVolume: averageVolume)
        }
        .sorted { $0.date < $1.date }
    }

    private func stoolVolumeValue(_ volume: StoolVolume) -> Double {
        switch volume {
        case .light: return 1.0
        case .medium: return 2.0
        case .heavy: return 3.0
        }
    }
}

struct DailyAverageStoolVolume: Identifiable {
    let id = UUID()
    let date: Date
    let averageVolume: Double
}
