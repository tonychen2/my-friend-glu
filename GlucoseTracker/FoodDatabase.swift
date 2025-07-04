import Foundation

class FoodDatabase: ObservableObject {
    
    // MARK: - Singleton
    static let shared = FoodDatabase()
    
    // MARK: - Properties
    @Published var foodItems: [FoodItem] = []
    
    private init() {
        loadFoodDatabase()
    }
    
    // MARK: - Database Loading
    private func loadFoodDatabase() {
        foodItems = [
            // Fruits
            FoodItem(name: "Apple", glucoseContentPerGram: 0.10, category: .fruits, aliases: ["apples", "green apple", "red apple"]),
            FoodItem(name: "Banana", glucoseContentPerGram: 0.12, category: .fruits, aliases: ["bananas"]),
            FoodItem(name: "Orange", glucoseContentPerGram: 0.09, category: .fruits, aliases: ["oranges"]),
            FoodItem(name: "Grapes", glucoseContentPerGram: 0.16, category: .fruits, aliases: ["grape"]),
            FoodItem(name: "Strawberries", glucoseContentPerGram: 0.05, category: .fruits, aliases: ["strawberry"]),
            FoodItem(name: "Blueberries", glucoseContentPerGram: 0.10, category: .fruits, aliases: ["blueberry"]),
            
            // Vegetables
            FoodItem(name: "Carrot", glucoseContentPerGram: 0.05, category: .vegetables, aliases: ["carrots"]),
            FoodItem(name: "Broccoli", glucoseContentPerGram: 0.02, category: .vegetables, aliases: ["broccolis"]),
            FoodItem(name: "Spinach", glucoseContentPerGram: 0.01, category: .vegetables, aliases: ["spinach leaves"]),
            FoodItem(name: "Sweet Potato", glucoseContentPerGram: 0.15, category: .vegetables, aliases: ["sweet potatoes", "yam"]),
            FoodItem(name: "Corn", glucoseContentPerGram: 0.19, category: .vegetables, aliases: ["corn kernels", "sweet corn"]),
            
            // Grains
            FoodItem(name: "White Rice", glucoseContentPerGram: 0.78, category: .grains, aliases: ["rice", "steamed rice"]),
            FoodItem(name: "Brown Rice", glucoseContentPerGram: 0.65, category: .grains, aliases: ["brown rice"]),
            FoodItem(name: "Quinoa", glucoseContentPerGram: 0.58, category: .grains, aliases: ["quinoa"]),
            FoodItem(name: "Oats", glucoseContentPerGram: 0.55, category: .grains, aliases: ["oatmeal", "rolled oats"]),
            FoodItem(name: "Bread", glucoseContentPerGram: 0.50, category: .grains, aliases: ["white bread", "slice of bread", "toast"]),
            FoodItem(name: "Pasta", glucoseContentPerGram: 0.71, category: .grains, aliases: ["spaghetti", "noodles"]),
            
            // Proteins
            FoodItem(name: "Chicken Breast", glucoseContentPerGram: 0.00, category: .proteins, aliases: ["chicken", "grilled chicken"]),
            FoodItem(name: "Salmon", glucoseContentPerGram: 0.00, category: .proteins, aliases: ["grilled salmon", "baked salmon"]),
            FoodItem(name: "Eggs", glucoseContentPerGram: 0.01, category: .proteins, aliases: ["egg", "scrambled eggs", "boiled egg"]),
            FoodItem(name: "Tofu", glucoseContentPerGram: 0.02, category: .proteins, aliases: ["tofu"]),
            FoodItem(name: "Black Beans", glucoseContentPerGram: 0.16, category: .proteins, aliases: ["beans", "black bean"]),
            
            // Dairy
            FoodItem(name: "Milk", glucoseContentPerGram: 0.05, category: .dairy, aliases: ["whole milk", "skim milk", "2% milk"]),
            FoodItem(name: "Greek Yogurt", glucoseContentPerGram: 0.04, category: .dairy, aliases: ["yogurt", "plain yogurt"]),
            FoodItem(name: "Cheese", glucoseContentPerGram: 0.01, category: .dairy, aliases: ["cheddar cheese", "mozzarella"]),
            
            // Sweets
            FoodItem(name: "Chocolate", glucoseContentPerGram: 0.45, category: .sweets, aliases: ["dark chocolate", "milk chocolate"]),
            FoodItem(name: "Ice Cream", glucoseContentPerGram: 0.22, category: .sweets, aliases: ["vanilla ice cream"]),
            FoodItem(name: "Cookie", glucoseContentPerGram: 0.68, category: .sweets, aliases: ["cookies", "chocolate chip cookie"]),
            
            // Beverages
            FoodItem(name: "Orange Juice", glucoseContentPerGram: 0.08, category: .beverages, aliases: ["OJ", "fresh orange juice"]),
            FoodItem(name: "Soda", glucoseContentPerGram: 0.11, category: .beverages, aliases: ["cola", "soft drink", "coke"]),
            FoodItem(name: "Coffee", glucoseContentPerGram: 0.00, category: .beverages, aliases: ["black coffee"]),
            
            // Snacks
            FoodItem(name: "Almonds", glucoseContentPerGram: 0.05, category: .snacks, aliases: ["almond", "raw almonds"]),
            FoodItem(name: "Potato Chips", glucoseContentPerGram: 0.50, category: .snacks, aliases: ["chips", "crisps"]),
            FoodItem(name: "Crackers", glucoseContentPerGram: 0.68, category: .snacks, aliases: ["saltine crackers", "wheat crackers"])
        ]
    }
    
    // MARK: - Search Methods
    func searchFood(query: String) -> [FoodItem] {
        let lowercaseQuery = query.lowercased()
        
        return foodItems.filter { food in
            food.name.lowercased().contains(lowercaseQuery) ||
            food.aliases.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    func findExactFood(name: String) -> FoodItem? {
        let lowercaseName = name.lowercased()
        
        return foodItems.first { food in
            food.name.lowercased() == lowercaseName ||
            food.aliases.contains { $0.lowercased() == lowercaseName }
        }
    }
    
    // MARK: - Voice Input Processing
    func parseVoiceInput(_ input: String) -> FoodRecognitionResult {
        let words = input.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var recognizedFoods: [FoodItem] = []
        var estimatedQuantities: [UUID: Double] = [:]
        var confidence: Float = 0.0
        var matchCount = 0
        
        // Process each word and phrase to find food matches
        for i in 0..<words.count {
            // Try single words first
            if let food = findFoodInWords(Array(words[i...i])) {
                recognizedFoods.append(food)
                estimatedQuantities[food.id] = estimateQuantity(from: input, for: food)
                matchCount += 1
            }
            
            // Try two-word combinations
            if i < words.count - 1 {
                if let food = findFoodInWords(Array(words[i...i+1])) {
                    if !recognizedFoods.contains(where: { $0.id == food.id }) {
                        recognizedFoods.append(food)
                        estimatedQuantities[food.id] = estimateQuantity(from: input, for: food)
                        matchCount += 1
                    }
                }
            }
            
            // Try three-word combinations
            if i < words.count - 2 {
                if let food = findFoodInWords(Array(words[i...i+2])) {
                    if !recognizedFoods.contains(where: { $0.id == food.id }) {
                        recognizedFoods.append(food)
                        estimatedQuantities[food.id] = estimateQuantity(from: input, for: food)
                        matchCount += 1
                    }
                }
            }
        }
        
        // Calculate confidence based on how many words matched food items
        confidence = words.isEmpty ? 0.0 : Float(matchCount) / Float(words.count)
        
        return FoodRecognitionResult(
            recognizedFoods: recognizedFoods,
            estimatedQuantities: estimatedQuantities,
            confidence: min(confidence, 1.0),
            originalText: input
        )
    }
    
    private func findFoodInWords(_ words: [String]) -> FoodItem? {
        let phrase = words.joined(separator: " ")
        
        return foodItems.first { food in
            food.name.lowercased() == phrase ||
            food.aliases.contains { $0.lowercased() == phrase }
        }
    }
    
    private func estimateQuantity(from input: String, for food: FoodItem) -> Double {
        let lowercaseInput = input.lowercased()
        
        // Look for quantity indicators in the voice input
        let quantityPatterns = [
            ("one", 100.0),
            ("two", 200.0),
            ("three", 300.0),
            ("half", 50.0),
            ("small", 80.0),
            ("medium", 150.0),
            ("large", 250.0),
            ("cup", 240.0),
            ("tablespoon", 15.0),
            ("teaspoon", 5.0),
            ("slice", 30.0),
            ("piece", 100.0),
            ("handful", 50.0),
            ("bowl", 200.0),
            ("plate", 300.0)
        ]
        
        for (pattern, quantity) in quantityPatterns {
            if lowercaseInput.contains(pattern) {
                return quantity
            }
        }
        
        // Default quantity based on food category
        switch food.category {
        case .fruits:
            return 150.0 // medium fruit
        case .vegetables:
            return 100.0 // serving of vegetables
        case .grains:
            return 200.0 // cooked portion
        case .proteins:
            return 120.0 // protein serving
        case .dairy:
            return 240.0 // cup equivalent
        case .sweets:
            return 50.0 // small portion
        case .beverages:
            return 240.0 // cup
        case .snacks:
            return 30.0 // small snack portion
        case .other:
            return 100.0 // default
        }
    }
    
    // MARK: - Utility Methods
    func getFoodsByCategory(_ category: FoodCategory) -> [FoodItem] {
        return foodItems.filter { $0.category == category }
    }
    
    func addCustomFood(_ food: FoodItem) {
        foodItems.append(food)
    }
}