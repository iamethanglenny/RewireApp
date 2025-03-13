import SwiftUI

// Simple line graph view
struct LineGraphView: View {
    // Sample data for the graph
    let dataPoints: [CGFloat]
    
    // Define gradient colors
    let gradientColors = Gradient(stops: [
        .init(color: Color(red: 0.58, green: 0.68, blue: 0.94, opacity: 0.87), location: 0), // #93ADEF with 87% opacity
        .init(color: Color(red: 0.07, green: 0.25, blue: 0.73, opacity: 1.0), location: 1)   // #1141B9 with 100% opacity
    ])
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid lines - placed first so they appear behind everything
                GridLines(
                    width: geometry.size.width - 30,
                    height: geometry.size.height - 15,
                    horizontalLines: 3,
                    verticalLines: 7
                )
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: 0.5,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [2, 4],
                        dashPhase: 0
                    )
                )
                .opacity(0.15) // Very subtle opacity
                .frame(width: geometry.size.width - 30, height: geometry.size.height - 15)
                .position(x: (geometry.size.width - 15) / 2, y: (geometry.size.height - 7.5) / 2)
                
                // Graph content
                GraphContent(
                    width: geometry.size.width - 30,
                    height: geometry.size.height - 15,
                    dataPoints: dataPoints,
                    gradientColors: gradientColors
                )
                
                // Y-axis labels (right side)
                VStack(alignment: .trailing, spacing: 0) {
                    Text("4h")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("2h")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("0h")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(width: 20, height: geometry.size.height)
                .position(x: geometry.size.width - 10, y: geometry.size.height / 2)
                
                // X-axis labels (days of week)
                HStack(spacing: 0) {
                    ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: (geometry.size.width - 30) / 7)
                    }
                }
                .frame(width: geometry.size.width - 30, height: 10)
                .position(x: (geometry.size.width - 15) / 2, y: geometry.size.height - 5)
            }
        }
    }
}

// Grid lines for the graph
struct GridLines: Shape {
    let width: CGFloat
    let height: CGFloat
    let horizontalLines: Int
    let verticalLines: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Horizontal grid lines
        let horizontalSpacing = height / CGFloat(horizontalLines)
        for i in 0...horizontalLines {
            let y = CGFloat(i) * horizontalSpacing
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        
        // Vertical grid lines
        let verticalSpacing = width / CGFloat(verticalLines)
        for i in 0...verticalLines {
            let x = CGFloat(i) * verticalSpacing
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        return path
    }
}

// Separate view for graph content to avoid control flow issues
struct GraphContent: View {
    let width: CGFloat
    let height: CGFloat
    let dataPoints: [CGFloat]
    let gradientColors: Gradient
    
    var body: some View {
        ZStack {
            // Area fill below the curved line
            AreaPath(width: width, height: height, dataPoints: dataPoints)
                .fill(LinearGradient(gradient: gradientColors, startPoint: .top, endPoint: .bottom))
                .opacity(0.5) // 50% transparency for the entire gradient
            
            // Curved line graph
            LinePath(width: width, height: height, dataPoints: dataPoints)
                .stroke(LinearGradient(gradient: gradientColors, startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                .opacity(0.5) // 50% transparency for the line
        }
        .frame(width: width, height: height)
        .position(x: width / 2, y: height / 2)
    }
}

// Path for the area below the line
struct AreaPath: Shape {
    let width: CGFloat
    let height: CGFloat
    let dataPoints: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepWidth = width / CGFloat(dataPoints.count - 1)
        let stepHeight = height / 60 // Assuming max value is 60 (4 hours)
        
        // Create points for the curved path
        var points = [CGPoint]()
        for i in 0..<dataPoints.count {
            let point = CGPoint(
                x: CGFloat(i) * stepWidth,
                y: height - dataPoints[i] * stepHeight
            )
            points.append(point)
        }
        
        // Start at the bottom left
        path.move(to: CGPoint(x: 0, y: height))
        
        // Draw line to the first data point
        path.addLine(to: points[0])
        
        // Draw curved lines through all data points
        for i in 1..<points.count {
            let previousPoint = points[i-1]
            let currentPoint = points[i]
            
            // Calculate control points for the curve
            let control1 = CGPoint(
                x: previousPoint.x + (currentPoint.x - previousPoint.x) / 2,
                y: previousPoint.y
            )
            let control2 = CGPoint(
                x: previousPoint.x + (currentPoint.x - previousPoint.x) / 2,
                y: currentPoint.y
            )
            
            path.addCurve(to: currentPoint, control1: control1, control2: control2)
        }
        
        // Draw line to bottom right
        path.addLine(to: CGPoint(x: width, y: height))
        
        // Close the path
        path.closeSubpath()
        
        return path
    }
}

// Path for the line
struct LinePath: Shape {
    let width: CGFloat
    let height: CGFloat
    let dataPoints: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let stepWidth = width / CGFloat(dataPoints.count - 1)
        let stepHeight = height / 60 // Assuming max value is 60 (4 hours)
        
        // Create points for the curved path
        var points = [CGPoint]()
        for i in 0..<dataPoints.count {
            let point = CGPoint(
                x: CGFloat(i) * stepWidth,
                y: height - dataPoints[i] * stepHeight
            )
            points.append(point)
        }
        
        // Start at the first point
        path.move(to: points[0])
        
        // Draw curved lines through all data points
        for i in 1..<points.count {
            let previousPoint = points[i-1]
            let currentPoint = points[i]
            
            // Calculate control points for the curve
            let control1 = CGPoint(
                x: previousPoint.x + (currentPoint.x - previousPoint.x) / 2,
                y: previousPoint.y
            )
            let control2 = CGPoint(
                x: previousPoint.x + (currentPoint.x - previousPoint.x) / 2,
                y: currentPoint.y
            )
            
            path.addCurve(to: currentPoint, control1: control1, control2: control2)
        }
        
        return path
    }
}

// Preview for the LineGraphView
struct LineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            LineGraphView(dataPoints: [20, 40, 30, 60, 25, 45, 35])
                .frame(width: 300, height: 60)
        }
    }
} 