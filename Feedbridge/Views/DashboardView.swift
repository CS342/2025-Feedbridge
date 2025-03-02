import Charts
import SpeziAccount
import SwiftUI

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
                Text("Weight")
                    .font(.headline)
                    .padding(.top)
                
                if entries.isEmpty {
                    Text("No data added")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .frame(height: 220)
                            .shadow(radius: 4)

                        Chart(entries.sorted(by: { $0.dateTime < $1.dateTime })) {
                            LineMark(
                                x: .value("Date", $0.dateTime),
                                y: .value("Weight (kg)", $0.asKilograms.value)
                            )
                            .interpolationMethod(.catmullRom) // Smooth curve
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2))

                            PointMark(
                                x: .value("Date", $0.dateTime),
                                y: .value("Weight (kg)", $0.asKilograms.value)
                            )
//                            .symbol(Circle().fill(Color.blue))
                        }
                        .frame(height: 200)
                        .padding()
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
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
