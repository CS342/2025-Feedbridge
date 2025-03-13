//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziHealthKit
import SpeziNotifications
import SpeziOnboarding
import SwiftUI

/// Displays an multi-step onboarding flow for the Feedbridge.
struct OnboardingFlow: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.notificationSettings) private var notificationSettings

    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false

    @State private var localNotificationAuthorization = false

    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()

            if !FeatureFlags.disableFirebase {
                AccountOnboarding()
            }

            #if !(targetEnvironment(simulator) && (arch(i386) || arch(x86_64)))
            Consent()
            #endif

            AddBabyView()
        }
        .interactiveDismissDisabled(!completedOnboardingFlow)
        .onChange(of: scenePhase, initial: true) {
            guard case .active = scenePhase else {
                return
            }

            Task {
                localNotificationAuthorization =
                    await notificationSettings().authorizationStatus == .authorized
            }
        }
    }
}

#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: FeedbridgeStandard()) {
            OnboardingDataSource()
            HealthKit()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
