import SwiftUI

@main
struct DiaryApp: App {
    @StateObject private var diaryModel = DiaryModel()
    @StateObject private var rewardsModel = RewardsModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(diaryModel)
                .environmentObject(rewardsModel)
        }
    }
}

// MARK: - Models
class DiaryModel: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    
    func addEntry(_ entry: DiaryEntry) {
        entries.append(entry)
    }
}

struct DiaryEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let text: String
}

class RewardsModel: ObservableObject {
    @Published var points: Int = 0
    @Published var streak: Int = 0
    
    func addPoints(for entry: DiaryEntry) {
        points += 10
        streak += 1
    }
}

// MARK: - Views
struct ContentView: View {
    @EnvironmentObject var diaryModel: DiaryModel
    @EnvironmentObject var rewardsModel: RewardsModel
    @State private var newEntryText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(diaryModel.entries.sorted(by: { $0.date > $1.date })) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.date, style: .date)
                                .font(.headline)
                            Text(entry.text)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                VStack {
                    TextEditor(text: $newEntryText)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                        .padding(.horizontal)
                    
                    Button(action: addEntry) {
                        Text("Add Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("My Diary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    RewardsView()
                }
            }
        }
    }
    
    private func addEntry() {
        guard !newEntryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let entry = DiaryEntry(date: Date(), text: newEntryText)
        diaryModel.addEntry(entry)
        rewardsModel.addPoints(for: entry)
        newEntryText = ""
    }
}

// MARK: - Rewards
struct RewardsView: View {
    @EnvironmentObject var rewardsModel: RewardsModel
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Points: \(rewardsModel.points)")
                .font(.caption)
            Text("Streak: \(rewardsModel.streak) days")
                .font(.caption2)
        }
    }
}

