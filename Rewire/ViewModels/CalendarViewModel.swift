import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    private let analyticsService = AnalyticsService.shared
    private let calendar = Calendar.current
    
    @Published var currentMonth: Date = Date()
    @Published var daysInMonth: [Date?] = []
    @Published var calendarData: [Date: Bool] = [:]
    
    var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    init() {
        generateDaysInMonth()
    }
    
    func loadCalendarData() {
        calendarData = analyticsService.getCalendarData(for: currentMonth)
        objectWillChange.send()
    }
    
    func vapingStatus(for date: Date) -> VapingStatus {
        let normalizedDate = date.startOfDay
        
        if let didVape = calendarData[normalizedDate] {
            return didVape ? .vaped : .vapeFree
        } else {
            return .noData
        }
    }
    
    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            generateDaysInMonth()
            loadCalendarData()
        }
    }
    
    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            generateDaysInMonth()
            loadCalendarData()
        }
    }
    
    private func generateDaysInMonth() {
        daysInMonth = []
        
        let startOfMonth = currentMonth.startOfMonth
        let endOfMonth = currentMonth.endOfMonth
        
        // Get the first day of the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Account for the weekday offset (if first day is not Sunday)
        let weekdayOffset = firstWeekday - 1
        
        // Add empty cells for days before the first of the month
        for _ in 0..<weekdayOffset {
            daysInMonth.append(nil)
        }
        
        // Add all days in the month
        let daysRange = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in daysRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                daysInMonth.append(date)
            }
        }
        
        // Calculate how many cells we need to fill the last row
        let remainingCells = (7 - (daysInMonth.count % 7)) % 7
        
        // Add empty cells for days after the end of the month
        for _ in 0..<remainingCells {
            daysInMonth.append(nil)
        }
    }
} 