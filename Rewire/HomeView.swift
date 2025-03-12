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

struct HourglassView: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hourglass outline
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    // Top triangle
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    
                    // Bottom triangle
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                
                // Filled portion (top)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                }
                .fill(Color.white.opacity(0.2))
                
                // Filled portion (bottom - represents progress)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    // Calculate how much of the bottom triangle to fill based on progress
                    let fillHeight = height / 2 * progress
                    
                    path.move(to: CGPoint(x: midX, y: height / 2))
                    
                    // Calculate points for the trapezoid
                    let ratio = fillHeight / (height / 2)
                    let leftX = midX - (midX * ratio)
                    let rightX = midX + (midX * ratio)
                    
                    path.addLine(to: CGPoint(x: leftX, y: height / 2 + fillHeight))
                    path.addLine(to: CGPoint(x: rightX, y: height / 2 + fillHeight))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                }
                .fill(Color.white)
            }
            .frame(width: min(geometry.size.width, 200))
            .frame(maxWidth: .infinity)
        }
    }
}

struct ProgressMetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(minWidth: 120)
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProgressBarView: View {
    let progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

struct ActionButtonView: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// Preview provider for HomeView
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// Preview providers for component views
struct HourglassView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            HourglassView(progress: 0.12)
                .frame(height: 300)
                .padding()
        }
    }
}

struct ProgressMetricView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ProgressMetricView(title: "Money saved", value: "$452.23")
        }
        .previewLayout(.sizeThatFits)
    }
}

struct ActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ActionButtonView(
                title: "track your day",
                iconName: "calendar",
                action: {}
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 