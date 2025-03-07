//
//  WeightCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//


import SwiftUI
import Charts
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct WeightChart: View {
    let entries: [WeightEntry]
    var isMini: Bool
    
    var body: some View {
        Chart {
            let averagedEntries = averageWeightsPerDay()

            if !isMini {
                ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                    let day = Calendar.current.startOfDay(for: entry.dateTime)
                    PointMark(
                        x: .value("Date", day),
                        y: .value("Pounds (lb)", entry.asPounds.value)
                    )
                    .foregroundStyle(.gray)
                    .symbol {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 8)
                    }
                }
            }
            ForEach(averagedEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Pounds (lb)", entry.averageWeight)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartXAxis(isMini ? .hidden : .visible)
        .chartYAxis(isMini ? .hidden : .visible)
        .chartXScale(domain: last7DaysRange())
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
    
    private func averageWeightsPerDay() -> [DailyAverageWeight] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.dateTime)
        }

        return grouped.map { (date, entries) in
            let totalWeight = entries.reduce(0) { $0 + $1.asPounds.value }
            let averageWeight = totalWeight / Double(entries.count)
            return DailyAverageWeight(date: date, averageWeight: averageWeight)
        }
        .sorted { $0.date < $1.date }
    }
}

struct WeightsSummaryView: View {
    let entries: [WeightEntry]

    private var lastEntry: WeightEntry? {
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
        NavigationLink(destination: WeightsView(entries: entries)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)

                VStack {
                    HStack {
                        Image(systemName: "scalemass")
                            .accessibilityLabel("Scale")
                            .font(.title3)
                            .foregroundColor(.orange)

                        Text("Weights")
                            .font(.title3.bold())
                            .foregroundColor(.orange)

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
                            Text("\(entry.asPounds.value, specifier: "%.2f") lbs")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Spacer()
                            MiniWeightChart(entries: entries)
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

struct MiniWeightChart: View {
    let entries: [WeightEntry]

    var body: some View {
        WeightChart(entries: entries, isMini: true)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}
