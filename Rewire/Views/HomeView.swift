import SwiftUI

struct HomeView: View {
    // Sample data - in a real app, this would come from a model
    let daysSinceQuitting = 12
    let moneySaved = 452.23
    let lifeReclaimed = "2 yrs"
    let progressPercentage: CGFloat = 0.12
    
    @State private var showingTrackingView = false
    @State private var showingChallengeView = false
    @State private var showingSupportView = false
    
    var body: some View {
        ZStack {
            // Background color - solid black
            Color.black
                .ignoresSafeArea()
            
            // Background image - top 50% of screen
            VStack {
                Image("homeBackground2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .clipped()
                
                Spacer()
            }
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Add space above the navigation bar
                Spacer()
                    .frame(height: 35)
                
                // Top navigation bar
                HStack {
                    Image("brandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for GET PRO button
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 8))
                            
                            Text("GET PRO")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            HStack(spacing: 3) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 8))
                                
                                Text("GET PRO")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(BrandGradient.gradient1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                    BrandGradient.gradient1,
                                    lineWidth: 1
                                )
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Content container that fills the screen
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Top half content - centered in top half
                        VStack(spacing: 0) {
                            Spacer() // This pushes content down from the top
                            
                            // Days counter with subtitle
                            VStack(spacing: 0) {
                                Text("vape-free for")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundColor(.white)
                                
                                Text("\(daysSinceQuitting) days")
                                    .font(.system(size: 70, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            .offset(y: -20)  // Move up by 20px total
                            
                            // Achievement indicator
                            Text("you're in the top 42%")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(hex: "20FF5F"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "20FF5F"), lineWidth: 1)
                                )
                                .padding(.top, 5)
                                .offset(y: -20)  // Move up by 20px total (was -10px)
                            
                            Spacer() // This pushes content up from the bottom
                        }
                        .frame(height: geometry.size.height * 0.5)
                        
                        // Bottom half content - starts exactly at 50% mark
                        VStack(spacing: 0) {
                            // Progress metrics in a 2x2 grid - no top padding
                            VStack(spacing: 15) {  // Decreased spacing from 30 to 20
                                // First row
                                HStack(spacing: 30) {
                                    ProgressMetricView(
                                        title: "💰 money saved",
                                        value: "$\(String(format: "%.2f", moneySaved))",
                                        isMoneyValue: true
                                    )
                                    
                                    ProgressMetricView(
                                        title: "🌱 life reclaimed",
                                        value: lifeReclaimed,
                                        isTimeValue: true
                                    )
                                }
                                
                                // Second row
                                HStack(spacing: 30) {
                                    ProgressMetricView(
                                        title: "🕰️ time saved",
                                        value: "5 hrs",
                                        isTimeValue: true
                                    )
                                    
                                    ProgressMetricView(
                                        title: "🎯 cravings beat",
                                        value: "62"
                                    )
                                }
                                
                                // Action buttons directly below the grid
                                HStack(spacing: 30) {
                                    CircularActionButton(
                                        iconName: "calendar",
                                        title: "track",
                                        action: { 
                                            showingTrackingView = true 
                                        }
                                    )
                                    
                                    CircularActionButton(
                                        iconName: "trophy",
                                        title: "challenge",
                                        action: { 
                                            showingChallengeView = true 
                                        }
                                    )
                                    
                                    CircularActionButton(
                                        iconName: "person.2.fill",
                                        title: "support",
                                        action: { 
                                            showingSupportView = true 
                                        }
                                    )
                                }
                                .padding(.top, 0)
                                
                                // Progress bar directly below action buttons
                                VStack(alignment: .leading) {
                                    Text("rewired by: 14th december 2025")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.bottom, 5)
                                    
                                    ProgressBarView(progress: progressPercentage)
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 0)
                            }
                            .padding(.horizontal)
                            .offset(y: -60)
                            
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.5, alignment: .top)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        
        // Add sheet presentations for the new views
        .sheet(isPresented: $showingTrackingView) {
            TrackingView()
        }
        .sheet(isPresented: $showingChallengeView) {
            ChallengeView()
        }
        .sheet(isPresented: $showingSupportView) {
            SupportView()
        }
    }
}

// Preview provider for HomeView
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

// Color extension for hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Brand gradients
enum BrandGradient {
    static let gradient1 = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "98B7FF"), location: 0.0),
            .init(color: Color(hex: "477BFF"), location: 0.52),
            .init(color: Color(hex: "0C50EF"), location: 1.0)
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // You can add more brand gradients here as needed
    // static let gradient2 = ...
}

// Circular Action Button Component
struct CircularActionButton: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
    }
} 
