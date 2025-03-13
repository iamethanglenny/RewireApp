import SwiftUI

struct SupportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: SupportCategory? = nil
    @State private var showingEmergencyContact = false
    
    let supportCategories = [
        SupportCategory(id: 1, name: "Therapy Resources", icon: "person.fill.questionmark", color: .blue),
        SupportCategory(id: 2, name: "Support Groups", icon: "person.3.fill", color: .green),
        SupportCategory(id: 3, name: "Crisis Helplines", icon: "phone.fill", color: .red),
        SupportCategory(id: 4, name: "Educational Content", icon: "book.fill", color: .orange),
        SupportCategory(id: 5, name: "Community Forum", icon: "bubble.left.and.bubble.right.fill", color: .purple)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if let category = selectedCategory {
                    // Category detail view
                    SupportCategoryDetailView(category: category, onBack: {
                        self.selectedCategory = nil
                    })
                } else {
                    // Main support view
                    ScrollView {
                        VStack(spacing: 25) {
                            // Emergency support button
                            Button(action: {
                                showingEmergencyContact = true
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                    Text("Emergency Support")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                            }
                            .padding(.horizontal)
                            .alert(isPresented: $showingEmergencyContact) {
                                Alert(
                                    title: Text("Emergency Support"),
                                    message: Text("Call National Crisis Hotline: 988\n\nText HOME to 741741 to reach Crisis Text Line\n\nIf you're in immediate danger, please call 911"),
                                    primaryButton: .default(Text("Call 988")) {
                                        // In a real app, this would initiate a phone call
                                        print("Calling crisis hotline")
                                    },
                                    secondaryButton: .cancel(Text("Dismiss"))
                                )
                            }
                            
                            Text("Support Resources")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Text("Connect with professional help and community support to strengthen your recovery journey.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Support categories grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(supportCategories, id: \.id) { category in
                                    SupportCategoryCard(category: category)
                                        .onTapGesture {
                                            selectedCategory = category
                                        }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Personal support network
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Your Support Network")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(.systemGray6))
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        ForEach(1...2, id: \.self) { index in
                                            HStack {
                                                Image(systemName: "person.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                                
                                                VStack(alignment: .leading) {
                                                    Text(index == 1 ? "John Smith (Sponsor)" : "Dr. Emily Johnson")
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    
                                                    Text(index == 1 ? "Available 24/7" : "Next appointment: Friday 2pm")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    // Contact action
                                                }) {
                                                    Image(systemName: "phone.fill")
                                                        .foregroundColor(.blue)
                                                        .padding(8)
                                                        .background(Color.blue.opacity(0.1))
                                                        .cornerRadius(8)
                                                }
                                            }
                                            
                                            if index == 1 {
                                                Divider()
                                            }
                                        }
                                        
                                        Button(action: {
                                            // Add contact action
                                        }) {
                                            HStack {
                                                Image(systemName: "plus.circle.fill")
                                                Text("Add Support Contact")
                                                    .fontWeight(.medium)
                                            }
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 5)
                                        }
                                    }
                                    .padding()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitle("Support", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                if selectedCategory != nil {
                    selectedCategory = nil
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        }
    }
}

struct SupportCategory: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
}

struct SupportCategoryCard: View {
    let category: SupportCategory
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: category.icon)
                .font(.system(size: 30))
                .foregroundColor(category.color)
                .frame(width: 60, height: 60)
                .background(category.color.opacity(0.1))
                .cornerRadius(15)
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct SupportCategoryDetailView: View {
    let category: SupportCategory
    let onBack: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Category header
                HStack {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(category.color)
                        .cornerRadius(10)
                    
                    Text(category.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding()
                
                // Resources list
                VStack(alignment: .leading, spacing: 15) {
                    Text("Available Resources")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(1...4, id: \.self) { index in
                        resourceCard(for: index)
                    }
                }
                
                // How to use section
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to Use These Resources")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("These resources are designed to provide support during your recovery journey. Reach out whenever you need assistance, guidance, or just someone to talk to. Remember that seeking help is a sign of strength, not weakness.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
    
    @ViewBuilder
    private func resourceCard(for index: Int) -> some View {
        let (title, description) = resourceInfo(for: index, category: category)
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
            
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Button(action: {
                        // Contact or access resource
                    }) {
                        Text(contactButtonText(for: category))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(category.color)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Save or bookmark
                    }) {
                        Image(systemName: "bookmark")
                            .foregroundColor(category.color)
                    }
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    private func resourceInfo(for index: Int, category: SupportCategory) -> (String, String) {
        switch category.name {
        case "Therapy Resources":
            let titles = ["Online Therapy Platform", "Find a Local Therapist", "Addiction Counseling", "Cognitive Behavioral Therapy"]
            let descriptions = [
                "Connect with licensed therapists specializing in addiction recovery through secure video sessions.",
                "Directory of therapists in your area who specialize in addiction and recovery.",
                "Specialized counseling focused on addiction recovery and relapse prevention.",
                "Evidence-based therapy techniques to change negative thought patterns."
            ]
            return (titles[index-1], descriptions[index-1])
            
        case "Support Groups":
            let titles = ["Virtual Recovery Meetings", "Local Support Groups", "Family Support Circle", "Peer Recovery Network"]
            let descriptions = [
                "Online meetings available 24/7 for support during your recovery journey.",
                "In-person groups in your community that meet weekly for mutual support.",
                "Support groups specifically for family members of those in recovery.",
                "Connect with peers who understand your experiences and can offer guidance."
            ]
            return (titles[index-1], descriptions[index-1])
            
        case "Crisis Helplines":
            let titles = ["24/7 Crisis Hotline", "Text Support Line", "Suicide Prevention Lifeline", "Substance Abuse Helpline"]
            let descriptions = [
                "Immediate support available any time of day or night when you're in crisis.",
                "Text-based support for those who prefer not to speak on the phone.",
                "Specialized support for those experiencing suicidal thoughts.",
                "Expert guidance for substance abuse emergencies and questions."
            ]
            return (titles[index-1], descriptions[index-1])
            
        case "Educational Content":
            let titles = ["Recovery Fundamentals", "Understanding Triggers", "Healthy Coping Mechanisms", "Relapse Prevention"]
            let descriptions = [
                "Essential information about the recovery process and what to expect.",
                "Learn to identify and manage triggers that lead to urges.",
                "Develop healthy alternatives to cope with stress and difficult emotions.",
                "Strategies and techniques to prevent relapse and maintain sobriety."
            ]
            return (titles[index-1], descriptions[index-1])
            
        case "Community Forum":
            let titles = ["Recovery Discussion Board", "Success Stories Thread", "Accountability Partners", "Ask the Experts"]
            let descriptions = [
                "Connect with others in recovery to share experiences and advice.",
                "Read and share stories of recovery milestones and achievements.",
                "Find someone to check in with regularly and keep you accountable.",
                "Ask questions and get answers from recovery professionals."
            ]
            return (titles[index-1], descriptions[index-1])
            
        default:
            return ("Resource \(index)", "Description for resource \(index)")
        }
    }
    
    private func contactButtonText(for category: SupportCategory) -> String {
        switch category.name {
        case "Therapy Resources":
            return "Schedule"
        case "Support Groups":
            return "Join"
        case "Crisis Helplines":
            return "Call Now"
        case "Educational Content":
            return "Read More"
        case "Community Forum":
            return "Participate"
        default:
            return "Connect"
        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
} 