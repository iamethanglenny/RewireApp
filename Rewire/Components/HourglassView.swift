import SwiftUI

struct HourglassView: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Hourglass outline
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    // Top triangle
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    
                    // Bottom triangle
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                
                // Filled portion (top)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                }
                .fill(Color.white.opacity(0.2))
                
                // Filled portion (bottom - represents progress)
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midX = width / 2
                    
                    // Calculate how much of the bottom triangle to fill based on progress
                    let fillHeight = height / 2 * progress
                    
                    path.move(to: CGPoint(x: midX, y: height / 2))
                    
                    // Calculate points for the trapezoid
                    let ratio = fillHeight / (height / 2)
                    let leftX = midX - (midX * ratio)
                    let rightX = midX + (midX * ratio)
                    
                    path.addLine(to: CGPoint(x: leftX, y: height / 2 + fillHeight))
                    path.addLine(to: CGPoint(x: rightX, y: height / 2 + fillHeight))
                    path.addLine(to: CGPoint(x: midX, y: height / 2))
                }
                .fill(Color.white)
            }
            .frame(width: min(geometry.size.width, 200))
            .frame(maxWidth: .infinity)
        }
    }
}

struct HourglassView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            HourglassView(progress: 0.12)
                .frame(height: 300)
                .padding()
        }
    }
} 