import Charts
import SpeziAccount
import SwiftUI

// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct DashboardView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(FeedbridgeStandard.self) private var standard
    @Binding var presentingAccount: Bool
    
    @State private var babies: [Baby] = []
    @State private var selectedBabyId: String?
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
                await loadBabies()
                await loadBaby()
            }
        }
    }
    
    @ViewBuilder private var mainContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                babyPicker
                if let baby {
                    WeightsSummaryView(entries: baby.weightEntries.weightEntries)
                    StoolChart(entries: baby.stoolEntries.stoolEntries)
                    FeedChart(entries: baby.feedEntries.feedEntries)
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder private var babyPicker: some View {
        Menu {
            ForEach(babies) { baby in
                Button {
                    selectedBabyId = baby.id
                    UserDefaults.standard.selectedBabyId = baby.id
                } label: {
                    HStack {
                        Text(baby.name)
                        Spacer()
                        if baby.id == selectedBabyId {
                            Image(systemName: "checkmark")
                                .accessibilityLabel("Selected")
                        }
                    }
                }
            }
            Divider()
            NavigationLink("Add New Baby") {
                AddSingleBabyView(onSave: {
                    Task {
                        await loadBabies()
                    }
                })
            }
        } label: {
            HStack {
                Image(systemName: "person.crop.circle")
                    .accessibilityLabel("Baby icon")
                Text(babies.first(where: { $0.id == selectedBabyId })?.name ?? "Select Baby")
                Image(systemName: "chevron.down")
                    .accessibilityLabel("Menu dropdown")
            }
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 2)
        }
    }
    
    struct WeightChart: View {
        let entries: [WeightEntry]
        
        var body: some View {
            Chart {
                ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                    let day = Calendar.current.startOfDay(for: entry.dateTime)
                    LineMark(
                        x: .value("Date", day),
                        y: .value("Weight (kg)", entry.asKilograms.value)
                    )
                    .foregroundStyle(.orange)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { plotArea in
                plotArea.background(Color.clear)
            }
        }
    }

    
    struct WeightsSummaryView: View {
        let entries: [WeightEntry]

        // Get the most recent weight entry if it exists.
        private var lastEntry: WeightEntry? {
            entries.sorted(by: { $0.dateTime > $1.dateTime }).first
        }

        // Format the date/time of the last entry.
        private var formattedTime: String {
            guard let date = lastEntry?.dateTime else { return "" }
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }

        var body: some View {
            NavigationLink(destination: WeightsView(entries: entries)) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .opacity(0.8)

                    VStack {
                        // Header with icon and title
                        HStack {
                            Image(systemName: "scalemass")
                                .accessibilityLabel("Scale")
                                .font(.title3)
                                .foregroundColor(.orange)

                            Text("Weights")
                                .font(.title3.bold())
                                .foregroundColor(.orange)

                            Spacer()
                        }
                        .padding()

                        // Content
                        if let entry = lastEntry {
                            Spacer()
                            
                            HStack {
                                Text("\(entry.asKilograms.value, specifier: "%.2f") kg")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                Spacer()
                                MiniWeightChart(entries: entries)
                                    .frame(width: 60, height: 40)
                                    .opacity(0.5)
                            }
                            .padding([.bottom, .horizontal])
                        } else {
                            Text("No data added")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
                .frame(height: 120)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    struct MiniWeightChart: View {
        let entries: [WeightEntry]

        var body: some View {
            WeightChart(entries: entries)
                .frame(width: 60, height: 40) // Small version
                .opacity(0.5)
        }
    }


    
    /// Represents the average weight for a specific date
    struct DailyAverageWeight: Identifiable {
        let id = UUID()
        let date: Date
        let averageWeight: Double
    }
    
    struct StoolChart: View {
        let entries: [StoolEntry]

        var body: some View {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .opacity(0.8)

                    VStack {
                        HStack {
                            Image(systemName: "plus.circle.fill")                   .accessibilityLabel("Circle with plus")
                                .font(.title3)
                                .foregroundColor(.cyan)
                                .padding(.leading, 8)

                            Text("Stools")
                                .font(.title3.bold())
                                .foregroundColor(.cyan)
                            
                            Spacer() // Ensures left alignment
                        }
                        .padding()

                        if entries.isEmpty {
                            Text("No data added")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                        }
//                            .frame(height: 170)
//                            .padding()
                    }
                }
            }
        }
    }
    
    struct FeedChart: View {
        let entries: [FeedEntry]

        var body: some View {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .opacity(0.8)

                    VStack {
                        HStack {
                            Image(systemName: "flame.fill")                   .accessibilityLabel("Flame")
                                .font(.title3)
                                .foregroundColor(.pink)
                                .padding(.leading, 8)

                            Text("Feeds")
                                .font(.title3.bold())
                                .foregroundColor(.pink)
                            
                            Spacer() // Ensures left alignment
                        }
                        .padding()

                        if entries.isEmpty {
                            Text("No data added")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                        }
//                            .frame(height: 170)
//                            .padding()
                    }
                }
            }
        }
    }

    private func loadBabies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            babies = try await standard.getBabies()
            if let savedId = UserDefaults.standard.selectedBabyId,
               babies.contains(where: { $0.id == savedId }) {
                selectedBabyId = savedId
            } else {
                selectedBabyId = babies.first?.id
                UserDefaults.standard.selectedBabyId = selectedBabyId
            }
        } catch {
            errorMessage = "Failed to load babies: \(error.localizedDescription)"
        }
        
        isLoading = false
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
