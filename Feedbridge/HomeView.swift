//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct HomeView: View {
    enum Tabs: String {
        case dashboard
        case addEntries
        case debug
    }

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.dashboard
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization =
        TabViewCustomization()
    @AppStorage(UserDefaults.selectedBabyIdKey) private var selectedBabyId: String?

    @State private var presentingAccount = false
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house", value: .dashboard) {
                DashboardView(viewModel: viewModel, presentingAccount: $presentingAccount)
            }
            Tab("Add Entries", systemImage: "plus", value: .addEntries) {
                AddEntryView(viewModel: viewModel)
            }
            Tab("Settings", systemImage: "gear", value: .debug) {
                Settings(viewModel: viewModel)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .sheet(isPresented: $presentingAccount) {
            AccountSheet(dismissAfterSignIn: false)  // presentation was user initiated, do not automatically dismiss
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        }
        .task {
            // Start listening for changes when the app starts
            if let id = selectedBabyId {
                viewModel.startListening(babyId: id)
            }
        }
        .onChange(of: selectedBabyId) { _, newId in
            // If baby selection changes, update the listener
            viewModel.stopListening()
            if let id = newId {
                viewModel.startListening(babyId: id)
            }
        }
    }
}

#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return HomeView()
        .previewWith(standard: FeedbridgeStandard()) {
            FeedbridgeScheduler()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
