//
// This source file is part of the Feedbridge based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct Welcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    var body: some View {
        OnboardingView(
            title: "Feedbridge",
            subtitle: "WELCOME_SUBTITLE",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "heart.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Monitor Your Baby",
                    description: "WELCOME_AREA1_DESCRIPTION"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .accessibilityHidden(true)
                    },
                    title: "Track Progress",
                    description: "WELCOME_AREA2_DESCRIPTION"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "bell.badge.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Early Alerts",
                    description: "WELCOME_AREA3_DESCRIPTION"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "person.3.fill")
                            .accessibilityHidden(true)
                    },
                    title: "About Us",
                    description: "WELCOME_AREA4_DESCRIPTION"
                )
            ],
            actionText: "Get Started",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
            .padding(.top, 24)
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        Welcome()
    }
}
#endif
