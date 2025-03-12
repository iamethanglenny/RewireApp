import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content based on selected tab
            ZStack {
                if selectedTab == 0 {
                    HomeView()
                } else if selectedTab == 1 {
                    RewiringView()
                } else {
                    ProfileView()
                }
            }
            
            // Custom tab bar
            HStack(spacing: 0) {
                // Home tab
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Image("homeIcon")
                            .scaleEffect(0.85) // Decrease size by 15%
                            .opacity(selectedTab == 0 ? 1.0 : 0.5) // Only adjust opacity
                        
                        Text("Home")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .opacity(selectedTab == 0 ? 1.0 : 0.5)
                    }
                    .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
                
                // Rewiring tab
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "brain")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .opacity(selectedTab == 1 ? 1.0 : 0.5)
                        
                        Text("Rewiring")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .opacity(selectedTab == 1 ? 1.0 : 0.5)
                    }
                    .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
                
                // Profile tab
                Button(action: { selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .opacity(selectedTab == 2 ? 1.0 : 0.5)
                        
                        Text("Profile")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .opacity(selectedTab == 2 ? 1.0 : 0.5)
                    }
                    .padding(.top, 5)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .background(Color.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
