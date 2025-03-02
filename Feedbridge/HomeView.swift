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
//        case addBabies
//        case schedule
//        case contact
    }


    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.dashboard
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var presentingAccount = false

    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house", value: .dashboard) {
                DashboardView(presentingAccount: $presentingAccount)
            }
            Tab("Add Entries", systemImage: "plus", value: .addEntries) {
                AddDataView(presentingAccount: $presentingAccount)
            }
            Tab("Baby Debug View", systemImage: "figure.2.and.child.holdinghands", value: .debug) {
                BabyDebugDisplayView()
            }
//            Tab("Add Babies", systemImage: "figure.2.and.child.holdinghands", value: .addBabies) {
//                AddBabyView()
//            }
//            Tab("Schedule", systemImage: "list.clipboard", value: .schedule) {
//                ScheduleView(presentingAccount: $presentingAccount)
//            }
//                .customizationID("home.schedule")
//            Tab("Contacts", systemImage: "person.fill", value: .contact) {
//                Contacts(presentingAccount: $presentingAccount)
//            }
//                .customizationID("home.contacts")
        }
            .tabViewStyle(.sidebarAdaptable)
            .tabViewCustomization($tabViewCustomization)
            .sheet(isPresented: $presentingAccount) {
                AccountSheet(dismissAfterSignIn: false) // presentation was user initiated, do not automatically dismiss
            }
            .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
                AccountSheet()
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
