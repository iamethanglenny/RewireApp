import SwiftUI

struct ActionButtonView: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ActionButtonView(
                title: "track your day",
                iconName: "calendar",
                action: {}
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 