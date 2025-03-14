import SwiftUI

struct TrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDailyCheckIn = true
    
    var body: some View {
        ZStack {
            // Show DailyCheckInView immediately
            if showingDailyCheckIn {
                DailyCheckInView(isPresented: $showingDailyCheckIn)
                    .onDisappear {
                        // When DailyCheckInView is dismissed, also dismiss TrackingView
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .onAppear {
            // Ensure DailyCheckInView is shown immediately
            showingDailyCheckIn = true
        }
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
} 
