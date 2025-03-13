import SwiftUI

struct RewiringView: View {
    // State to track which time period is selected
    @State private var selectedPeriod: TimePeriod = .week
    
    var body: some View {
        MainContentView(selectedPeriod: $selectedPeriod)
    }
}

// Extracted main content view to simplify the main view
struct MainContentView: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
            
            // Top elements in their own VStack
            HeaderView()
            
            // Main content in a VStack with fixed positioning
            ContentCardsView(selectedPeriod: $selectedPeriod)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// Content cards view component
struct ContentCardsView: View {
    @Binding var selectedPeriod: TimePeriod
    
    // Calculate the vertical position once
    private var verticalPosition: CGFloat {
        // Break down the calculation into smaller parts
        let headerHeight: CGFloat = 8 + 24 + 20 + 8 + 26
        let spacing: CGFloat = 30
        let offset: CGFloat = 100
        let cardHeight: CGFloat = 210 / 2
        
        return headerHeight + spacing + offset + cardHeight
    }
    
    var body: some View {
        GeometryReader { mainGeometry in
            VStack(spacing: 20) {
                // Graph card
                GraphCardView(
                    width: mainGeometry.size.width - 50,
                    contentWidth: mainGeometry.size.width - 70,
                    selectedPeriod: $selectedPeriod
                )
                
                // Recovery Timeline section - now using the component
                RecoveryTimelineView(
                    width: mainGeometry.size.width - 50,
                    contentWidth: mainGeometry.size.width - 70
                )
            }
            .position(
                x: mainGeometry.size.width / 2,
                y: verticalPosition // Use the pre-calculated position
            )
        }
    }
}

// Graph card view component
struct GraphCardView: View {
    let width: CGFloat
    let contentWidth: CGFloat
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        ZStack {
            // Outer rounded rectangle
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .frame(width: width, height: 200)
            
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
            .frame(width: contentWidth, alignment: .leading)
        }
        .frame(height: 200)
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
