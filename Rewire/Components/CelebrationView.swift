import SwiftUI

struct CelebrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var returnToHome: Bool
    @State private var confettiEmojis = ["🎉", "🎊", "✨", "💪", "🏆", "⭐️", "🌟", "👏", "🙌"]
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animationStarted = false
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        let emoji: String
        var startPosition: CGPoint
        var endPosition: CGPoint
        let scale: CGFloat
        let speed: CGFloat
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A1A1A"), location: 0.0),
                    .init(color: Color(hex: "1141B9"), location: 0.5),
                    .init(color: Color(hex: "93ADEF"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Confetti emojis
            ForEach(confettiPieces) { piece in
                Text(piece.emoji)
                    .font(.system(size: 40 * piece.scale))
                    .position(animationStarted ? piece.endPosition : piece.startPosition)
                    .animation(
                        Animation.easeOut(duration: 5.0)
                            .speed(piece.speed),
                        value: animationStarted
                    )
            }
            
            // Congratulatory message
            VStack(spacing: 30) {
                Text("Congratulations!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                Text("You are making moves towards changing your life for the better, keep up the good work!")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer().frame(height: 40)
                
                Button(action: {
                    // Signal to return to home screen
                    returnToHome = true
                    // Dismiss this view
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Home")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color(hex: "1141B9"))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 100)
        }
        .onAppear {
            // Generate confetti pieces
            generateConfetti()
            
            // Start animation after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animationStarted = true
                }
            }
        }
    }
    
    private func generateConfetti() {
        // Get the screen size
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        // Generate 40 confetti pieces for a more dense explosion
        for _ in 0..<40 {
            let emoji = confettiEmojis.randomElement() ?? "🎉"
            let angle = Double.random(in: 0..<2 * .pi)
            
            // Reduce the distance for slower movement
            let distance = CGFloat.random(in: max(screenWidth, screenHeight) * 0.8...max(screenWidth, screenHeight) * 1.2)
            
            // Calculate end position based on angle and distance
            let endX = centerX + cos(angle) * distance
            let endY = centerY + sin(angle) * distance
            
            let piece = ConfettiPiece(
                emoji: emoji,
                startPosition: CGPoint(x: centerX, y: centerY),
                endPosition: CGPoint(x: endX, y: endY),
                scale: CGFloat.random(in: 0.7...1.3),
                speed: CGFloat.random(in: 0.5...0.7) // Slower speed range
            )
            
            confettiPieces.append(piece)
        }
    }
}

struct CelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        CelebrationView(returnToHome: .constant(false))
    }
} 