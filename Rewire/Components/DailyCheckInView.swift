import SwiftUI

struct DailyCheckInView: View {
    @Binding var isPresented: Bool
    @State private var showWellbeingForm = false
    @State private var stayedClean: Bool? = nil
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "1A1A1A"), location: 0.47),
                    .init(color: Color(hex: "1141B9"), location: 0.65),
                    .init(color: Color(hex: "93ADEF"), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with Today text and exit button in-line
                ZStack {
                    // Centered text
                    Text("Today")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Right-aligned X button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // "Did you stay clean?" section
                VStack(spacing: 30) {
                    Text("Did you stay clean?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 50) {
                        // YES button
                        Button(action: {
                            stayedClean = true
                            showWellbeingForm = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text("YES")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // NO button
                        Button(action: {
                            stayedClean = false
                            showWellbeingForm = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text("NO")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(y: -40)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showWellbeingForm) {
            WellbeingFormView(isPresented: $isPresented, stayedClean: stayedClean ?? false)
        }
    }
} 