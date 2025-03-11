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

import Charts
import SpeziAccount
import SwiftUI

/// Dashboard view displaying baby data such as weights, feeds, wet diapers, and stools.
struct DashboardView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(FeedbridgeStandard.self) private var standard
    @Binding var presentingAccount: Bool
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var baby: Baby?

    var body: some View {
        NavigationStack {
            Group {
                // Show loading, error, or main content
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    mainContent.refreshable {
                        await loadBaby()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .task {
                await loadBaby()
            }
        }
    }

    /// Main content of the dashboard, displaying summary views.
    @ViewBuilder private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let baby {
                    AlertView(baby: baby)
                    WeightsSummaryView(entries: baby.weightEntries.weightEntries, babyId: baby.id ?? "")
                    FeedsSummaryView(entries: baby.feedEntries.feedEntries, babyId: baby.id ?? "")
                    WetDiapersSummaryView(entries: baby.wetDiaperEntries.wetDiaperEntries, babyId: baby.id ?? "")
                    StoolsSummaryView(entries: baby.stoolEntries.stoolEntries, babyId: baby.id ?? "")
                }
            }
            .padding()
        }
    }

    /// Loads baby data asynchronously.
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
            errorMessage = "Failed to load baby: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
