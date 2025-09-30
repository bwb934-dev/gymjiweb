# LazyGym Web App

A complete HTML/JavaScript replica of the LazyGym SwiftUI workout tracking app. This web version maintains all the core functionality of the original iOS app while being accessible from any modern web browser.

## Features

### 🏋️ Exercise Management
- **Create, edit, and delete exercises** with custom names and progression types
- **Three progression types**:
  - **AMRAP** (As Many Reps As Possible): 3×5 reps + 1 set to failure with automatic weight progression
  - **Pyramid**: Percentage-based rep scheme (100%, 70%, 50%, 50%) with performance tracking
  - **Free**: Manual progression without automatic weight increases
- **Body part classification**: Upper body, Lower body, or Full body
- **Weight and rep tracking** with intelligent progression algorithms

### 📋 Workout Templates
- **Create custom workout templates** combining multiple exercises
- **Workout focus options**: Upper body, Lower body, or Full body workouts
- **Exercise preview** showing included exercises and progression types
- **Quick workout selection** with one-click start

### 🏃 Active Workout Tracking
- **Real-time workout timer** with pause/resume functionality
- **Set-by-set tracking** with planned vs actual reps
- **Dynamic weight adjustment** during workouts
- **Rest timer** with customizable duration and skip option
- **Progress tracking** through exercises and sets
- **Workout completion** with automatic progression updates

### 📊 Analytics & History
- **Workout history** with detailed session information
- **Performance analytics** including:
  - Total workouts completed
  - Average workouts per week
  - Heaviest lift achieved
  - Longest workout streak
- **Exercise progression charts** showing weight, reps, and volume over time
- **Data export** functionality for backup and analysis

### 💾 Data Management
- **Local storage** - All data is saved locally in your browser
- **Data export/import** - Backup and restore your workout data
- **Automatic progression** - Smart weight increases based on performance
- **Data persistence** - Workouts and exercises are automatically saved

## Getting Started

### Installation
1. **Download the files** to your computer
2. **Open `index.html`** in any modern web browser
3. **Start using** - No installation or setup required!

### First Steps
1. **Add exercises** - Go to the Exercises tab and add your favorite exercises
2. **Create workouts** - Build workout templates combining your exercises
3. **Start training** - Use the Home tab to begin your first workout
4. **Track progress** - View your history and analytics to see improvements

## How to Use

### Adding Exercises
1. Click the **"+ Add Exercise"** button in the Exercises tab
2. Fill in the exercise details:
   - **Name**: Exercise name (e.g., "Bench Press")
   - **Progression Type**: Choose AMRAP, Pyramid, or Free
   - **Body Part**: Upper, Lower, or Full body
   - **Current Weight**: Starting weight in kg
   - **Base Reps**: For Pyramid progression only
3. Click **"Add Exercise"** to save

### Creating Workouts
1. Click the **"+ Add Workout"** button in the Workouts tab
2. Enter workout details:
   - **Name**: Workout name (e.g., "Upper Body Day")
   - **Focus**: Choose Upper, Lower, or Full body
   - **Exercises**: Select exercises to include
3. Click **"Add Workout"** to save

### Starting a Workout
1. Go to the **Home tab**
2. Click **"Start Workout"**
3. Select a workout template
4. Follow the guided workout flow:
   - Complete sets as instructed
   - Enter actual reps performed
   - Use the rest timer between sets
   - Adjust weights as needed

### Understanding Progression

#### AMRAP Progression
- **Structure**: 3 sets of 5 reps + 1 set to failure
- **Weight increases**:
  - Final set < 5 reps: No increase
  - Final set 5-9 reps: +1kg (upper) or +2.5kg (lower)
  - Final set ≥ 10 reps: +2kg (upper) or +5kg (lower)

#### Pyramid Progression
- **Structure**: 100%, 70%, 50%, 50% of base reps
- **Tracking**: Uses actual reps from previous workout
- **Adaptation**: Automatically adjusts based on performance

#### Free Progression
- **Structure**: Same as AMRAP (3×5 + failure set)
- **Manual**: No automatic weight increases
- **Flexibility**: Complete control over progression

## Keyboard Shortcuts

- **Ctrl/Cmd + 1**: Switch to Home tab
- **Ctrl/Cmd + 2**: Switch to Workouts tab
- **Ctrl/Cmd + 3**: Switch to Exercises tab
- **Ctrl/Cmd + 4**: Switch to History tab
- **Ctrl/Cmd + S**: Start workout (or continue active workout)
- **Escape**: Close modals

## Browser Compatibility

- **Chrome** 80+ ✅
- **Firefox** 75+ ✅
- **Safari** 13+ ✅
- **Edge** 80+ ✅

## Data Storage

All data is stored locally in your browser using localStorage. This means:
- ✅ **Privacy**: Your data never leaves your device
- ✅ **Speed**: Instant access to your workouts
- ✅ **Offline**: Works without internet connection
- ⚠️ **Backup**: Export your data regularly for backup

## Exporting Data

1. Go to the **History tab**
2. Click **"Export Data"**
3. A JSON file will be downloaded with all your data
4. Keep this file safe as a backup

## Technical Details

### Architecture
- **Frontend**: Pure HTML, CSS, and JavaScript (ES6+)
- **Storage**: Browser localStorage for data persistence
- **Charts**: Chart.js for analytics visualization
- **Design**: Modern CSS with CSS Grid and Flexbox
- **Responsive**: Mobile-first design that works on all devices

### File Structure
```
lazygym-web/
├── index.html          # Main HTML file
├── styles.css          # All CSS styles
├── js/
│   ├── models.js       # Data models and classes
│   ├── dataManager.js  # Data persistence and management
│   ├── progressionCalculator.js # Progression logic
│   ├── ui.js          # UI management and interactions
│   └── app.js         # Main app initialization
└── README.md          # This file
```

## Differences from SwiftUI Version

### Maintained Features
- ✅ All exercise types and progression systems
- ✅ Complete workout tracking functionality
- ✅ Analytics and history features
- ✅ Data persistence and export
- ✅ Modern, responsive UI design

### Web-Specific Improvements
- 🌐 **Cross-platform**: Works on any device with a browser
- 📱 **Responsive**: Optimized for mobile, tablet, and desktop
- ⌨️ **Keyboard shortcuts**: Enhanced productivity
- 🔄 **Auto-save**: Continuous data saving
- 📊 **Enhanced charts**: Better data visualization

### Limitations
- ❌ No native iOS notifications
- ❌ No Apple Health integration
- ❌ No haptic feedback
- ❌ Requires browser (not a native app)

## Troubleshooting

### Data Not Saving
- Check if localStorage is enabled in your browser
- Ensure you're not in private/incognito mode
- Try refreshing the page

### Charts Not Loading
- Ensure JavaScript is enabled
- Check browser console for errors
- Try a different browser

### Performance Issues
- Clear browser cache and reload
- Close other browser tabs
- Restart your browser

## Contributing

This is a replica of the original SwiftUI app. If you find bugs or have suggestions:
1. Check the browser console for error messages
2. Try the troubleshooting steps above
3. Report issues with browser and device information

## License

This project replicates the functionality of the LazyGym SwiftUI app for web use. All rights reserved to the original app creator.

---

**Enjoy your workouts with LazyGym Web! 🏋️‍♂️💪**
