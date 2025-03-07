//
//  WeightsSummaryView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
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
                    }
                    .padding()

                    if let entry = lastEntry {
                        Spacer()
                        HStack {
                            Text("\(entry.asKilograms.value, specifier: "%.2f") kg")
                                .font(.title2)
                                .foregroundColor(.primary)
                            Spacer()
//                            MiniWeightChart(entries: entries)
//                                .frame(width: 60, height: 40)
//                                .opacity(0.5)
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
