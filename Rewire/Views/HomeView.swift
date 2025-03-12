import SwiftUI

struct HomeView: View {
    // Sample data - in a real app, this would come from a model
    let daysSinceQuitting = 12
    let moneySaved = 452.23
    let lifeReclaimed = "2 yrs"
    let progressPercentage: CGFloat = 0.12
    
    var body: some View {
        ZStack {
            // Background color - solid black
            Color.black
                .ignoresSafeArea()
            
            // Background image - top 50% of screen
            VStack {
                Image("homeBackground")
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
                            
                            Spacer() // This pushes content up from the bottom
                        }
                        .frame(height: geometry.size.height * 0.5)
                        
                        // Bottom half content - starts exactly at 50% mark
                        VStack(spacing: 20) {
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
                            .padding(.top, 30)
                            
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
                            
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.5)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
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
