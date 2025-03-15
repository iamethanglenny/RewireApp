import SwiftUI
// Import the shared TimePeriod enum
// Note: After adding the Shared directory to your Xcode project, you may need to adjust this import

struct RewiringView: View {
    // State to track which time period is selected
    @State private var selectedPeriod: TimePeriod = .week
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed header at the top
                HeaderView()
                    .padding(.bottom, 10)
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Add some spacing at the top
                        Spacer().frame(height: 10)
                        
                        // Content cards
                        ContentCardsView(selectedPeriod: $selectedPeriod)
                        
                        // Add some spacing at the bottom for better scrolling experience
                        Spacer().frame(height: 30)
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
    }
}

// Header view component
struct HeaderView: View {
    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Content cards view component - simplified without position calculations
struct ContentCardsView: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        VStack(spacing: 20) {
            // Graph card
            GraphCardView(
                selectedPeriod: $selectedPeriod
            )
            
            // Recovery Timeline section
            RecoveryTimelineView(
                width: UIScreen.main.bounds.width - 50,
                contentWidth: UIScreen.main.bounds.width - 70
            )
            
            // Community section - moved above Craving Reports
            CommunityView(
                width: UIScreen.main.bounds.width - 50,
                contentWidth: UIScreen.main.bounds.width - 70
            )
            
            // Craving Reports section - now after Community
            CravingReportsView(
                width: UIScreen.main.bounds.width - 50,
                contentWidth: UIScreen.main.bounds.width - 70
            )
        }
    }
}

// Graph card view component - simplified
struct GraphCardView: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        ZStack {
            // Outer rounded rectangle
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .frame(width: UIScreen.main.bounds.width - 50, height: 200)
            
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
            .frame(width: UIScreen.main.bounds.width - 70, alignment: .leading)
        }
        .frame(height: 200)
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
            Color.black.ignoresSafeArea()
            RecoveryTimelineCard(
                dayRange: "Days 1-3",
                title: "Nicotine Withdrawal",
                description: "Your body is clearing out nicotine and adjusting to its absence. You may experience cravings, irritability, and headaches.",
                isCompleted: true
            )
            .frame(width: 130, height: 130)
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 
