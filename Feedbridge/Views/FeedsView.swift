//
//  feedsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
import Charts
import SwiftUI
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct FeedsView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [FeedEntry]

    var body: some View {
        NavigationView {
            VStack {
                fullFeedChart
                feedEntriesList
            }
            .navigationTitle("Feeds")
        }
    }

    private var fullFeedChart: some View {
        Chart {
            // Grouped points for Bottle Feeds
            let bottleEntries = entries
                .filter { $0.feedType == .bottle }
                .sorted(by: { $0.dateTime < $1.dateTime })

            if !bottleEntries.isEmpty {
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
        .frame(height: 300)
        .padding()
    }



    private var feedEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text(entry.feedType == .bottle ? "Bottle Feed: \(entry.feedVolumeInML ?? 0) ml" : "Breastfeeding: \(entry.feedTimeInMinutes ?? 0) min")
                    .font(.headline)
                Text(entry.dateTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
