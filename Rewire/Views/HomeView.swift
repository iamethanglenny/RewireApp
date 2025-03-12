import SwiftUI

struct HomeView: View {
    // Sample data - in a real app, this would come from a model
    let daysSinceQuitting = 12
    let moneySaved = 452.23
    let lifeReclaimed = "2 yrs"
    let progressPercentage: CGFloat = 0.12
    
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
                    Text("REWIRE")
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
                
                Spacer()
                
                // Main content
                VStack(spacing: 25) {
                    // Days counter
                    Text("\(daysSinceQuitting) days")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Hourglass visualization
                    HourglassView(progress: progressPercentage)
                        .frame(height: 300)
                    
                    // Progress metrics
                    HStack(spacing: 20) {
                        ProgressMetricView(
                            title: "Money saved",
                            value: "$\(String(format: "%.2f", moneySaved))"
                        )
                        
                        ProgressMetricView(
                            title: "Life reclaimed",
                            value: lifeReclaimed
                        )
                    }
                    
                    // Progress bar
                    ProgressBarView(progress: progressPercentage)
                        .padding(.horizontal, 30)
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        ActionButtonView(
                            title: "track your day",
                            iconName: "calendar",
                            action: { /* Track day action */ }
                        )
                        
                        ActionButtonView(
                            title: "challenge me",
                            iconName: "trophy",
                            action: { /* Challenge action */ }
                        )
                        
                        ActionButtonView(
                            title: "get support",
                            iconName: "person.2.fill",
                            action: { /* Support action */ }
                        )
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

// Preview provider for HomeView
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
