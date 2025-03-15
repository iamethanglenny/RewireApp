import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate: Date = Date()
    @State private var showingDailyLog = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Month selector
                HStack {
                    Button(action: viewModel.previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: viewModel.nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                
                // Day of week headers
                HStack(spacing: 0) {
                    ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(viewModel.daysInMonth, id: \.self) { day in
                        if let date = day {
                            CalendarDayView(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                vapingStatus: viewModel.vapingStatus(for: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                                showingDailyLog = true
                            }
                        } else {
                            // Empty cell for days not in current month
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 40)
                        }
                    }
                }
                
                Spacer()
                
                // Legend
                HStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                        Text("Vape-free")
                            .font(.caption)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                        Text("Vaped")
                            .font(.caption)
                    }
                    
                    HStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 12, height: 12)
                        Text("No data")
                            .font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Calendar")
            .onAppear {
                viewModel.loadCalendarData()
            }
            .sheet(isPresented: $showingDailyLog) {
                DailyLogView(date: selectedDate) {
                    viewModel.loadCalendarData()
                }
            }
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let vapingStatus: VapingStatus
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(textColor)
        }
        .frame(height: 40)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var backgroundColor: Color {
        switch vapingStatus {
        case .vaped:
            return .red.opacity(0.7)
        case .vapeFree:
            return .green.opacity(0.7)
        case .noData:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch vapingStatus {
        case .vaped, .vapeFree:
            return .white
        case .noData:
            return isToday ? .blue : .primary
        }
    }
}

enum VapingStatus {
    case vaped, vapeFree, noData
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
} 