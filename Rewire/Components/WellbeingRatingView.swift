import SwiftUI

struct WellbeingRatingView: View {
    @Environment(\.presentationMode) var presentationMode
    let category: String
    @Binding var selectedRating: Int?
    @Binding var selectedOption: String
    @State private var temporaryRating: Int? = nil
    
    var body: some View {
        ZStack {
            // Solid black background
            Color(hex: "000000")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with title and exit button in-line
                ZStack {
                    // Centered text
                    Text(category)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Right-aligned X button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .background(Color.black)
                
                Spacer()
                
                // Question text
                Text(questionForCategory(category))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                
                // White container for rating options (50% of screen height)
                ZStack(alignment: .top) {
                    // White background with rounded top corners
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .edgesIgnoringSafeArea(.bottom)
                    
                    // Rating options
                    VStack(spacing: 15) {
                        ForEach(ratingOptionsForCategory(category).indices, id: \.self) { index in
                            let option = ratingOptionsForCategory(category)[index]
                            let rating = 5 - index // Convert index to rating (5 to 1)
                            
                            Button(action: {
                                temporaryRating = rating
                                selectedRating = rating
                                selectedOption = option
                                
                                // Wait a moment to show selection before dismissing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                HStack(spacing: 15) {
                                    // Vertical pill indicator (inverted to fill from bottom)
                                    RatingPill(rating: rating, color: colorForCategory(category))
                                        .frame(width: 8, height: 40)
                                    
                                    Text(option)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(rating)/5")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(temporaryRating == rating ? Color.gray.opacity(0.1) : Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 15)
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
            }
        }
    }
    
    private func questionForCategory(_ category: String) -> String {
        switch category {
        case "Mood":
            return "How did you feel today?"
        case "Energy":
            return "How energised did you feel today?"
        case "Sleep":
            return "How well did you sleep last night?"
        case "Cravings":
            return "How strong were your cravings today?"
        default:
            return "Rate your \(category.lowercased()) today"
        }
    }
    
    private func ratingOptionsForCategory(_ category: String) -> [String] {
        switch category {
        case "Mood":
            return ["Very Happy", "Happy", "Neutral", "Sad", "Very Sad"]
        case "Energy":
            return ["Very Energetic", "Energetic", "Average", "Tired", "Very Tired"]
        case "Sleep":
            return ["Excellent", "Good", "Average", "Poor", "Very Poor"]
        case "Cravings":
            return ["None", "Mild", "Moderate", "Strong", "Very Strong"]
        default:
            return ["Excellent", "Good", "Average", "Poor", "Very Poor"]
        }
    }
    
    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Mood":
            return Color(hex: "4CAF50") // Green
        case "Energy":
            return Color(hex: "F1C644") // Yellow
        case "Sleep":
            return Color(hex: "3F51B5") // Indigo
        case "Cravings":
            return Color(hex: "FF5722") // Deep Orange
        default:
            return Color.blue
        }
    }
} 