import SwiftUI

struct ProgressBarView: View {
    let progress: CGFloat
    
    var body: some View {
        HStack(spacing: 10) {  // Use HStack with explicit spacing
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "20FF5F"))
                        .frame(width: geometry.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, alignment: .leading)  // Fixed width for consistency
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ProgressBarView(progress: 0.12)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 