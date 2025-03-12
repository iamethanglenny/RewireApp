import SwiftUI

struct RewiringView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundTop"), Color("BackgroundBottom")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Top navigation bar
                HStack {
                    Text("REWIRING")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for GET PRO button
                    }) {
                        Text("GET PRO")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Your Brain Recovery")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Recovery timeline cards
                        RecoveryTimelineCard(
                            dayRange: "Days 1-3",
                            title: "Nicotine Withdrawal",
                            description: "Your body is clearing out nicotine and adjusting to its absence. You may experience cravings, irritability, and headaches.",
                            isCompleted: true
                        )
                        
                        RecoveryTimelineCard(
                            dayRange: "Days 4-10",
                            title: "Brain Fog Clearing",
                            description: "Acetylcholine receptors are beginning to return to normal. Mental clarity starts to improve.",
                            isCompleted: true
                        )
                        
                        RecoveryTimelineCard(
                            dayRange: "Days 11-30",
                            title: "Dopamine Rebalancing",
                            description: "Your brain's reward system is starting to normalize. Natural pleasures become more satisfying.",
                            isCompleted: false
                        )
                        
                        RecoveryTimelineCard(
                            dayRange: "Days 31-90",
                            title: "Neural Pathway Rewiring",
                            description: "New habits are forming. The brain is creating healthier connections not associated with vaping.",
                            isCompleted: false
                        )
                        
                        RecoveryTimelineCard(
                            dayRange: "Days 91+",
                            title: "Long-term Recovery",
                            description: "Risk of relapse significantly decreases. Your brain has largely adapted to life without nicotine.",
                            isCompleted: false
                        )
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}



// Preview provider for RewiringView
struct RewiringView_Previews: PreviewProvider {
    static var previews: some View {
        RewiringView()
    }
}

// Preview provider for RecoveryTimelineCard
struct RecoveryTimelineCardPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            RecoveryTimelineCard(
                dayRange: "Days 1-3",
                title: "Nicotine Withdrawal",
                description: "Your body is clearing out nicotine and adjusting to its absence. You may experience cravings, irritability, and headaches.",
                isCompleted: true
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 
