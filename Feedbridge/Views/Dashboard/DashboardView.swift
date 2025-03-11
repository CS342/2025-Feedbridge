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

  @State private var viewModel = DashboardViewModel()

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

        // Only start listening if we have a baby selected
        if let id = selectedBabyId {
          viewModel.startListening(babyId: id)
        }
      }
      .onDisappear {
        // Also ensure main actor for the same reason:
        Task { @MainActor in
          viewModel.stopListening()
        }
      }
    }
  }

  @ViewBuilder
  private func mainContent(for baby: Baby) -> some View {
    ScrollView {
      VStack(spacing: 16) {
        AlertView(baby: baby)
          DehydrationAlertSummaryView(
            entries: baby.dehydrationChecks.dehydrationChecks
          )
        WeightsSummaryView(
          entries: baby.weightEntries.weightEntries,
          babyId: baby.id ?? ""
        )
        FeedsSummaryView(
          entries: baby.feedEntries.feedEntries,
          babyId: baby.id ?? ""
        )
        WetDiapersSummaryView(
          entries: baby.wetDiaperEntries.wetDiaperEntries,
          babyId: baby.id ?? ""
        )
        StoolsSummaryView(
          entries: baby.stoolEntries.stoolEntries,
          babyId: baby.id ?? ""
        )
      }
      .padding()
    }
  }
}
