import SwiftUI

struct RewiringView: View {
    // State to track which time period is selected
    @State private var selectedPeriod: TimePeriod = .week
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Top elements in their own VStack
            VStack(alignment: .leading, spacing: 4) {
                Text("REWIRING")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("insights & stats")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("top 42%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.green)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .padding(.top, 2)
            }
            .padding(.top, 8)
            .padding(.leading, 25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // Calculate position to be 30px below the green rectangle
            GeometryReader { geometry in
                ZStack {
                    // Outer rounded rectangle - increased width to match top content
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        .frame(width: geometry.size.width - 50, height: 200)
                    
                    // Use the reusable component
                    RewiringGraphCard(
                        selectedPeriod: $selectedPeriod,
                        dataPoints: [20, 40, 30, 60, 25, 45, 35],
                        averageTime: "2hrs, 22 mins",
                        subtitle: "Avg Craving Intervals",
                        timeRange: "last 7 days",
                        onPreviousPeriod: {
                            // Handle previous period
                        },
                        onNextPeriod: {
                            // Handle next period
                        }
                    )
                    .frame(width: geometry.size.width - 70, alignment: .leading)
                }
                .position(
                    x: geometry.size.width / 2,
                    y: 8 + 24 + 20 + 8 + 26 + 30 + 100
                )
            }
        }
    }
}

// Time period enum moved to a shared location
enum TimePeriod: String, CaseIterable {
    case week = "week"
    case month = "month"
    case lifetime = "lifetime"
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
