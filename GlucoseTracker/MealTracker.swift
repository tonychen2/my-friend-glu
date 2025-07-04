import Foundation
import SwiftUI

class MealTracker: ObservableObject {
    
    // MARK: - Published Properties
    @Published var mealEntries: [MealEntry] = []
    @Published var currentMealType: MealType = .breakfast
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let foodDatabase = FoodDatabase.shared
    private let voiceService = VoiceRecognitionService()
    
    // MARK: - UserDefaults Key
    private let mealEntriesKey = "SavedMealEntries"
    
    init() {
        loadMealEntries()
        setupVoiceService()
    }
    
    // MARK: - Setup
    private func setupVoiceService() {
        voiceService.onTranscriptionComplete = { [weak self] voiceResult in
            self?.processVoiceInput(voiceResult)
        }
    }
    
    // MARK: - Voice Input Processing
    func startVoiceInput() {
        voiceService.startRecording()
    }
    
    func stopVoiceInput() {
        voiceService.stopRecording()
    }
    
    private func processVoiceInput(_ voiceResult: VoiceRecognitionResult) {
        isLoading = true
        
        // Process the voice input to recognize foods
        let foodResult = foodDatabase.parseVoiceInput(voiceResult.transcription)
        
        if !foodResult.recognizedFoods.isEmpty {
            // Create a new meal entry
            let mealEntry = MealEntry(
                mealType: currentMealType,
                foodItems: foodResult.recognizedFoods,
                quantities: foodResult.estimatedQuantities,
                voiceInput: voiceResult.transcription,
                notes: "Confidence: \(Int(foodResult.confidence * 100))%"
            )
            
            addMealEntry(mealEntry)
        } else {
            errorMessage = "No food items recognized in: '\(voiceResult.transcription)'"
        }
        
        isLoading = false
    }
    
    // MARK: - Meal Management
    func addMealEntry(_ entry: MealEntry) {
        mealEntries.insert(entry, at: 0) // Add to beginning for chronological order
        saveMealEntries()
    }
    
    func deleteMealEntry(_ entry: MealEntry) {
        mealEntries.removeAll { $0.id == entry.id }
        saveMealEntries()
    }
    
    func updateMealEntry(_ entry: MealEntry, newNotes: String) {
        if let index = mealEntries.firstIndex(where: { $0.id == entry.id }) {
            var updatedEntry = entry
            // Since MealEntry is a struct, we need to create a new one
            let newEntry = MealEntry(
                mealType: entry.mealType,
                foodItems: entry.foodItems,
                quantities: entry.quantities,
                voiceInput: entry.voiceInput,
                notes: newNotes
            )
            mealEntries[index] = newEntry
            saveMealEntries()
        }
    }
    
    // MARK: - Data Persistence
    private func saveMealEntries() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(mealEntries)
            UserDefaults.standard.set(data, forKey: mealEntriesKey)
        } catch {
            errorMessage = "Failed to save meal entries: \(error.localizedDescription)"
        }
    }
    
    private func loadMealEntries() {
        guard let data = UserDefaults.standard.data(forKey: mealEntriesKey) else {
            // No saved data, start with empty array
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            mealEntries = try decoder.decode([MealEntry].self, from: data)
        } catch {
            errorMessage = "Failed to load meal entries: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Analytics
    func getDailySummary(for date: Date) -> DailySummary {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dayMeals = mealEntries.filter { meal in
            meal.timestamp >= startOfDay && meal.timestamp < endOfDay
        }
        
        return DailySummary(date: date, meals: dayMeals)
    }
    
    func getWeeklySummary() -> [DailySummary] {
        let calendar = Calendar.current
        let today = Date()
        var summaries: [DailySummary] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                summaries.append(getDailySummary(for: date))
            }
        }
        
        return summaries
    }
    
    func getTotalGlucoseToday() -> Double {
        return getDailySummary(for: Date()).totalGlucose
    }
    
    func getAverageGlucosePerMeal() -> Double {
        guard !mealEntries.isEmpty else { return 0 }
        let totalGlucose = mealEntries.reduce(0) { $0 + $1.totalGlucoseContent }
        return totalGlucose / Double(mealEntries.count)
    }
    
    func getMealsByType(_ type: MealType) -> [MealEntry] {
        return mealEntries.filter { $0.mealType == type }
    }
    
    // MARK: - Helper Methods
    func clearAllData() {
        mealEntries.removeAll()
        UserDefaults.standard.removeObject(forKey: mealEntriesKey)
    }
    
    func exportData() -> String {
        var exportString = "Date,Meal Type,Food Items,Voice Input,Glucose Content (g)\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        for meal in mealEntries {
            let foodNames = meal.foodItems.map { $0.name }.joined(separator: "; ")
            let row = "\(formatter.string(from: meal.timestamp)),\(meal.mealType.rawValue),\"\(foodNames)\",\"\(meal.voiceInput)\",\(String(format: "%.2f", meal.totalGlucoseContent))\n"
            exportString += row
        }
        
        return exportString
    }
    
    // MARK: - Voice Service Properties
    var isRecording: Bool {
        voiceService.isRecording
    }
    
    var currentTranscription: String {
        voiceService.transcription
    }
    
    var isVoiceAuthorized: Bool {
        voiceService.isAuthorized
    }
}