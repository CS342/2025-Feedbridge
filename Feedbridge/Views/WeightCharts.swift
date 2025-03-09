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
    var entries: [WeightEntry]
    var isMini: Bool
    
    @Binding var weightUnitPreference: WeightUnit
    
    var body: some View {
        Chart {
            let averagedEntries = averageWeightsPerDay()

            if !isMini {
                ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                    let day = Calendar.current.startOfDay(for: entry.dateTime)
                    PointMark(
                        x: .value("Date", day),
                        y: .value(weightUnitPreference == .kilograms ? "Weight (kg)" : "Weight (lb)",
                            weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value
                            )
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
                    y: .value(weightUnitPreference == .kilograms ? "Weight (kg)" : "Weight (lb)", entry.averageWeight)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.indigo)
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

        var dailyAverages: [DailyAverageWeight] = []

        for (date, entries) in grouped {
            let totalWeight = entries.reduce(0) { result, entry in
                result + (weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value)
            }
            let averageWeight = totalWeight / Double(entries.count)
            dailyAverages.append(DailyAverageWeight(date: date, averageWeight: averageWeight))
        }

        return dailyAverages.sorted { $0.date < $1.date }
    }
}

struct WeightsSummaryView: View {
    var entries: [WeightEntry]
    let babyId: String
    
    @AppStorage(UserDefaults.weightUnitPreference) var weightUnitPreference: WeightUnit = .kilograms
    
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
        NavigationLink(destination: WeightsView(entries: entries, babyId: babyId)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(0.8)

                VStack {
                    HStack {
                        Image(systemName: "scalemass")
                            .accessibilityLabel("Scale")
                            .font(.title3)
                            .foregroundColor(.indigo)

                        Text("Weights")
                            .font(.title3.bold())
                            .foregroundColor(.indigo)

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
                            Text("\(weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value, specifier: "%.2f") \(weightUnitPreference == .kilograms ? "kg" : "lb")")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Spacer()
                            MiniWeightChart(entries: entries, weightUnitPreference: $weightUnitPreference)
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
    var entries: [WeightEntry]
    @Binding var weightUnitPreference: WeightUnit
    
    var body: some View {
        WeightChart(entries: entries, isMini: true, weightUnitPreference: $weightUnitPreference)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}
