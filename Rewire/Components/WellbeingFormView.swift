import SwiftUI

struct WellbeingFormView: View {
    @Binding var isPresented: Bool
    @State private var returnToHome = false
    let stayedClean: Bool
    @State private var showingNoteWriter = false
    @State private var showingCelebration = false
    @State private var savedNote: String = ""
    
    var body: some View {
        ZStack {
            // Inverted gradient background
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "93ADEF"), location: 0.0),
                    .init(color: Color(hex: "1141B9"), location: 0.35),
                    .init(color: Color(hex: "1A1A1A"), location: 0.53)
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
                
                // "Did you stay clean?" section position reference
                Color.clear
                    .frame(height: 50)
                
                // White container for form content (50% of screen height)
                ZStack(alignment: .top) {
                    // White background with rounded top corners
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack(spacing: 0) {
                        // Form content
                        VStack(spacing: 20) {
                            // Status confirmation
                            Text(stayedClean ? "You stayed clean today!" : "You had a slip today.")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding(.top, 30)
                                .padding(.bottom, 5)
                            
                            // Separator line
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .padding(.horizontal)
                            
                            // Wellbeing section
                            Text("Your Wellbeing")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Wellbeing buttons in 2x2 grid with fixed size
                            VStack(spacing: 15) {
                                HStack(spacing: 15) {
                                    WellbeingButton(title: "Mood")
                                        .frame(width: 160, height: 42)
                                    WellbeingButton(title: "Energy")
                                        .frame(width: 160, height: 42)
                                }
                                
                                HStack(spacing: 15) {
                                    WellbeingButton(title: "Sleep")
                                        .frame(width: 160, height: 42)
                                    WellbeingButton(title: "Cravings")
                                        .frame(width: 160, height: 42)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Add a note section with notepad styling
                            ZStack {
                                // Shadow rectangle
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "D9D9D9").opacity(0.5))
                                    .frame(height: savedNote.isEmpty ? 120 : 150)
                                    .offset(x: 3, y: 3)
                                    .blur(radius: 4)
                                
                                // White notepad background
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(height: savedNote.isEmpty ? 120 : 150)
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                
                                // Note content
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Add a note")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    if savedNote.isEmpty {
                                        Text("Self-reflection drives positive change")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Button(action: {
                                            showingNoteWriter = true
                                        }) {
                                            Text("Write")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .frame(width: 100, height: 36)
                                                .background(Color(hex: "1141B9"))
                                                .cornerRadius(5)
                                        }
                                        .padding(.top, 5)
                                    } else {
                                        // Note preview
                                        Text(savedNote)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black.opacity(0.5))
                                            .lineLimit(3)
                                            .padding(.top, 5)
                                            .padding(.bottom, 5)
                                        
                                        Button(action: {
                                            showingNoteWriter = true
                                        }) {
                                            Text("Edit")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .frame(width: 100, height: 36)
                                                .background(Color(hex: "1141B9"))
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Replace the Spacer with a fixed height spacer that's 75% smaller
                            Color.clear.frame(height: 5)
                        }
                        .padding(.horizontal)
                        
                        // Done button at the bottom
                        Button(action: {
                            showingCelebration = true
                        }) {
                            Text("Done")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color(hex: "1141B9"))
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 40)
                        .padding(.top, 0)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
            }
        }
        .fullScreenCover(isPresented: $showingNoteWriter) {
            NoteWritingView(savedNote: $savedNote)
        }
        .fullScreenCover(isPresented: $showingCelebration) {
            CelebrationView(returnToHome: $returnToHome)
                .onDisappear {
                    if returnToHome {
                        // If returnToHome is true, dismiss all the way back to home
                        isPresented = false
                    }
                }
        }
        .onChange(of: returnToHome) { _, newValue in
            if newValue {
                // If returnToHome becomes true, dismiss this view
                isPresented = false
            }
        }
    }
} 