import Charts
import SpeziAccount
import SwiftUI

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
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    mainContent
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
    
    @ViewBuilder private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let baby {
                    WeightsSummaryView(entries: baby.weightEntries.weightEntries)
                    FeedsSummaryView(entries: baby.feedEntries.feedEntries)
                    WetDiapersSummaryView(entries: baby.wetDiaperEntries.wetDiaperEntries)
                    StoolsSummaryView(entries: baby.stoolEntries.stoolEntries)
                }
            }
            .padding()
        }
    }
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

// Define the enum for chart types
enum ChartType: Identifiable {
    case weight
    case dehydration
    case feed
    
    var id: String {
        switch self {
        case .weight: return "weight"
        case .dehydration: return "dehydration"
        case .feed: return "feed"
        }
    }
}
