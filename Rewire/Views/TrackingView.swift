import SwiftUI

struct TrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Track Your Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Daily tracking section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Daily Check-in")
                                .font(.headline)
                                .padding(.leading)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                                
                                VStack(spacing: 15) {
                                    HStack {
                                        Text("How are you feeling today?")
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 20) {
                                        ForEach(1...5, id: \.self) { rating in
                                            Button(action: {
                                                // Handle mood selection
                                            }) {
                                                VStack {
                                                    Text(moodEmoji(for: rating))
                                                        .font(.system(size: 30))
                                                    Text(moodText(for: rating))
                                                        .font(.caption)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding()
                            }
                            .frame(height: 120)
                            .padding(.horizontal)
                        }
                        
                        // Progress metrics
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Progress")
                                .font(.headline)
                                .padding(.leading)
                            
                            VStack(spacing: 15) {
                                ProgressMetricView(title: "Days Clean", value: "15")
                                ProgressMetricView(title: "Urges Resisted", value: "27")
                                ProgressMetricView(title: "Mood Trend", value: "Improving")
                            }
                            .padding(.horizontal)
                        }
                        
                        // Activity log
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Activity Log")
                                .font(.headline)
                                .padding(.leading)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.systemGray6))
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Recent Activities")
                                        .font(.subheadline)
                                    
                                    ForEach(1...3, id: \.self) { index in
                                        HStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 10, height: 10)
                                            Text("Completed meditation session")
                                                .font(.system(size: 14))
                                            Spacer()
                                            Text("\(index) day\(index == 1 ? "" : "s") ago")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        if index < 3 {
                                            Divider()
                                        }
                                    }
                                    
                                    Button(action: {
                                        // View full history
                                    }) {
                                        Text("View Full History")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.top, 5)
                                }
                                .padding()
                            }
                            .frame(height: 180)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("Tracking", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                Text("Back")
            })
        }
    }
    
    private func moodEmoji(for rating: Int) -> String {
        switch rating {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    private func moodText(for rating: Int) -> String {
        switch rating {
        case 1: return "Bad"
        case 2: return "Poor"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return "Okay"
        }
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
} 