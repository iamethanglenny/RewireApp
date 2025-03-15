import SwiftUI

// You can also add this line to be explicit about using SwiftUI's ProgressView
typealias ProgressViewType = SwiftUI.ProgressView<EmptyView, EmptyView>

struct ChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedChallenge: Challenge? = nil
    
    let challenges = [
        Challenge(id: 1, title: "7-Day Meditation", description: "Meditate for at least 10 minutes every day for a week", difficulty: "Easy", daysToComplete: 7, progress: 0.3),
        Challenge(id: 2, title: "Journal Daily", description: "Write in your journal every day for 14 days", difficulty: "Medium", daysToComplete: 14, progress: 0.5),
        Challenge(id: 3, title: "30-Day Clean Streak", description: "Maintain a clean streak for 30 days", difficulty: "Hard", daysToComplete: 30, progress: 0.2),
        Challenge(id: 4, title: "Exercise Routine", description: "Exercise for at least 20 minutes 3 times a week", difficulty: "Medium", daysToComplete: 21, progress: 0.7),
        Challenge(id: 5, title: "Mindfulness Practice", description: "Practice mindfulness techniques daily for 10 days", difficulty: "Easy", daysToComplete: 10, progress: 0.0)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedChallenge = selectedChallenge {
                    // Challenge detail view
                    ChallengeDetailView(challenge: selectedChallenge, onBack: {
                        self.selectedChallenge = nil
                    })
                } else {
                    // Challenge list view
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Complete challenges to build healthy habits and stay on track with your recovery journey.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Active challenges section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Active Challenges")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ForEach(challenges.filter { $0.progress > 0.0 }, id: \.id) { challenge in
                                    ChallengeCard(challenge: challenge)
                                        .onTapGesture {
                                            selectedChallenge = challenge
                                        }
                                }
                            }
                            
                            // Available challenges section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Available Challenges")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ForEach(challenges.filter { $0.progress == 0.0 }, id: \.id) { challenge in
                                    ChallengeCard(challenge: challenge)
                                        .onTapGesture {
                                            selectedChallenge = challenge
                                        }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitle("Challenges", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                if selectedChallenge != nil {
                    selectedChallenge = nil
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        }
    }
}

struct Challenge: Identifiable {
    let id: Int
    let title: String
    let description: String
    let difficulty: String
    let daysToComplete: Int
    let progress: Double
}

struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(challenge.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(challenge.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(challenge.difficulty).opacity(0.2))
                        .foregroundColor(difficultyColor(challenge.difficulty))
                        .cornerRadius(10)
                }
                
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("\(challenge.daysToComplete) days")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if challenge.progress > 0 {
                        Text("\(Int(challenge.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if challenge.progress > 0 {
                    SwiftUI.ProgressView(value: challenge.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy":
            return .green
        case "Medium":
            return .orange
        case "Hard":
            return .red
        default:
            return .blue
        }
    }
}

struct ChallengeDetailView: View {
    let challenge: Challenge
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Challenge header
                VStack(alignment: .leading, spacing: 10) {
                    Text(challenge.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(challenge.difficulty)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(difficultyColor(challenge.difficulty).opacity(0.2))
                            .foregroundColor(difficultyColor(challenge.difficulty))
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        Text("\(challenge.daysToComplete) days")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Progress section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress")
                        .font(.headline)
                    
                    SwiftUI.ProgressView(value: challenge.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    
                    HStack {
                        Text("\(Int(challenge.progress * 100))% Complete")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("\(Int(challenge.progress * Double(challenge.daysToComplete)))/\(challenge.daysToComplete) days")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Description section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(challenge.description)
                        .font(.body)
                    
                    Text("This challenge helps you build consistency and discipline in your recovery journey. Completing it will strengthen your resolve and provide a sense of accomplishment.")
                        .font(.body)
                        .padding(.top, 5)
                }
                .padding()
                
                // Tips section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tips for Success")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TipRow(icon: "alarm", text: "Set a daily reminder")
                        TipRow(icon: "calendar", text: "Schedule it at the same time each day")
                        TipRow(icon: "person.2", text: "Find an accountability partner")
                        TipRow(icon: "star", text: "Reward yourself for consistency")
                    }
                }
                .padding()
                
                // Action button
                Button(action: {
                    // Start or continue challenge
                }) {
                    Text(challenge.progress > 0 ? "Continue Challenge" : "Start Challenge")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy":
            return .green
        case "Medium":
            return .orange
        case "Hard":
            return .red
        default:
            return .blue
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct ChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeView()
    }
} 