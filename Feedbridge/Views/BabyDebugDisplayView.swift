//
//  BabyDebugDisplayView.swift
//  Feedbridge
//
//  Created by Calvin Xu on 2/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
// swiftlint:disable file_types_order

import SwiftUI

struct BabyDebugDisplayView: View {
    @Environment(FeedbridgeStandard.self) private var standard
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?

    @State private var baby: Baby?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if let baby {
                    BabyDetailsList(baby: baby)
                } else {
                    Text("No baby selected")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Baby Debug View")
            .task {
                await loadBaby()
            }
        }
    }

    private func loadBaby() async {
        guard let babyId = selectedBabyId else {
            baby = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            baby = try await standard.getBaby(id: babyId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct BabyDetailsList: View {
    let baby: Baby

    var body: some View {
        List {
            BasicInfoSection(baby: baby)
            FeedEntriesSection(entries: baby.feedEntries.feedEntries)
            WeightEntriesSection(entries: baby.weightEntries.weightEntries)
            StoolEntriesSection(entries: baby.stoolEntries.stoolEntries)
            WetDiaperEntriesSection(entries: baby.wetDiaperEntries.wetDiaperEntries)
            DehydrationChecksSection(checks: baby.dehydrationChecks.dehydrationChecks)
        }
    }
}

private struct BasicInfoSection: View {
    let baby: Baby

    var body: some View {
        Section("Basic Info") {
            LabeledContent("Name", value: baby.name)
            LabeledContent("ID", value: baby.id ?? "N/A")
            LabeledContent("Date of Birth", value: baby.dateOfBirth.formatted())
            LabeledContent("Age", value: "\(baby.ageInMonths) months")
            if let weight = baby.currentWeight {
                LabeledContent("Current Weight", value: "\(weight.asKilograms.formatted())")
            }
            LabeledContent("Has Active Alerts", value: baby.hasActiveAlerts ? "Yes" : "No")
        }
    }
}

private struct FeedEntriesSection: View {
    let entries: [FeedEntry]

    var body: some View {
        Section("Feed Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Type: \(entry.feedType.rawValue)")
                    if entry.feedType == .bottle {
                        Text("Milk Type: \(entry.milkType?.rawValue ?? "N/A")")
                        if let volume = entry.feedVolumeInML {
                            Text("Amount: \(volume)ml")
                        }
                    } else if let minutes = entry.feedTimeInMinutes {
                        Text("Duration: \(minutes) minutes")
                    }
                }
            }
        }
    }
}

private struct WeightEntriesSection: View {
    let entries: [WeightEntry]

    var body: some View {
        Section("Weight Entries") {
            if entries.isEmpty {
                Text("No weight entries")
                    .foregroundColor(.secondary)
            } else {
                ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.dateTime.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.asKilograms.formatted())
                            .font(.body)
                    }
                }
            }
        }
    }
}

private struct StoolEntriesSection: View {
    let entries: [StoolEntry]

    var body: some View {
        Section("Stool Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Volume: \(entry.volume.rawValue)")
                    Text("Color: \(entry.color.rawValue)")
                    if entry.medicalAlert {
                        Text("⚠️ Medical Alert")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct WetDiaperEntriesSection: View {
    let entries: [WetDiaperEntry]

    var body: some View {
        Section("Wet Diaper Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                    Text("Volume: \(entry.volume.rawValue)")
                    Text("Color: \(entry.color.rawValue)")
                    if entry.dehydrationAlert {
                        Text("⚠️ Dehydration Alert")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

private struct DehydrationChecksSection: View {
    let checks: [DehydrationCheck]

    var body: some View {
        Section("Dehydration Checks") {
            ForEach(checks.sorted(by: { $0.dateTime > $1.dateTime })) { check in
                VStack(alignment: .leading) {
                    Text(check.dateTime.formatted())
                        .font(.caption)
                    Text("Poor Skin Elasticity: \(check.poorSkinElasticity ? "Yes" : "No")")
                    Text("Dry Mucous Membranes: \(check.dryMucousMembranes ? "Yes" : "No")")
                    if check.dehydrationAlert {
                        Text("⚠️ Dehydration Alert")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    BabyDebugDisplayView()
        .previewWith(standard: FeedbridgeStandard()) {}
}
