import SwiftUI

struct ProgressMetricView: View {
    let title: String
    let value: String
    var isMoneyValue: Bool = false
    var isTimeValue: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            if isMoneyValue, let formattedValue = formatMoneyValue(value) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$")
                        .font(.system(size: 25))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(formattedValue.dollars)
                        .font(.system(size: 37, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(formattedValue.cents)
                        .font(.system(size: 25))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else if isTimeValue, let formattedValue = formatTimeValue(value) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(formattedValue.number)
                        .font(.system(size: 37, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(formattedValue.unit)
                        .font(.system(size: 25))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                Text(value)
                    .font(.system(size: 37, weight: .black))
                    .foregroundColor(.white)
            }
        }
        .frame(minWidth: 120)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
    }
    
    private func formatMoneyValue(_ value: String) -> (dollars: String, cents: String)? {
        // Remove any existing $ sign
        let cleanValue = value.replacingOccurrences(of: "$", with: "")
        
        // Split by decimal point
        let components = cleanValue.components(separatedBy: ".")
        if components.count == 2 {
            return (dollars: components[0], cents: "." + components[1])
        } else if components.count == 1 {
            return (dollars: components[0], cents: ".00")
        }
        
        return nil
    }
    
    private func formatTimeValue(_ value: String) -> (number: String, unit: String)? {
        // Regular expression to separate number and unit
        let pattern = "^(\\d+)\\s*([a-zA-Z]+)$"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        if let regex = regex,
           let match = regex.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)) {
            let numberRange = Range(match.range(at: 1), in: value)!
            let unitRange = Range(match.range(at: 2), in: value)!
            
            return (number: String(value[numberRange]), unit: String(value[unitRange]))
        }
        
        return nil
    }
}

struct ProgressMetricView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            VStack(spacing: 30) {
                ProgressMetricView(title: "💰 money saved", value: "$452.23", isMoneyValue: true)
                ProgressMetricView(title: "🌱 life reclaimed", value: "2 yrs", isTimeValue: true)
                ProgressMetricView(title: "🕰️ time saved", value: "5 hrs", isTimeValue: true)
                ProgressMetricView(title: "🎯 cravings overcome", value: "62")
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 
