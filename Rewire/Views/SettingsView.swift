import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingQuitDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Vaping Cost")) {
                    HStack {
                        Text("Daily cost")
                        Spacer()
                        TextField("0.00", value: $viewModel.dailyVapingCost, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Quit Date")) {
                    HStack {
                        Text("Quit date")
                        Spacer()
                        Button(viewModel.quitDateFormatted) {
                            showingQuitDatePicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button("Export Data") {
                        viewModel.exportData()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Reset All Data") {
                        viewModel.showResetConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingQuitDatePicker) {
                NavigationView {
                    VStack {
                        DatePicker("Select Quit Date", selection: $viewModel.quitDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                    }
                    .navigationTitle("Quit Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingQuitDatePicker = false
                            }
                        }
                    }
                }
            }
            .alert("Reset All Data", isPresented: $viewModel.showResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your tracking data. This action cannot be undone.")
            }
            .alert("Data Exported", isPresented: $viewModel.showExportSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your data has been exported successfully.")
            }
            .onDisappear {
                viewModel.saveSettings()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 