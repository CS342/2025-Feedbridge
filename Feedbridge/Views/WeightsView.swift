//
//  WeightsView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 3/3/25.
//

import Charts
import SwiftUI
struct WeightsView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @Environment(\.presentationMode) var presentationMode
    @State var entries: [WeightEntry]
    
    let babyId: String
    
    @AppStorage(UserDefaults.weightUnitPreference) var weightUnitPreference: WeightUnit = .kilograms

    var body: some View {
        NavigationStack {
            WeightChart(entries: entries, isMini: false)
                .frame(height: 300)
                .padding()
            weightEntriesList
        }
        .navigationTitle("Weights")
    }


    private var fullWeightChart: some View {
        Chart {
            let averagedEntries = averageWeightsPerDay()

            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                let day = Calendar.current.startOfDay(for: entry.dateTime)
                PointMark(
                    x: .value("Date", day),
                    y: .value("Weight (lb)", entry.asPounds.value)
                )
                .foregroundStyle(.gray)
                .symbol {
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 8)
                }
            }

            ForEach(averagedEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight (lb)", entry.averageWeight)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.indigo)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .frame(height: 300)
        .padding()
    }

    private var weightEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.asPounds.value, specifier: "%.2f") lb")
                    .font(.headline)
                Text(entry.dateTime.formattedString())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }.swipeActions {
                Button(role: .destructive) { Task {
                    print("Delete weight entry with id: \(entry.id ?? "")")
                print("Baby: \(babyId)")
                    try await standard.deleteWeightEntry(babyId: babyId, entryId: entry.id ?? "")
                    self.entries.removeAll { $0.id == entry.id }
                } } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
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

struct DailyAverageWeight: Identifiable {
    let id = UUID()
    let date: Date
    let averageWeight: Double
}
