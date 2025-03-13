import SwiftUI

struct CravingReportsView: View {
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
                Text("Craving Reports")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // Subtitle with highlighted percentage
                HStack(spacing: 0) {
                    Text("Your daily average Cravings is down 45% since you installed Rewire.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
                
                // Carousel for cards
                CravingReportsCarousel()
                    .padding(.top, 8)
            }
            .padding(15)
            .frame(width: contentWidth, alignment: .leading)
        }
        .frame(height: 220)
    }
}

// Craving reports carousel component
struct CravingReportsCarousel: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // First card - Last Week
                CravingReportCard(
                    subtitle: "Last Week",
                    percentageChange: "48% decrease",
                    isDecrease: true,
                    index: 0
                )
                .frame(width: 130, height: 130)
                
                // Second card - Previous week with date
                CravingReportCard(
                    subtitle: "23 Feb 2025",
                    percentageChange: "24% decrease",
                    isDecrease: true,
                    index: 1
                )
                .frame(width: 130, height: 130)
                
                // Additional placeholder cards
                ForEach(0..<3) { index in
                    CravingReportCard(
                        subtitle: "Previous Week \(index + 3)",
                        percentageChange: "\(10 + index * 5)% decrease",
                        isDecrease: true,
                        index: index + 2
                    )
                    .frame(width: 130, height: 130)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 20)
        }
    }
}

// Preview for the CravingReportsView
struct CravingReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CravingReportsView(
                width: 350,
                contentWidth: 330
            )
        }
        .previewLayout(.sizeThatFits)
    }
} 