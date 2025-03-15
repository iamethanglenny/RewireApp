import Foundation

extension Date {
    // Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // Get end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // Get start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // Get end of week
    var endOfWeek: Date {
        var components = DateComponents()
        components.day = 7
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek) ?? self
    }
    
    // Get start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // Get end of month
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    // Format date to string
    func formatted(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Get days between two dates
    func daysBetween(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
    
    // Add days to date
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    // Check if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // Check if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    // Check if date is in current week
    var isInCurrentWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    // Check if date is in current month
    var isInCurrentMonth: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
} 