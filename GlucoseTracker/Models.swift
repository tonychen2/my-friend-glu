import Foundation
import CoreData

// MARK: - Food Item Model
struct FoodItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let glucoseContentPerGram: Double // grams of glucose per gram of food
    let category: FoodCategory
    let aliases: [String] // alternative names for voice recognition
    
    init(name: String, glucoseContentPerGram: Double, category: FoodCategory, aliases: [String] = []) {
        self.name = name
        self.glucoseContentPerGram = glucoseContentPerGram
        self.category = category
        self.aliases = aliases
    }
}

// MARK: - Food Categories
enum FoodCategory: String, CaseIterable, Codable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case grains = "Grains"
    case proteins = "Proteins"
    case dairy = "Dairy"
    case sweets = "Sweets"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case other = "Other"
}

// MARK: - Meal Type
enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        }
    }
}

// MARK: - Meal Entry
struct MealEntry: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let mealType: MealType
    let foodItems: [FoodItem]
    let quantities: [UUID: Double] // foodItem.id -> quantity in grams
    let voiceInput: String
    let totalGlucoseContent: Double
    let notes: String?
    
    init(mealType: MealType, foodItems: [FoodItem], quantities: [UUID: Double], voiceInput: String, notes: String? = nil) {
        self.timestamp = Date()
        self.mealType = mealType
        self.foodItems = foodItems
        self.quantities = quantities
        self.voiceInput = voiceInput
        self.notes = notes
        
        // Calculate total glucose content
        self.totalGlucoseContent = foodItems.reduce(0) { total, food in
            let quantity = quantities[food.id] ?? 0
            return total + (food.glucoseContentPerGram * quantity)
        }
    }
}

// MARK: - Daily Summary
struct DailySummary: Identifiable {
    let id = UUID()
    let date: Date
    let meals: [MealEntry]
    let totalGlucose: Double
    let mealCount: Int
    
    init(date: Date, meals: [MealEntry]) {
        self.date = date
        self.meals = meals
        self.totalGlucose = meals.reduce(0) { $0 + $1.totalGlucoseContent }
        self.mealCount = meals.count
    }
}

// MARK: - Voice Recognition Result
struct VoiceRecognitionResult {
    let transcription: String
    let confidence: Float
    let timestamp: Date
    
    init(transcription: String, confidence: Float) {
        self.transcription = transcription
        self.confidence = confidence
        self.timestamp = Date()
    }
}

// MARK: - Food Recognition Result
struct FoodRecognitionResult {
    let recognizedFoods: [FoodItem]
    let estimatedQuantities: [UUID: Double] // foodItem.id -> estimated quantity in grams
    let confidence: Float
    let originalText: String
    
    init(recognizedFoods: [FoodItem], estimatedQuantities: [UUID: Double], confidence: Float, originalText: String) {
        self.recognizedFoods = recognizedFoods
        self.estimatedQuantities = estimatedQuantities
        self.confidence = confidence
        self.originalText = originalText
    }
}