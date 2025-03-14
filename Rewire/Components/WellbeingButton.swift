import SwiftUI

struct WellbeingButton: View {
    var title: String
    @State private var showRating = false
    @State private var selectedRating: Int? = nil
    @State private var selectedOption: String = ""
    
    var body: some View {
        Button(action: {
            showRating = true
        }) {
            HStack {
                if selectedRating != nil {
                    // Show pill indicator when rating is selected
                    RatingPill(rating: selectedRating!, color: colorForCategory(title))
                        .frame(width: 8, height: 24)
                        .padding(.trailing, 5)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "1141B9"))
                }
                
                // Always show the category name
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedRating != nil ? .black : Color(hex: "1141B9"))
                
                Spacer()
                
                if selectedRating != nil {
                    Text("\(selectedRating!)/5")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 15)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                selectedRating != nil 
                ? Color.white 
                : Color(hex: "93ADEF").opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedRating != nil 
                        ? Color(hex: "868686").opacity(0.25) 
                        : Color(hex: "1141B9").opacity(0.5),
                        lineWidth: 2
                    )
            )
            .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $showRating) {
            WellbeingRatingView(
                category: title,
                selectedRating: $selectedRating,
                selectedOption: $selectedOption
            )
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