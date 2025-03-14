import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var selectedTimeframe: Timeframe = .week
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe selector
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        Text("Week").tag(Timeframe.week)
                        Text("Month").tag(Timeframe.month)
                        Text("All Time").tag(Timeframe.allTime)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: selectedTimeframe) { _ in
                        viewModel.updateStats(for: selectedTimeframe)
                    }
                    
                    // Streak card
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current Streak")
                                    .font(.headline)
                                Text("\(viewModel.currentStreak) days")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Longest Streak")
                                    .font(.headline)
                                Text("\(viewModel.longestStreak) days")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        ProgressView(value: Double(viewModel.currentStreak), total: Double(max(viewModel.longestStreak, 1)))
                            .tint(.green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Success rate card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Success Rate")
                            .font(.headline)
                        
                        HStack(alignment: .lastTextBaseline) {
                            Text("\(Int(viewModel.successRate))%")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text("\(viewModel.vapeFreeCount)/\(viewModel.totalDays) days vape-free")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: viewModel.successRate, total: 100)
                            .tint(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Money saved card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Money Saved")
                            .font(.headline)
                        
                        HStack(alignment: .lastTextBaseline) {
                            Text("$\(viewModel.moneySaved, specifier: "%.2f")")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            if let dailyCost = viewModel.dailyVapingCost {
                                Text("$\(dailyCost, specifier: "%.2f") per day")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if viewModel.projectedYearlySavings > 0 {
                            Text("Projected yearly savings: $\(viewModel.projectedYearlySavings, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Wellbeing correlations
                    if !viewModel.correlations.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Wellbeing Impact")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            ForEach(viewModel.correlations.sorted(by: { abs($0.value) > abs($1.value) }), id: \.key) { key, value in
                                HStack {
                                    Text(key.capitalized)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    if value > 0 {
                                        Text("+\(value, specifier: "%.1f")")
                                            .foregroundColor(.green)
                                    } else if value < 0 {
                                        Text("\(value, specifier: "%.1f")")
                                            .foregroundColor(.red)
                                    } else {
                                        Text("No change")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                            
                            Text("These numbers show the average difference in scores between vape-free days and days when you vaped.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                viewModel.updateStats(for: selectedTimeframe)
            }
        }
    }
}

enum Timeframe {
    case week, month, allTime
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
} 