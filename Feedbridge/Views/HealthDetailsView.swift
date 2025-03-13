//
//  SettingsEntriesView.swift
//  Feedbridge
//
//  Created by Shamit Surana on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct BasicInfoSection: View {
    let baby: Baby
    @Binding var weightUnitPreference: WeightUnit

    var body: some View {
        Section("Basic Info") {
            LabeledContent("Name", value: baby.name)
            LabeledContent("Date of Birth", value: baby.dateOfBirth.formatted())
            LabeledContent("Age", value: "\(baby.ageInMonths) months")
        }
    }
}

struct FeedEntriesSection: View {
    let entries: [FeedEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

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
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteFeedEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

struct WeightEntriesSection: View {
    let entries: [WeightEntry]
    @Binding var weightUnitPreference: WeightUnit
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Weight Entries") {
            ForEach(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.dateTime.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(
                        "\(weightUnitPreference == .kilograms ? entry.asKilograms.value : entry.asPounds.value, specifier: "%.2f") \(weightUnitPreference == .kilograms ? "kg" : "lb")"
                    )
                    .font(.body)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteWeightEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

struct StoolEntriesSection: View {
    let entries: [StoolEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

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
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteStoolEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

struct WetDiaperEntriesSection: View {
    let entries: [WetDiaperEntry]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Section("Void Entries") {
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
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let entryId = entry.id {
                                try await standard.deleteWetDiaperEntry(babyId: babyId, entryId: entryId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}

struct DehydrationChecksSection: View {
    let checks: [DehydrationCheck]
    var babyId: String
    var standard: FeedbridgeStandard
    @State private var refreshID = UUID()  // For forcing view refresh

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
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            if let checkId = check.id {
                                try await standard.deleteDehydrationCheck(babyId: babyId, entryId: checkId)
                                // Force view refresh
                                refreshID = UUID()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .id(refreshID)  // Force refresh when an item is deleted
        }
    }
}


struct HealthDetailsView: View {
    // Use the shared viewModel instead of a direct baby reference
    var viewModel: DashboardViewModel
    @Binding var weightUnitPreference: WeightUnit
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?
    @State private var isRefreshing = false
    @Environment(FeedbridgeStandard.self) private var standard
    @State private var refreshID = UUID()  // For forcing view refresh

    var body: some View {
        Group {
            if let baby = viewModel.baby {
                List {
                    FeedEntriesSection(
                        entries: baby.feedEntries.feedEntries, babyId: baby.id ?? "", standard: standard
                    )
                    WeightEntriesSection(
                        entries: baby.weightEntries.weightEntries,
                        weightUnitPreference: $weightUnitPreference,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                    StoolEntriesSection(
                        entries: baby.stoolEntries.stoolEntries, babyId: baby.id ?? "", standard: standard
                    )
                    WetDiaperEntriesSection(
                        entries: baby.wetDiaperEntries.wetDiaperEntries,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                    DehydrationChecksSection(
                        checks: baby.dehydrationChecks.dehydrationChecks,
                        babyId: baby.id ?? "",
                        standard: standard
                    )
                }
                .id(refreshID)  // Force refresh when data changes
                .refreshable {
                    await refreshData()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Health Details")
        .onAppear {
            // Ensure we have the latest data when the view appears
            if !isRefreshing {
                Task {
                    await refreshData()
                }
            }
        }
        .onChange(of: viewModel.baby) { _, _ in
            // When the baby data changes in the viewModel, update the refreshID
            refreshID = UUID()
        }
    }

    private func refreshData() async {
        isRefreshing = true

        // Stop and restart the listener to refresh all data
        viewModel.stopListening()
        if let id = selectedBabyId {
            viewModel.startListening(babyId: id)
        }

        // Add a small delay to ensure the UI shows the refresh indicator
        try? await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

        // Update the refreshID to force a view refresh
        refreshID = UUID()

        isRefreshing = false
    }
}
