import SwiftUI

struct DailyCheckInView: View {
    @Binding var isPresented: Bool
    @Binding var returnToHome: Bool
    @State private var showWellbeingForm = false
    @State private var stayedClean: Bool? = nil
    
    // Animation states for bubbles
    @State private var yesBubblePosition = CGPoint(x: 0, y: 0)
    @State private var noBubblePosition = CGPoint(x: 0, y: 0)
    @State private var yesBubbleVelocity = CGVector(dx: 0.5, dy: -0.3)
    @State private var noBubbleVelocity = CGVector(dx: -0.4, dy: 0.2)
    @State private var lastUpdateTime = Date()
    @State private var animationTimer: Timer?
    
    // Bubble sizes - YES bubble is now 1.2x larger, and NO bubble is exactly 1/3 of YES
    let yesBubbleSize: CGFloat = 150 // Increased from 125 (1.2x)
    let noBubbleSize: CGFloat = 75   // 150/3 = 50
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A1A1A"), location: 0.47),
                    .init(color: Color(hex: "1141B9"), location: 0.65),
                    .init(color: Color(hex: "93ADEF"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with Today text and exit button in-line
                ZStack {
                    // Centered text
                    Text("Today")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Right-aligned X button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // "Did you stay clean?" section
                VStack(spacing: 30) {
                    Text("Did you stay clean?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    ZStack {
                        // YES bubble
                        Button(action: {
                            stayedClean = true
                            showWellbeingForm = true
                        }) {
                            BubbleView(text: "YES", size: yesBubbleSize)
                        }
                        .position(x: UIScreen.main.bounds.width/2 + yesBubblePosition.x - 50, 
                                  y: yesBubblePosition.y + 100)
                        
                        // NO bubble
                        Button(action: {
                            stayedClean = false
                            showWellbeingForm = true
                        }) {
                            BubbleView(text: "NO", size: noBubbleSize)
                        }
                        .position(x: UIScreen.main.bounds.width/2 + noBubblePosition.x + 50, 
                                  y: noBubblePosition.y + 100)
                    }
                    .frame(height: 250)
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(y: 60)
                
                Spacer()
            }
        }
        .onAppear {
            startBubbleAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .fullScreenCover(isPresented: $showWellbeingForm) {
            WellbeingFormView(isPresented: $isPresented, stayedClean: stayedClean ?? false)
                .onChange(of: isPresented) { _, newValue in
                    if !newValue {
                        // If WellbeingFormView is dismissed, also dismiss this view
                        returnToHome = true
                    }
                }
        }
    }
    
    // Start the bubble animation
    private func startBubbleAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBubblePositions()
        }
    }
    
    // Update bubble positions with physics
    private func updateBubblePositions() {
        let now = Date()
        let deltaTime = now.timeIntervalSince(lastUpdateTime)
        lastUpdateTime = now
        
        // Update positions based on velocity
        yesBubblePosition.x += CGFloat(yesBubbleVelocity.dx * deltaTime * 60)
        yesBubblePosition.y += CGFloat(yesBubbleVelocity.dy * deltaTime * 60)
        noBubblePosition.x += CGFloat(noBubbleVelocity.dx * deltaTime * 60)
        noBubblePosition.y += CGFloat(noBubbleVelocity.dy * deltaTime * 60)
        
        // Boundary collision detection (limit movement range)
        let maxXOffset: CGFloat = 30
        let maxYOffset: CGFloat = 20
        
        // Yes bubble boundary collision
        if abs(yesBubblePosition.x) > maxXOffset {
            yesBubbleVelocity.dx *= -1
            yesBubblePosition.x = yesBubblePosition.x > 0 ? maxXOffset : -maxXOffset
        }
        if abs(yesBubblePosition.y) > maxYOffset {
            yesBubbleVelocity.dy *= -1
            yesBubblePosition.y = yesBubblePosition.y > 0 ? maxYOffset : -maxYOffset
        }
        
        // No bubble boundary collision
        if abs(noBubblePosition.x) > maxXOffset {
            noBubbleVelocity.dx *= -1
            noBubblePosition.x = noBubblePosition.x > 0 ? maxXOffset : -maxXOffset
        }
        if abs(noBubblePosition.y) > maxYOffset {
            noBubbleVelocity.dy *= -1
            noBubblePosition.y = noBubblePosition.y > 0 ? maxYOffset : -maxYOffset
        }
        
        // Bubble collision detection
        let distance = sqrt(pow((yesBubblePosition.x - 50) - (noBubblePosition.x + 50), 2) + 
                           pow(yesBubblePosition.y - noBubblePosition.y, 2))
        let minDistance = (yesBubbleSize + noBubbleSize) / 2
        
        if distance < minDistance {
            // Collision response - simple bounce
            let overlap = minDistance - distance
            
            // Calculate collision normal
            let nx = ((noBubblePosition.x + 50) - (yesBubblePosition.x - 50)) / distance
            let ny = (noBubblePosition.y - yesBubblePosition.y) / distance
            
            // Separate bubbles to prevent overlap
            yesBubblePosition.x -= nx * overlap * 0.3
            yesBubblePosition.y -= ny * overlap * 0.3
            noBubblePosition.x += nx * overlap * 0.3
            noBubblePosition.y += ny * overlap * 0.3
            
            // Reflect velocities (simplified physics)
            let dotProductYes = yesBubbleVelocity.dx * nx + yesBubbleVelocity.dy * ny
            let dotProductNo = noBubbleVelocity.dx * nx + noBubbleVelocity.dy * ny
            
            yesBubbleVelocity.dx -= 1.8 * dotProductYes * nx
            yesBubbleVelocity.dy -= 1.8 * dotProductYes * ny
            noBubbleVelocity.dx -= 1.8 * dotProductNo * nx
            noBubbleVelocity.dy -= 1.8 * dotProductNo * ny
        }
    }
}

// Bubble component
struct BubbleView: View {
    let text: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main bubble with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "93ADEF"), // Light blue from the app's gradient
                            Color(hex: "1141B9")  // Darker blue from the app's gradient
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                )
                .overlay(
                    // Highlight to create bubble effect
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: size * 0.6, height: size * 0.6)
                        .offset(x: -size * 0.15, y: -size * 0.15)
                )
                .frame(width: size, height: size)
            
            // Text
            Text(text)
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct DailyCheckInView_Previews: PreviewProvider {
    static var previews: some View {
        DailyCheckInView(isPresented: .constant(true), returnToHome: .constant(false))
    }
} 