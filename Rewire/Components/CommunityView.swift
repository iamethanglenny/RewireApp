import SwiftUI

struct CommunityView: View {
    let width: CGFloat
    let contentWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Outer rounded rectangle with adjusted height
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .frame(width: width, height: 160)
            
            // Content inside the rectangle with proper padding and spacing
            VStack(alignment: .leading, spacing: 2) {
                // Add space at the top to match CravingReportsView
                Spacer().frame(height: 25)
                
                // Header
                Text("Community")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Subtitle with same spacing as CravingReportsView
                Text("Your cravings were 53% lower than your peers yesterday. Keep up the great work!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                
                // Spectrum Graph with user positioning
                SpectrumComparisonView(contentWidth: contentWidth - 20)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                
                Spacer() // Push content to the top
            }
            .padding(15) // Same padding as CravingReportsView
            .frame(width: contentWidth, alignment: .leading)
        }
        .frame(height: 160)
    }
}

// Preference key to capture content height
struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Custom view for the spectrum comparison
struct SpectrumComparisonView: View {
    let contentWidth: CGFloat
    
    // User's position on the spectrum (0.0 to 1.0)
    let userPosition: CGFloat = 0.25
    
    // Peer average position on the spectrum (0.0 to 1.0)
    let peerPosition: CGFloat = 0.75
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Base spectrum graph
            Image("spectrumGraph")
                .resizable()
                .scaledToFit()
                .frame(width: contentWidth)
                .padding(.top, 25) // Reduced top padding
            
            // User marker with vertical line
            VStack(spacing: 1) { // Reduced spacing
                // User craving count
                Text("14x")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "20FF5F"))
                
                // Vertical line
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 2, height: 5)
                
                // Home icon from assets
                Image("homeIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18) // Slightly smaller
                
                // "YOU" label
                Text("YOU")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "20FF5F"))
            }
            .frame(width: 40)
            .offset(x: contentWidth * userPosition - 20, y: 3) // Adjusted position
            
            // Peer average marker with vertical line
            VStack(spacing: 1) { // Reduced spacing
                // Peer average craving count
                Text("27x")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                
                // Vertical line
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 2, height: 5)
                
                // Spacer to replace the icon
                Spacer()
                    .frame(height: 18) // Match home icon height
                
                // Peer age group label
                Text("18 - 24 Avg")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.orange)
            }
            .frame(width: 70)
            .offset(x: contentWidth * peerPosition - 35, y: 3) // Adjusted position
        }
        .frame(width: contentWidth, height: 80) // Further reduced height
    }
}

// Preview for the CommunityView
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CommunityView(
                width: 350,
                contentWidth: 330
            )
        }
        .previewLayout(.sizeThatFits)
    }
} 
