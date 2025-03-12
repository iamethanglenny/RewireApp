import SwiftUI

struct ProfileView: View {
    // Sample user data
    let username = "Alex"
    let quitDate = "June 15, 2023"
    let streak = 12
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundTop"), Color("BackgroundBottom")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Top navigation bar
                HStack {
                    Text("PROFILE")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action for GET PRO button
                    }) {
                        Text("GET PRO")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Profile header
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text(username)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Label("\(streak) day streak", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                }
                .padding(.vertical, 30)
                
                // Profile sections
                ScrollView {
                    VStack(spacing: 20) {
                        ProfileSectionView(title: "Your Journey") {
                            VStack(alignment: .leading, spacing: 15) {
                                ProfileInfoRow(label: "Quit Date", value: quitDate)
                                ProfileInfoRow(label: "Money Saved", value: "$452.23")
                                ProfileInfoRow(label: "Vape-Free Days", value: "\(streak)")
                                ProfileInfoRow(label: "Cravings Overcome", value: "47")
                            }
                        }
                        
                        ProfileSectionView(title: "Settings") {
                            VStack(alignment: .leading, spacing: 15) {
                                SettingsButtonRow(icon: "bell", title: "Notifications")
                                SettingsButtonRow(icon: "gear", title: "Preferences")
                                SettingsButtonRow(icon: "chart.bar", title: "Statistics")
                                SettingsButtonRow(icon: "questionmark.circle", title: "Help & Support")
                            }
                        }
                        
                        Button(action: {
                            // Logout action
                        }) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(15)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

struct ProfileSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            VStack {
                content
                    .padding()
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {
            // Settings action
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// Preview provider for ProfileView
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// Preview providers for component views
struct ProfileSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            ProfileSectionView(title: "Your Journey") {
                VStack(alignment: .leading, spacing: 15) {
                    ProfileInfoRow(label: "Quit Date", value: "June 15, 2023")
                    ProfileInfoRow(label: "Money Saved", value: "$452.23")
                }
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

struct ProfileInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            ProfileInfoRow(label: "Quit Date", value: "June 15, 2023")
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}

struct SettingsButtonRow_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            SettingsButtonRow(icon: "bell", title: "Notifications")
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
} 