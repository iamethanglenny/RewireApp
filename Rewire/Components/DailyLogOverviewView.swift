import SwiftUI

struct DailyLogOverviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditLog = false
    @State private var showingCalendar = false
    @State private var showingProgress = false
    
    // Sample data - in a real app, this would be passed in or fetched
    let loggedData = LoggedDayData(
        date: Date(),
        stayedClean: true,
        wellbeingRatings: [
            "Mood": 4,
            "Energy": 3,
            "Sleep": 4,
            "Cravings": 2
        ],
        note: "Today was challenging but I managed to stay focused on my goals."
    )
    
    var body: some View {
        ZStack {
            // Updated background to pure black
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with title and exit button
                ZStack {
                    Text("Today's Log")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
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
                
                // Status card with enhanced styling
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: loggedData.stayedClean ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(loggedData.stayedClean ? Color(hex: "4CAF50") : Color(hex: "F44336"))
                        
                        Text(loggedData.stayedClean ? "You stayed clean today" : "You had a slip today")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    // Date
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(formattedDate(loggedData.date))
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(hex: "121212"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Wellbeing ratings with enhanced styling
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Wellbeing")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Ratings grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(Array(loggedData.wellbeingRatings.keys.sorted()), id: \.self) { category in
                            if let rating = loggedData.wellbeingRatings[category] {
                                WellbeingRatingCard(
                                    category: category,
                                    rating: rating,
                                    color: colorForCategory(category)
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(hex: "121212"))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.top, 15)
                
                // Note section with enhanced styling - removing black box behind note
                if !loggedData.note.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Note")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(loggedData.note)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // Removed the black background
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(hex: "121212"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.top, 15)
                }
                
                Spacer()
                
                // Action buttons with refined glassy effect
                VStack(spacing: 15) {
                    Button(action: {
                        showingEditLog = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Today's Log")
                        }
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            ZStack {
                                // Base gradient - more subtle
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "0A2472").opacity(0.8), Color(hex: "1141B9").opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // Very subtle glass overlay
                                Color.white.opacity(0.05)
                                
                                // More subtle highlight at the top
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0)]),
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5 // Thinner border for elegance
                                )
                        )
                        .cornerRadius(10)
                        .shadow(color: Color(hex: "1141B9").opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            showingCalendar = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Calendar")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                ZStack {
                                    // Dark base with refined transparency
                                    Color(hex: "121212").opacity(0.9)
                                    
                                    // Very subtle glass effect
                                    Color.white.opacity(0.03)
                                    
                                    // Refined highlight at the top
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0)]),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.05)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5 // Thinner border for elegance
                                    )
                            )
                            .cornerRadius(10)
                            .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        Button(action: {
                            showingProgress = true
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("Progress")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                ZStack {
                                    // Dark base with refined transparency
                                    Color(hex: "121212").opacity(0.9)
                                    
                                    // Very subtle glass effect
                                    Color.white.opacity(0.03)
                                    
                                    // Refined highlight at the top
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0)]),
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.05)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 0.5 // Thinner border for elegance
                                    )
                            )
                            .cornerRadius(10)
                            .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.vertical)
        }
        .fullScreenCover(isPresented: $showingEditLog) {
            // This would navigate to the tracking flow, but starting with the wellbeing form
            WellbeingFormView(isPresented: $showingEditLog, stayedClean: loggedData.stayedClean)
        }
        .sheet(isPresented: $showingCalendar) {
            // Placeholder for calendar view
            CalendarView()
        }
        .sheet(isPresented: $showingProgress) {
            // Placeholder for progress view
            ProgressOverviewView()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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

// Data model for a logged day
struct LoggedDayData {
    let date: Date
    let stayedClean: Bool
    let wellbeingRatings: [String: Int]
    let note: String
}

// Card to display wellbeing rating
struct WellbeingRatingCard: View {
    let category: String
    let rating: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            RatingPill(rating: rating, color: color)
                .frame(width: 8, height: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(category)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text("\(rating)/5")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color(hex: "0A0A0A"))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(10)
    }
}

// Placeholder views for Calendar and Progress
struct CalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Calendar View")
                    .font(.largeTitle)
                    .padding()
                
                Text("Coming soon!")
                    .font(.title2)
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ProgressOverviewView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Progress Overview")
                    .font(.largeTitle)
                    .padding()
                
                Text("Coming soon!")
                    .font(.title2)
                
                Spacer()
            }
            .navigationTitle("Your Progress")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DailyLogOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        DailyLogOverviewView()
    }
} 