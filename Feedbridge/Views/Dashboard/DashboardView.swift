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
// swiftlint:disable closure_body_length

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
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if let baby = viewModel.baby {
                    mainContent(for: baby)
                } else {
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
            }
            .navigationTitle("Dashboard")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            // Make sure to call these on the main actor:
            .task {
                // If no baby is selected, try to select the first one
                if selectedBabyId == nil {
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
            }
        }
    }

    @ViewBuilder
    private func mainContent(for baby: Baby) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                AlertView(baby: baby)
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
