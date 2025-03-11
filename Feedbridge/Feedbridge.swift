//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI

@main
struct Feedbridge: App {
    @UIApplicationDelegateAdaptor(FeedbridgeDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView()
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: !$completedOnboardingFlow) {
                OnboardingFlow()
            }
            .testingSetup()
            .spezi(appDelegate)
        }
    }
}
