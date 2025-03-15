import SwiftUI
// Import the shared TimePeriod enum
// Note: After adding the Shared directory to your Xcode project, you may need to adjust this import

struct RewiringGraphCard: View {
    @Binding var selectedPeriod: TimePeriod
    let dataPoints: [CGFloat]
    let averageTime: String
    let subtitle: String
    let timeRange: String
    var onPreviousPeriod: () -> Void = {}
    var onNextPeriod: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            // Time period selector - left aligned
            HStack(spacing: 10) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    PeriodSelectorButton(period: period, selectedPeriod: $selectedPeriod)
                }
            }
            
            // Average time display - left aligned
            Text(averageTime)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 5)
            
            // Subtitle - left aligned
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            // Line graph - full width
            LineGraphView(dataPoints: dataPoints)
                .frame(height: 60)
                .padding(.top, 10)
            
            // Spacer to push time navigator down by 3px
            Spacer().frame(height: 3)
            
            // Time period navigation - centered with rounded rectangle border
            HStack {
                Button(action: onPreviousPeriod) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10)) // Smaller arrow size
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(timeRange)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Button(action: onNextPeriod) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10)) // Smaller arrow size
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .padding(.top, 10)
        }
        .padding(10)
    }
}

// Period selector button component
struct PeriodSelectorButton: View {
    let period: TimePeriod
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        Text(period.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(selectedPeriod == period ? Color.white : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(selectedPeriod == period ? 1.0 : 0.5), lineWidth: 1)
                    .opacity(selectedPeriod == period ? 0 : 1) // Only show stroke for unselected
            )
            .foregroundColor(selectedPeriod == period ? Color.black : Color.white.opacity(0.7))
            .onTapGesture {
                selectedPeriod = period
            }
    }
}

// Preview for the RewiringGraphCard
struct RewiringGraphCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            RewiringGraphCard(
                selectedPeriod: .constant(.week),
                dataPoints: [20, 40, 30, 60, 25, 45, 35],
                averageTime: "2hrs, 22 mins",
                subtitle: "Avg Craving Intervals",
                timeRange: "last 7 days"
            )
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    .frame(width: 350, height: 200)
            )
        }
    }
} 