import SwiftUI

struct ProgressBarView: View {
    let progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 10)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ProgressBarView(progress: 0.12)
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 