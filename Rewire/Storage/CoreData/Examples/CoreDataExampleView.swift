import SwiftUI
import CoreData

struct CoreDataExampleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyLog.date, ascending: false)],
        animation: .default)
    private var dailyLogs: FetchedResults<DailyLog>
    
    @State private var showingAddForm = false
    @State private var noteText = ""
    @State private var stayedClean = true
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dailyLogs) { log in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(formatDate(log.date ?? Date()))
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: log.stayedClean ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(log.stayedClean ? .green : .red)
                        }
                        
                        if let note = log.note, !note.isEmpty {
                            Text(note)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        if let cravings = log.cravings as? Set<CravingRecord>, !cravings.isEmpty {
                            Text("Cravings: \(cravings.count)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteDailyLogs)
            }
            .navigationTitle("Daily Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddForm = true }) {
                        Label("Add Log", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                addDailyLogForm
            }
        }
    }
    
    private var addDailyLogForm: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Details")) {
                    Toggle("Stayed Clean", isOn: $stayedClean)
                    
                    TextField("Notes", text: $noteText)
                }
                
                Button("Save") {
                    addDailyLog()
                    showingAddForm = false
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("New Daily Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingAddForm = false
                    }
                }
            }
        }
    }
    
    private func addDailyLog() {
        withAnimation {
            let newLog = DailyLog(context: viewContext)
            newLog.id = UUID().uuidString
            newLog.date = Date()
            newLog.stayedClean = stayedClean
            newLog.note = noteText
            newLog.userId = "current-user-id" // In a real app, get this from user state
            
            // Create wellbeing ratings
            let ratings = WellbeingRatings(context: viewContext)
            ratings.id = UUID().uuidString
            ratings.mood = 3
            ratings.energy = 3
            ratings.sleep = 3
            ratings.cravingIntensity = 3
            ratings.dailyLog = newLog
            newLog.wellbeingRatings = ratings
            
            do {
                try viewContext.save()
                
                // Reset form
                noteText = ""
                stayedClean = true
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteDailyLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { dailyLogs[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct CoreDataExampleView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataExampleView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 