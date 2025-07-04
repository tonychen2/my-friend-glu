import SwiftUI

struct ContentView: View {
    @StateObject private var mealTracker = MealTracker()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Log Meal Tab
            LogMealView(mealTracker: mealTracker)
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Log Meal")
                }
                .tag(0)
            
            // MARK: - History Tab
            HistoryView(mealTracker: mealTracker)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }
                .tag(1)
            
            // MARK: - Analytics Tab
            AnalyticsView(mealTracker: mealTracker)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(2)
            
            // MARK: - Settings Tab
            SettingsView(mealTracker: mealTracker)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Log Meal View
struct LogMealView: View {
    @ObservedObject var mealTracker: MealTracker
    @State private var showingMealTypePicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Meal Type Selection
                HStack {
                    Text("Meal Type:")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingMealTypePicker = true }) {
                        HStack {
                            Text(mealTracker.currentMealType.emoji)
                            Text(mealTracker.currentMealType.rawValue)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Voice Recording Section
                VStack(spacing: 15) {
                    if mealTracker.isVoiceAuthorized {
                        // Recording Button
                        Button(action: {
                            if mealTracker.isRecording {
                                mealTracker.stopVoiceInput()
                            } else {
                                mealTracker.startVoiceInput()
                            }
                        }) {
                            VStack {
                                Image(systemName: mealTracker.isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 50))
                                    .foregroundColor(mealTracker.isRecording ? .red : .blue)
                                
                                Text(mealTracker.isRecording ? "Recording..." : "Tap to record meal")
                                    .font(.headline)
                                    .foregroundColor(mealTracker.isRecording ? .red : .primary)
                            }
                            .frame(width: 200, height: 200)
                            .background(
                                Circle()
                                    .fill(mealTracker.isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                                    .scaleEffect(mealTracker.isRecording ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: mealTracker.isRecording)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Live Transcription
                        if mealTracker.isRecording && !mealTracker.currentTranscription.isEmpty {
                            Text("\"" + mealTracker.currentTranscription + "\"")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    } else {
                        VStack {
                            Image(systemName: "mic.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Microphone access required")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Please enable microphone and speech recognition in Settings")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                Spacer()
                
                // Recent Glucose Info
                VStack {
                    HStack {
                        Text("Today's Glucose:")
                            .font(.headline)
                        Spacer()
                        Text("\(String(format: "%.1f", mealTracker.getTotalGlucoseToday()))g")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Glucose Tracker")
            .sheet(isPresented: $showingMealTypePicker) {
                MealTypePickerView(selectedMealType: $mealTracker.currentMealType)
            }
            .overlay(
                Group {
                    if mealTracker.isLoading {
                        ProgressView("Processing...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
            .alert("Error", isPresented: .constant(mealTracker.errorMessage != nil)) {
                Button("OK") {
                    mealTracker.errorMessage = nil
                }
            } message: {
                Text(mealTracker.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Meal Type Picker
struct MealTypePickerView: View {
    @Binding var selectedMealType: MealType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(MealType.allCases, id: \.self) { mealType in
                Button(action: {
                    selectedMealType = mealType
                    dismiss()
                }) {
                    HStack {
                        Text(mealType.emoji)
                            .font(.title2)
                        Text(mealType.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedMealType == mealType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Meal Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @ObservedObject var mealTracker: MealTracker
    
    var body: some View {
        NavigationView {
            List {
                ForEach(mealTracker.mealEntries) { meal in
                    MealEntryRow(meal: meal)
                }
                .onDelete(perform: deleteMeals)
            }
            .navigationTitle("Meal History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteMeals(offsets: IndexSet) {
        for index in offsets {
            mealTracker.deleteMealEntry(mealTracker.mealEntries[index])
        }
    }
}

// MARK: - Meal Entry Row
struct MealEntryRow: View {
    let meal: MealEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meal.mealType.emoji)
                    .font(.title2)
                Text(meal.mealType.rawValue)
                    .font(.headline)
                Spacer()
                Text(meal.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Foods: " + meal.foodItems.map { $0.name }.joined(separator: ", "))
                .font(.body)
                .foregroundColor(.primary)
            
            Text("Voice: \"\(meal.voiceInput)\"")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
            
            HStack {
                Text("Glucose: \(String(format: "%.1f", meal.totalGlucoseContent))g")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                if let notes = meal.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    @ObservedObject var mealTracker: MealTracker
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Summary
                    SummaryCard(
                        title: "Today",
                        value: String(format: "%.1f", mealTracker.getTotalGlucoseToday()),
                        unit: "g glucose",
                        color: .blue
                    )
                    
                    // Average per meal
                    SummaryCard(
                        title: "Average per Meal",
                        value: String(format: "%.1f", mealTracker.getAverageGlucosePerMeal()),
                        unit: "g glucose",
                        color: .green
                    )
                    
                    // Total meals logged
                    SummaryCard(
                        title: "Total Meals",
                        value: "\(mealTracker.mealEntries.count)",
                        unit: "entries",
                        color: .orange
                    )
                    
                    // Weekly summary
                    WeeklySummaryView(mealTracker: mealTracker)
                }
                .padding()
            }
            .navigationTitle("Analytics")
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Weekly Summary
struct WeeklySummaryView: View {
    @ObservedObject var mealTracker: MealTracker
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week")
                .font(.headline)
                .padding(.bottom, 10)
            
            ForEach(mealTracker.getWeeklySummary()) { dailySummary in
                HStack {
                    Text(dailySummary.date, format: .dateTime.weekday(.wide))
                        .frame(width: 80, alignment: .leading)
                    
                    Text("\(dailySummary.mealCount) meals")
                        .frame(width: 70, alignment: .leading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.1f", dailySummary.totalGlucose))g")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var mealTracker: MealTracker
    @State private var showingExportSheet = false
    @State private var exportText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Data") {
                    Button("Export Data") {
                        exportText = mealTracker.exportData()
                        showingExportSheet = true
                    }
                    
                    Button("Clear All Data", role: .destructive) {
                        mealTracker.clearAllData()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                NavigationView {
                    ScrollView {
                        Text(exportText)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                    }
                    .navigationTitle("Export Data")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingExportSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}