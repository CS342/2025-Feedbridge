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
                    WeightChart(entries: baby.weightEntries.weightEntries)
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
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .opacity(0.8)

                    VStack {
                        HStack {
                            Image(systemName: "scalemass")                   .accessibilityLabel("Scale")
                                .font(.title3)
                                .foregroundColor(.orange)
                                .padding(.leading, 8)

                            Text("Weights")
                                .font(.title3.bold())
                                .foregroundColor(.orange)
                            
                            Spacer() // Ensures left alignment
                        }
                        .padding()

                        if entries.isEmpty {
                            Text("No data added")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            Chart {
                                let averagedEntries = averageWeightsPerDay()

                                // Plot individual weight measurements as dots (aligned per day)
                                ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                                    let day = Calendar.current.startOfDay(for: entry.dateTime)
                                    PointMark(
                                        x: .value("Date", day),
                                        y: .value("Weight (kg)", entry.asKilograms.value)
                                    )
                                    .foregroundStyle(.gray)
                                    .symbol {
                                        Circle()
                                            .fill(Color.gray.opacity(0.6))
                                            .frame(width: 8)
                                    }
                                }

                                // Trend line
                                ForEach(averagedEntries) { entry in
                                    LineMark(
                                        x: .value("Date", entry.date),
                                        y: .value("Weight (kg)", entry.averageWeight)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(.orange)
                                    .lineStyle(StrokeStyle(lineWidth: 2))
                                }
                            }
                            .frame(height: 170)
                            .padding()
                        }
                    }
                }
            }
        }

        /// Groups weights by day and calculates the average weight per day
        private func averageWeightsPerDay() -> [DailyAverageWeight] {
            let grouped = Dictionary(grouping: entries) { entry in
                Calendar.current.startOfDay(for: entry.dateTime)
            }

            return grouped.map { (date, entries) in
                let totalWeight = entries.reduce(0) { $0 + $1.asKilograms.value }
                let averageWeight = totalWeight / Double(entries.count)
                return DailyAverageWeight(date: date, averageWeight: averageWeight)
            }
            .sorted { $0.date < $1.date } // Ensure sorted order
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

//#Preview {
//    DashboardView(presentingAccount: .constant(false))
//        .previewWith(standard: FeedbridgeStandard()) {}
//}
