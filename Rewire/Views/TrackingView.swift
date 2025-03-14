import SwiftUI

struct TrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDailyCheckIn = true
    
    var body: some View {
        ZStack {
            // Show DailyCheckInView immediately
            if showingDailyCheckIn {
                DailyCheckInView(isPresented: $showingDailyCheckIn)
                    .onDisappear {
                        // When DailyCheckInView is dismissed, also dismiss TrackingView
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .onAppear {
            // Ensure DailyCheckInView is shown immediately
            showingDailyCheckIn = true
        }
    }
}

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

struct WellbeingFormView: View {
    @Binding var isPresented: Bool
    let stayedClean: Bool
    @State private var showingNoteWriter = false
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
                            isPresented = false
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
    }
}

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

struct NoteWritingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var savedNote: String
    @State private var noteText: String = ""
    @State private var characterCount: Int = 0
    private let characterLimit = 140
    
    // Create a custom TextEditor with white background and placeholder
    struct WhiteTextEditor: UIViewRepresentable {
        @Binding var text: String
        var placeholder: String
        
        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textView.delegate = context.coordinator
            textView.backgroundColor = .white
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.textColor = .black
            textView.isScrollEnabled = true
            textView.isEditable = true
            textView.isUserInteractionEnabled = true
            textView.autocapitalizationType = .sentences
            
            // Set placeholder text
            if text.isEmpty {
                textView.text = placeholder
                textView.textColor = UIColor.lightGray
            }
            
            return textView
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            // Only update if the text has changed to avoid cursor jumping
            if uiView.text != text {
                if text.isEmpty {
                    if uiView.textColor == UIColor.lightGray {
                        // Already showing placeholder, no need to update
                        return
                    }
                    uiView.text = placeholder
                    uiView.textColor = UIColor.lightGray
                } else {
                    uiView.text = text
                    uiView.textColor = UIColor.black
                }
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UITextViewDelegate {
            var parent: WhiteTextEditor
            
            init(_ parent: WhiteTextEditor) {
                self.parent = parent
            }
            
            func textViewDidBeginEditing(_ textView: UITextView) {
                // Clear placeholder when editing begins
                if textView.textColor == UIColor.lightGray {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }
            
            func textViewDidEndEditing(_ textView: UITextView) {
                // Restore placeholder if text is empty
                if textView.text.isEmpty {
                    textView.text = parent.placeholder
                    textView.textColor = UIColor.lightGray
                }
            }
            
            func textViewDidChange(_ textView: UITextView) {
                // Only update parent text if not showing placeholder
                if textView.textColor != UIColor.lightGray {
                    parent.text = textView.text
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with title and exit button
                ZStack {
                    // Centered text
                    Text("Add a Note")
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
                
                Spacer()
                
                // Note writing area
                VStack(spacing: 15) {
                    // White text input area
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        
                        // Use custom WhiteTextEditor with placeholder
                        WhiteTextEditor(
                            text: $noteText,
                            placeholder: "What is the first thing that comes to mind...?"
                        )
                        .padding(10)
                    }
                    .frame(height: 200)
                    .onChange(of: noteText) { _, newValue in
                        characterCount = newValue.count
                        if newValue.count > characterLimit {
                            noteText = String(newValue.prefix(characterLimit))
                            characterCount = characterLimit
                        }
                    }
                    .onAppear {
                        // Initialize with existing note if available
                        noteText = savedNote
                        characterCount = savedNote.count
                    }
                    
                    // Character count and save button
                    HStack {
                        Text("\(characterCount)/\(characterLimit)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            // Save the note and dismiss
                            savedNote = noteText
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Color(hex: "1141B9"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.horizontal, 25)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct RatingPill: View {
    let rating: Int
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Unfilled portion (now at the top)
                Rectangle()
                    .fill(color.opacity(0.25))
                    .frame(height: geometry.size.height * (1.0 - CGFloat(rating) / 5.0))
                
                // Filled portion (now at the bottom)
                Rectangle()
                    .fill(color)
                    .frame(height: geometry.size.height * CGFloat(rating) / 5.0)
            }
            .cornerRadius(4)
        }
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
} 
