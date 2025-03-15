import SwiftUI

struct DailyLogView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DailyLogViewModel()
    
    var date: Date
    var onSave: (() -> Void)?
    
    init(date: Date = Date(), onSave: (() -> Void)? = nil) {
        self.date = date
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date")) {
                    Text(date.formattedString(style: .full))
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Did you vape today?")) {
                    Toggle("I vaped today", isOn: $viewModel.didVape)
                        .tint(.red)
                }
                
                Section(header: Text("How are you feeling?")) {
                    VStack(alignment: .leading) {
                        Text("Mood")
                            .font(.headline)
                        ScoreSlider(value: $viewModel.moodScore, color: .blue)
                        Text(viewModel.moodDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Energy")
                            .font(.headline)
                        ScoreSlider(value: $viewModel.energyScore, color: .green)
                        Text(viewModel.energyDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Sleep Quality")
                            .font(.headline)
                        ScoreSlider(value: $viewModel.sleepScore, color: .purple)
                        Text(viewModel.sleepDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Cravings Intensity")
                            .font(.headline)
                        ScoreSlider(value: $viewModel.cravingsScore, color: .orange)
                        Text(viewModel.cravingsDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Notes"), footer: Text("\(140 - viewModel.notes.count) characters remaining")) {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .onChange(of: viewModel.notes) { newValue in
                            if newValue.count > 140 {
                                viewModel.notes = String(newValue.prefix(140))
                            }
                        }
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveDailyLog(for: date)
                        onSave?()
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadDailyLog(for: date)
            }
        }
    }
}

struct ScoreSlider: View {
    @Binding var value: Int
    var color: Color
    
    var body: some View {
        HStack {
            Text("1")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: 1...5,
                step: 1
            )
            .tint(color)
            
            Text("5")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 30)
        }
    }
}

struct DailyLogView_Previews: PreviewProvider {
    static var previews: some View {
        DailyLogView()
    }
} 