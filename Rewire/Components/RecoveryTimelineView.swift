import SwiftUI

struct RecoveryTimelineView: View {
    let width: CGFloat
    let contentWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Outer rounded rectangle (reverted to original)
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                .frame(width: width, height: 220)
            
            // Content inside the rectangle
            VStack(alignment: .leading, spacing: 2) {
                // Header
                Text("Recovery Timeline")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Subtitle
                Text("You are on track to complete your fourth rewiring cycle change, congratulations!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
                
                // Carousel for cards
                TimelineCardsCarousel()
                    .padding(.top, 8)
            }
            .padding(15)
            .frame(width: contentWidth, alignment: .leading)
        }
        .frame(height: 220)
    }
}

// Timeline cards carousel component
struct TimelineCardsCarousel: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // Placeholder for cards (130x130)
                ForEach(0..<5) { index in
                    RecoveryTimelineCard(
                        dayRange: "Days \(index*3+1)-\(index*3+3)",
                        title: "Recovery Stage \(index+1)",
                        description: "Description for recovery stage \(index+1). This is a placeholder text.",
                        isCompleted: index < 2
                    )
                    .frame(width: 130, height: 130)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 20)
        }
    }
}

// Preview for the RecoveryTimelineView
struct RecoveryTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RecoveryTimelineView(
                width: 350,
                contentWidth: 330
            )
        }
        .previewLayout(.sizeThatFits)
    }
} 