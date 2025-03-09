//  WeightCharts.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI

/// Displays weight summary card and navigates to full view.
struct WeightsSummaryView: View {
    let entries: [WeightEntry]
    
    @AppStorage(UserDefaults.weightUnitPreference) var weightUnitPreference: WeightUnit = .kilograms
    
    private var lastEntry: WeightEntry? {
        entries.max(by: { $0.dateTime < $1.dateTime })
    }

    private var formattedTime: String {
        formatDate(lastEntry?.dateTime)
    }

    var body: some View {
        NavigationLink(destination: WeightsView(entries: entries)) {
            summaryCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Creates the main summary card
    private func summaryCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .opacity(0.8)

            VStack {
                header()
                if let entry = lastEntry {
                    Spacer()
                    entryDetails(entry)
                } else {
                    noDataText()
                }
            }
        }
        .frame(height: 120)
    }

    /// Creates the header section with the icon and title
    private func header() -> some View {
        HStack {
            Image(systemName: "scalemass.fill")
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
    }

    /// Displays the last recorded weight entry
    private func entryDetails(_ entry: WeightEntry) -> some View {
        HStack {
            Text(formattedWeightText(entry: entry, weightUnitPreference: weightUnitPreference))
                .font(.title2)
                .foregroundColor(.primary)
            
            Spacer()
            
            MiniWeightChart(entries: entries, weightUnitPreference: $weightUnitPreference)
                .frame(width: 60, height: 40)
                .opacity(0.5)
        }
        .padding([.bottom, .horizontal])
    }

    /// Displays a placeholder when no data is available
    private func noDataText() -> some View {
        Text("No data added")
            .foregroundColor(.gray)
            .padding()
    }
}

/// Mini version of the weight chart to be used in the summary view.
struct MiniWeightChart: View {
    let entries: [WeightEntry]
    @Binding var weightUnitPreference: WeightUnit
    
    var body: some View {
        WeightChart(entries: entries, isMini: true, weightUnitPreference: $weightUnitPreference)
            .frame(width: 60, height: 40)
            .opacity(0.8)
    }
}

/// Displays weight entries on a chart with the option for a mini view.
struct WeightChart: View {
    let entries: [WeightEntry]
    var isMini: Bool
    
    @Binding var weightUnitPreference: WeightUnit
    
    var body: some View {
        Chart {
            let averagedEntries = averageWeightsPerDay()

            // Plot individual weight entries for full view
            if !isMini {
                ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                    let day = Calendar.current.startOfDay(for: entry.dateTime)
                    PointMark(
                        x: .value("Date", day),
                        y: .value(
                                weightUnitPreference == .kilograms ? "Weight (kg)" : "Weight (lb)",
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
            // Plot averaged weight data
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
    
    // Groups and averages weights per day
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
/// Utility function to format the weight text based on user preference.
func formattedWeightText(entry: WeightEntry, weightUnitPreference: WeightUnit) -> String {
    let value = weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value
    let unit = weightUnitPreference == .kilograms ? "kg" : "lb"
    return String(format: "%.2f %@", value, unit)
}
