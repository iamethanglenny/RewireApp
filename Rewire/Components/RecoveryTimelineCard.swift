import SwiftUI

struct RecoveryTimelineCard: View {
    let dayRange: String
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Day range
            Text(dayRange)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isCompleted ? .green : .white.opacity(0.7))
            
            // Title
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            
            // Description
            Text(description)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Completion indicator
            if isCompleted {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCompleted ? Color.green.opacity(0.7) : Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Preview provider for RecoveryTimelineCard
struct RecoveryTimelineCard_Previews: PreviewProvider {
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