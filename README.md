# Glucose Tracker iOS App

A voice-enabled iOS app for tracking meal glucose content to help monitor dietary glucose intake.

## Features

- **Voice Recognition**: Use speech-to-text to quickly log meals by speaking what you ate
- **Automatic Glucose Estimation**: Built-in food database with glucose content estimates
- **Meal Tracking**: Categorize meals by type (breakfast, lunch, dinner, snack)
- **Analytics Dashboard**: View daily, weekly glucose intake summaries
- **Data Export**: Export your meal history as CSV for further analysis
- **Local Storage**: All data stored securely on your device

## Screenshots

The app includes:
- Voice recording interface with visual feedback
- Meal history with detailed breakdowns
- Analytics with charts and summaries
- Settings for data management

## Requirements

- iOS 15.0 or later
- iPhone or iPad with microphone access
- Speech recognition permissions

## Setup Instructions

### 1. Open in Xcode

1. Clone or download this repository
2. Open `GlucoseTracker.xcodeproj` in Xcode 15 or later
3. Select your development team in the project settings
4. Update the bundle identifier to something unique (e.g., `com.yourname.GlucoseTracker`)

### 2. Permissions Setup

The app requires two key permissions that are already configured in `Info.plist`:

- **Microphone Access**: `NSMicrophoneUsageDescription`
- **Speech Recognition**: `NSSpeechRecognitionUsageDescription`

### 3. Build and Run

1. Select a target device (iPhone/iPad or Simulator)
2. Press `Cmd+R` to build and run
3. Grant microphone and speech recognition permissions when prompted

## How to Use

### Recording Meals

1. Select the meal type (breakfast, lunch, dinner, or snack)
2. Tap the microphone button to start recording
3. Speak clearly what you ate, for example:
   - "I had a medium apple and two slices of bread"
   - "Large bowl of rice with grilled chicken"
   - "One banana and a cup of milk"
4. The app will automatically:
   - Recognize food items from your speech
   - Estimate portion sizes based on your description
   - Calculate total glucose content
   - Save the meal entry

### Voice Input Tips

- Speak clearly and at normal pace
- Include quantity indicators like "one", "two", "large", "small", "cup", "bowl"
- Use common food names (the app recognizes many aliases)
- Examples of good voice input:
  - "One large apple"
  - "Two cups of white rice"
  - "Small piece of grilled salmon with vegetables"
  - "Half a cup of blueberries"

### Viewing History

- Check the "History" tab to see all logged meals
- Each entry shows:
  - Meal type and timestamp
  - Recognized foods
  - Original voice input
  - Total glucose content
- Swipe to delete entries

### Analytics

- View daily glucose totals
- See weekly summaries
- Track average glucose per meal
- Monitor eating patterns

## Food Database

The app includes a comprehensive food database with glucose content estimates for:

- **Fruits**: Apples, bananas, oranges, berries, grapes
- **Vegetables**: Carrots, broccoli, sweet potatoes, corn
- **Grains**: Rice, bread, pasta, quinoa, oats
- **Proteins**: Chicken, salmon, eggs, beans, tofu
- **Dairy**: Milk, yogurt, cheese
- **Snacks**: Nuts, chips, crackers
- **Beverages**: Juices, sodas, coffee
- **Sweets**: Chocolate, ice cream, cookies

## Technical Architecture

### Core Components

- **VoiceRecognitionService**: Handles speech-to-text conversion using iOS Speech framework
- **FoodDatabase**: Contains nutritional data and food recognition logic
- **MealTracker**: Manages meal entries, data persistence, and analytics
- **ContentView**: SwiftUI-based user interface with tabs for different functions

### Data Models

- **FoodItem**: Represents individual foods with glucose content
- **MealEntry**: Complete meal record with timestamp, foods, and calculations
- **MealType**: Enumeration for breakfast, lunch, dinner, snack
- **DailySummary**: Aggregated daily statistics

### Data Storage

- Uses UserDefaults for local data persistence
- JSON encoding/decoding for meal entries
- No external dependencies required

## Customization

### Adding New Foods

You can extend the food database by modifying `FoodDatabase.swift`:

```swift
FoodItem(
    name: "New Food", 
    glucoseContentPerGram: 0.15, 
    category: .fruits, 
    aliases: ["alternative name"]
)
```

### Adjusting Portion Estimates

Modify the `estimateQuantity` method in `FoodDatabase.swift` to adjust default portion sizes or add new quantity keywords.

## Privacy & Security

- All data stored locally on device
- No data transmitted to external servers
- Speech recognition processed on-device when possible
- Users can export and delete their data anytime

## Future Enhancements

Potential features for future versions:

- Integration with nutrition APIs for more accurate data
- Barcode scanning for packaged foods
- Photo recognition for meal logging
- Health app integration
- Cloud sync across devices
- Custom food additions
- Glucose level tracking integration

## Troubleshooting

### Voice Recognition Not Working

1. Check microphone permissions in Settings > Privacy & Security > Microphone
2. Check speech recognition permissions in Settings > Privacy & Security > Speech Recognition
3. Ensure device is not in silent mode
4. Try speaking closer to the microphone

### Food Not Recognized

1. Try using simpler, more common food names
2. Speak clearly and at normal pace
3. Check if the food exists in the database
4. Use alternative names (e.g., "rice" instead of "jasmine rice")

### App Crashes

1. Restart the app
2. Check iOS version compatibility (requires iOS 15+)
3. Try clearing app data in Settings

## Contributing

This is a template project that can be extended and customized. Feel free to:

- Add more foods to the database
- Improve voice recognition accuracy
- Enhance the UI/UX
- Add new analytics features
- Implement additional data export formats

## License

This project is available under the MIT License. See LICENSE file for details.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the code comments for implementation details
3. Test with the iOS Simulator for development

---

**Disclaimer**: This app provides estimates for educational purposes. Consult healthcare professionals for medical advice regarding glucose monitoring and dietary management.