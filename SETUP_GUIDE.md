# SETUP GUIDE - SpotFinder

## Quick Start Guide

Follow these steps to get SpotFinder up and running:

### Step 1: Open the Project in Xcode

```bash
cd /Users/gustavocaldasdesouza/Workspace/SpotFinder
open SpotFinder.xcodeproj
```

### Step 2: Add New Files to Xcode Project

Since we've created new Swift files outside of Xcode, we need to add them to the project:

1. **In Xcode**, locate the "SpotFinder" folder in the Project Navigator (left sidebar)

2. **Right-click** on the "SpotFinder" folder → Select **"Add Files to 'SpotFinder'..."**

3. **Navigate** to the SpotFinder folder and select ALL these folders:

   - ✅ Models
   - ✅ Services
   - ✅ ViewModels
   - ✅ Views
   - ✅ Utilities

4. **Important Options** in the dialog:

   - ✅ Check "Copy items if needed"
   - ✅ Select "Create groups" (not folder references)
   - ✅ Ensure "SpotFinder" target is checked
   - ✅ Click "Add"

5. **Remove ContentView.swift**:
   - Find `ContentView.swift` in the project navigator
   - Right-click → Delete → Move to Trash
   - (We're using MapScreen.swift as the main view instead)

### Step 3: Configure Project Settings

1. **Select the SpotFinder project** in the navigator
2. **Select the SpotFinder target**
3. **Go to "Info" tab**
4. **Verify these entries exist** (they should be in Info.plist):
   - ✅ Privacy - Location When In Use Usage Description
   - ✅ Privacy - Location Always and When In Use Usage Description

### Step 4: Update API Configuration

If your backend is NOT running on localhost:3000, update the API URL:

1. Open `Utilities/AppConfiguration.swift`
2. Update these values:

```swift
static var apiBaseURL: String {
    #if DEBUG
    return "http://YOUR_BACKEND_IP:3000"  // e.g., "http://192.168.1.100:3000"
    #else
    return "https://your-production-api.com"
    #endif
}
```

### Step 5: Build and Run

1. **Select a simulator** or connected device (iOS 17+)
2. **Press Cmd + R** or click the Play button
3. **Grant location permission** when prompted

### Step 6: Test with Backend

Ensure your NestJS backend is running:

```bash
# In your backend project directory
npm run start:dev
```

The backend should be accessible at `http://localhost:3000`

## File Structure After Setup

Your Xcode project should look like this:

```
SpotFinder
├── SpotFinderApp.swift
├── Models
│   ├── ParkingReport.swift
│   ├── LocationPermissionStatus.swift
│   └── APIError.swift
├── Services
│   ├── APIClient.swift
│   ├── WebSocketManager.swift
│   └── LocationManager.swift
├── ViewModels
│   └── ParkingReportViewModel.swift
├── Views
│   ├── MapScreen.swift
│   ├── ReportSheet.swift
│   ├── SettingsView.swift
│   └── Components
│       ├── ParkingPinView.swift
│       ├── ReportCard.swift
│       └── ErrorBanner.swift
├── Utilities
│   └── AppConfiguration.swift
├── Assets.xcassets
└── Info.plist
```

## Troubleshooting Setup

### "No such module" errors

- Clean build folder: **Cmd + Shift + K**
- Ensure all files are added to the SpotFinder target
- Check that files show the target membership in File Inspector

### Build failures

- Verify you're using Xcode 15+ with Swift 6 support
- Check minimum deployment target is set to iOS 17.0
- Try deleting derived data: `~/Library/Developer/Xcode/DerivedData`

### Files show as red in Xcode

- The file reference path is broken
- Try removing and re-adding the files
- Ensure files are actually in the correct location on disk

### Location not working in simulator

- Go to simulator menu: Features → Location → Custom Location
- Enter coordinates: 37.7749, -122.4194 (San Francisco)

## Testing the App

### 1. Test Location Permission

- Launch app → Should request location permission
- Check Settings view → Should show "While Using" status

### 2. Test Map View

- Map should center on current location
- User location dot should be visible
- Map controls (compass, user location button) should work

### 3. Test Report Creation

- Tap "Report Spot" button
- Should auto-fill current coordinates
- Enter street name
- Submit → Should see success or error

### 4. Test Real-time Updates

- With backend running and WebSocket enabled
- Create report in backend or another device
- Should see new pin appear on map automatically

### 5. Test Rating System

- Tap on a report card
- Tap thumbs up/down
- Count should increment

## Development Workflow

### Making Changes

1. Edit files in Xcode (not external editor)
2. Build regularly to catch errors early
3. Test on simulator and real device
4. Use SwiftUI previews for rapid iteration

### Using Previews

Each view has a `#Preview` block:

```swift
#Preview {
    MapScreen()
}
```

- Click "Resume" in canvas to see live preview
- Great for UI tweaking without running the full app

### Debugging

- Set breakpoints by clicking line numbers
- Use `print()` statements temporarily
- Check console for API errors
- Use Xcode Instruments for performance

## Next Steps

Once the app is running:

1. **Test all features** systematically
2. **Configure your backend URL** for device testing
3. **Customize colors/styling** in view files
4. **Add more features** from the roadmap
5. **Write unit tests** for ViewModels

## Getting Help

If you encounter issues:

1. Check this guide first
2. Review the main README.md
3. Check inline code comments
4. Search for the error in Xcode documentation
5. Verify backend API is responding

## Production Checklist

Before releasing:

- [ ] Update API URLs to production endpoints
- [ ] Configure code signing and provisioning
- [ ] Test on multiple devices and iOS versions
- [ ] Review and update Info.plist descriptions
- [ ] Add app icons in Assets.xcassets
- [ ] Test all error scenarios
- [ ] Verify accessibility features
- [ ] Performance testing with many pins
- [ ] App Store screenshots and description

---

Happy coding! 🚀
