//
//  DashboardView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import SpeziAccount
import SwiftUI

struct DashboardView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(FeedbridgeStandard.self) private var standard

    // Use the shared viewModel passed from HomeView
    var viewModel: DashboardViewModel

    @Binding var presentingAccount: Bool
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if let baby = viewModel.baby {
                    mainContent(for: baby)
                } else {
                    noBabiesFoundView
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            // Make sure to call these on the main actor:
            .task {
                await loadBabyData()
            }
        }
    }

    // Loading state view
    private var loadingView: some View {
        ProgressView()
    }

    // Error state view
    private func errorView(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
    }

    // No babies found view
    private var noBabiesFoundView: some View {
        VStack(spacing: 16) {
            VStack {
                Text("No babies found")
                    .font(.headline)
                Text("Please add a baby in Settings before adding entries.")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
            }
            .padding()
            Spacer()
        }
    }

    // Task to load baby data or load test data if in testing mode
    @MainActor
    private func loadBabyData() async {
        if selectedBabyId == nil {
            await selectFirstBabyIfNeeded()
        }
        if ProcessInfo.processInfo.arguments.contains("--testingMode") {
            await loadTestData()
        }
    }

    // Select the first baby if none is selected
    @MainActor
    private func selectFirstBabyIfNeeded() async {
        do {
            let babies = try await standard.getBabies()
            if !babies.isEmpty {
                selectedBabyId = babies.first?.id
                UserDefaults.standard.selectedBabyId = selectedBabyId
            }
        } catch {
            viewModel.errorMessage = "Failed to load babies: \(error.localizedDescription)"
        }
    }

    // Mock data loading for testing
    @MainActor
    private func loadTestData() async {
        let testBaby = Baby(name: "Benjamin", dateOfBirth: Date().addingTimeInterval(-30 * 24 * 60 * 60))

        let calendar = Calendar.current
        let targetDate = calendar.date(from: DateComponents(year: 2025, month: 3, day: 11, hour: 0, minute: 0, second: 0)) ?? Date()
        let mockStoolEntries = [
            StoolEntry(dateTime: targetDate, volume: .medium, color: .brown)
        ]
        let mockFeedEntries = [
            FeedEntry(directBreastfeeding: 15, dateTime: targetDate)
        ]
        // Mock weight entries for testing
        let mockWeightEntries: [WeightEntry] = [
            WeightEntry(pounds: 7, ounces: 4, dateTime: targetDate)
        ]
        let mockDehydrationChecks: [DehydrationCheck] = [
            DehydrationCheck(dateTime: targetDate, poorSkinElasticity: true, dryMucousMembranes: false)
        ]
        let mockWetDiaperEntries: [WetDiaperEntry] = [
            WetDiaperEntry(dateTime: targetDate, volume: .medium, color: .yellow)
        ]
        viewModel.baby = Baby(name: testBaby.name, dateOfBirth: testBaby.dateOfBirth)
        viewModel.baby?.stoolEntries.stoolEntries = mockStoolEntries
        viewModel.baby?.feedEntries.feedEntries = mockFeedEntries
        viewModel.baby?.weightEntries.weightEntries = mockWeightEntries
        viewModel.baby?.dehydrationChecks.dehydrationChecks = mockDehydrationChecks
        viewModel.baby?.wetDiaperEntries.wetDiaperEntries = mockWetDiaperEntries
    }

    // Main content view for a baby
    @ViewBuilder
    private func mainContent(for baby: Baby) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                AlertView(
                    baby: baby,
                    viewModel: viewModel
                )
                WeightsSummaryView(
                    entries: baby.weightEntries.weightEntries,
                    babyId: baby.id ?? "",
                    viewModel: viewModel
                )
                FeedsSummaryView(
                    entries: baby.feedEntries.feedEntries,
                    babyId: baby.id ?? "",
                    viewModel: viewModel
                )
                WetDiapersSummaryView(
                    entries: baby.wetDiaperEntries.wetDiaperEntries,
                    babyId: baby.id ?? "",
                    viewModel: viewModel
                )
                StoolsSummaryView(
                    entries: baby.stoolEntries.stoolEntries,
                    babyId: baby.id ?? "",
                    viewModel: viewModel
                )
                DehydrationSummaryView(
                    entries: baby.dehydrationChecks.dehydrationChecks,
                    babyId: baby.id ?? "",
                    viewModel: viewModel
                )
            }
            .padding()
        }
    }
}
