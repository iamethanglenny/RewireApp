import SwiftUI

struct RecoveryTimelineCard: View {
    let dayRange: String
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.white.opacity(0.3))
                    .frame(width: 20, height: 20)
                
                Text(dayRange)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .green : .white)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct RecoveryTimelineCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            RecoveryTimelineCard(
                dayRange: "Days 1-3",
                title: "Nicotine Withdrawal",
                description: "Your body is clearing out nicotine and adjusting to its absence. You may experience cravings, irritability, and headaches.",
                isCompleted: true
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 