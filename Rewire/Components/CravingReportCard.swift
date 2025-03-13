import SwiftUI

struct CravingReportCard: View {
    let subtitle: String
    let percentageChange: String
    let isDecrease: Bool
    let index: Int
    
    // Array of gradient configurations
    private let gradients: [(colors: [Color], start: UnitPoint, end: UnitPoint)] = [
        // Blue gradient (original)
        (
            colors: [Color(hex: "1A1A1A"), Color(hex: "1141B9"), Color(hex: "93ADEF")],
            start: UnitPoint(x: 0.5, y: 0.9),
            end: UnitPoint(x: 0.7, y: 0.2)
        ),
        // Purple gradient
        (
            colors: [Color(hex: "1A1A1A"), Color(hex: "6B11B9"), Color(hex: "C393EF")],
            start: UnitPoint(x: 0.5, y: 0.9),
            end: UnitPoint(x: 0.7, y: 0.2)
        ),
        // Green gradient
        (
            colors: [Color(hex: "1A1A1A"), Color(hex: "11B957"), Color(hex: "93EFC3")],
            start: UnitPoint(x: 0.5, y: 0.9),
            end: UnitPoint(x: 0.7, y: 0.2)
        ),
        // Orange gradient
        (
            colors: [Color(hex: "1A1A1A"), Color(hex: "B95711"), Color(hex: "EFC393")],
            start: UnitPoint(x: 0.5, y: 0.9),
            end: UnitPoint(x: 0.7, y: 0.2)
        ),
        // Teal gradient
        (
            colors: [Color(hex: "1A1A1A"), Color(hex: "11B9B9"), Color(hex: "93EFEF")],
            start: UnitPoint(x: 0.5, y: 0.9),
            end: UnitPoint(x: 0.7, y: 0.2)
        )
    ]
    
    // Get the gradient for this card based on index
    private var cardGradient: (colors: [Color], start: UnitPoint, end: UnitPoint) {
        let safeIndex = abs(index) % gradients.count
        return gradients[safeIndex]
    }
    
    // Get the accent color for the shadow and border
    private var accentColor: Color {
        return cardGradient.colors[1]
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            // Title
            Text("CRAVING REPORT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 5)
            
            // Subtitle (date or "Last Week")
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
            
            Spacer()
            
            // Percentage change
            HStack(spacing: 2) {
                Image(systemName: isDecrease ? "arrow.down" : "arrow.up")
                    .font(.system(size: 9))
                    .foregroundColor(Color("20FF5F"))
                
                Text(percentageChange)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color("20FF5F"))
            }
            
            // OPEN button
            Button(action: {
                // Action to open the report
            }) {
                Text("OPEN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 24)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "555555"),
                                Color(hex: "333333")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2),
                                        Color.black.opacity(0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(4)
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: cardGradient.colors,
                        startPoint: cardGradient.start,
                        endPoint: cardGradient.end
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            accentColor.opacity(0.5),
                            Color.white.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: accentColor.opacity(0.3),
            radius: 4,
            x: 0,
            y: 2
        )
    }
}

// Preview provider for CravingReportCard
struct CravingReportCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                // Preview multiple cards with different gradients
                ForEach(0..<5) { i in
                    CravingReportCard(
                        subtitle: "Card \(i+1)",
                        percentageChange: "\(10 + i * 10)% decrease",
                        isDecrease: true,
                        index: i
                    )
                    .frame(width: 130, height: 130)
                }
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 
