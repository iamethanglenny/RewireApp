import SwiftUI

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