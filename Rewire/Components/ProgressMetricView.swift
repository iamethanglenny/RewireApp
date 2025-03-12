import SwiftUI

struct ProgressMetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(minWidth: 120)
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProgressMetricView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ProgressMetricView(title: "Money saved", value: "$452.23")
        }
        .previewLayout(.sizeThatFits)
    }
} 
