import SwiftUI

struct RatingPill: View {
    let rating: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Unfilled portion (now at the top)
                Rectangle()
                    .fill(color.opacity(0.25))
                    .frame(height: geometry.size.height * (1.0 - CGFloat(rating) / 5.0))
                
                // Filled portion (now at the bottom)
                Rectangle()
                    .fill(color)
                    .frame(height: geometry.size.height * CGFloat(rating) / 5.0)
            }
            .cornerRadius(4)
        }
    }
} 