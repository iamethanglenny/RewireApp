import SwiftUI

struct TrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDailyCheckIn = false
    @State private var showingLogOverview = false
    @State private var returnToHome = false
    
    // This would be determined by checking if the user has logged their day
    // For now, we'll use a static property for demonstration
    let hasLoggedToday = false // Change to true to test the overview screen
    
    var body: some View {
        ZStack {
            // Determine which view to show based on whether the user has logged their day
            if hasLoggedToday {
                if showingLogOverview {
                    DailyLogOverviewView()
                        .onDisappear {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            } else {
                if showingDailyCheckIn {
                    DailyCheckInView(isPresented: $showingDailyCheckIn, returnToHome: $returnToHome)
                        .onDisappear {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
            }
        }
        .onAppear {
            // Show the appropriate view when this view appears
            if hasLoggedToday {
                showingLogOverview = true
            } else {
                showingDailyCheckIn = true
            }
        }
        .onChange(of: returnToHome) { _, newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
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
