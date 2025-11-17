# Testing Checklist for SpotFinder

Use this checklist to verify all features are working correctly.

## Pre-Testing Setup

- [ ] Backend API is running on http://localhost:3000
- [ ] Xcode project builds without errors
- [ ] All files are added to Xcode project
- [ ] Info.plist contains location permissions
- [ ] iOS 17+ simulator or device selected

## 1. Location Services

### Permission Request

- [ ] App requests location permission on first launch
- [ ] Permission dialog shows custom message from Info.plist
- [ ] Selecting "Allow While Using App" enables features
- [ ] Selecting "Don't Allow" disables report button

### Location Updates

- [ ] User location dot appears on map
- [ ] Location updates as simulator location changes
- [ ] Coordinates display in Report Sheet
- [ ] Map centers on user location initially

### Settings Integration

- [ ] Settings view shows permission status correctly
- [ ] "Open Settings" button appears when denied
- [ ] Tapping button opens iOS Settings app
- [ ] Status updates when permission changes

**Test Locations:**

- San Francisco: 37.7749, -122.4194
- New York: 40.7128, -74.0060
- Custom locations in simulator

## 2. Map View

### Display

- [ ] Map loads and displays correctly
- [ ] User location button works
- [ ] Compass appears when map is rotated
- [ ] Scale view shows distance
- [ ] Map can be panned smoothly
- [ ] Map can be zoomed in/out
- [ ] Map responds to pinch gestures

### Annotations

- [ ] Parking pins appear on map
- [ ] Pin colors match status (blue/red/gray)
- [ ] Expired pins show as gray
- [ ] Pins don't overlap (clustering works)
- [ ] Tapping pin selects report
- [ ] Selected pin highlights correctly

### Map Controls

- [ ] User location button centers on user
- [ ] Compass reorients map to north
- [ ] Refresh button fetches latest data
- [ ] Settings button opens settings sheet

## 3. Report Submission

### Form Validation

- [ ] Report button disabled when location unavailable
- [ ] Submit button disabled when form incomplete
- [ ] Street name is required field
- [ ] Cross streets are optional
- [ ] Form shows current GPS coordinates
- [ ] Status picker shows Available/Taken options

### Submission Process

- [ ] Tapping report button opens sheet
- [ ] Form fields are editable
- [ ] Submitting shows loading indicator
- [ ] Success dismisses sheet
- [ ] Failure shows error alert
- [ ] New report appears on map immediately
- [ ] Haptic feedback on success

### Error Handling

- [ ] Network error shows user-friendly message
- [ ] Invalid data shows validation error
- [ ] Server error displays properly
- [ ] Retry logic works for timeouts

## 4. Report Display

### Report Cards

- [ ] Cards scroll horizontally
- [ ] Shows up to 10 recent reports
- [ ] Displays street name clearly
- [ ] Shows cross streets if available
- [ ] Status icon matches report type
- [ ] Time ago updates (2 min ago, etc.)
- [ ] Expired reports show as gray

### Card Interaction

- [ ] Tapping card centers map on report
- [ ] Map zooms to appropriate level
- [ ] Selected report highlights on map
- [ ] Card shows upvote/downvote counts

## 5. Rating System

### Rating Actions

- [ ] Thumbs up button increments upvotes
- [ ] Thumbs down button increments downvotes
- [ ] Counts update in real-time
- [ ] Rating reflects in card immediately
- [ ] Multiple ratings work correctly
- [ ] Error handling for failed ratings

### Visual Feedback

- [ ] Green color for upvotes
- [ ] Red color for downvotes
- [ ] Numbers display correctly
- [ ] Haptic feedback on tap

## 6. Real-time Updates

### WebSocket Connection

- [ ] Connects automatically on app launch
- [ ] Shows connection status if needed
- [ ] Receives new reports instantly
- [ ] Updates existing reports
- [ ] Reconnects after disconnection
- [ ] Handles connection errors gracefully

### Live Updates

- [ ] New reports appear without refresh
- [ ] Existing pins update status
- [ ] Vote counts update live
- [ ] Map doesn't interrupt user interaction
- [ ] No duplicate reports appear

### Testing Real-time

1. Open app on two devices/simulators
2. Create report on device 1
3. Verify appears on device 2 automatically
4. Rate report on device 1
5. Verify count updates on device 2

## 7. Nearby Search

### Filtering

- [ ] Shows reports within 500m radius
- [ ] Updates as user location changes
- [ ] Excludes far reports correctly
- [ ] Distance calculation is accurate

### Performance

- [ ] Handles 100+ reports smoothly
- [ ] Map doesn't lag with many pins
- [ ] Clustering works with dense areas
- [ ] Scrolling remains smooth

## 8. Time Display

### Timestamp Formatting

- [ ] "Just now" for <1 minute
- [ ] "X min ago" for minutes
- [ ] "X hour(s) ago" for hours
- [ ] "X day(s) ago" for days
- [ ] Updates automatically over time

### Expiration Logic

- [ ] Reports older than 1 hour are gray
- [ ] Expired status shows correctly
- [ ] Doesn't affect functionality
- [ ] Old reports can still be rated

## 9. Error Handling

### Network Errors

- [ ] No internet connection handled
- [ ] Server unreachable shows message
- [ ] Timeout errors display properly
- [ ] Error banner dismisses correctly
- [ ] X button closes error banner

### API Errors

- [ ] 400 Bad Request shows validation error
- [ ] 404 Not Found handled gracefully
- [ ] 500 Server Error displays properly
- [ ] Error messages are user-friendly

### Location Errors

- [ ] Location unavailable shows message
- [ ] Permission denied handled correctly
- [ ] GPS weak signal handled
- [ ] Indoor location issues managed

## 10. User Interface

### Accessibility

- [ ] VoiceOver reads all elements
- [ ] Dynamic Type scales text
- [ ] Buttons meet 44pt minimum size
- [ ] Color contrast is sufficient
- [ ] Labels are descriptive

### Responsive Design

- [ ] Works in portrait orientation
- [ ] Works in landscape orientation
- [ ] Adapts to different iPhone sizes
- [ ] Adapts to iPad if applicable
- [ ] Keyboard doesn't hide fields

### Visual Polish

- [ ] Animations are smooth
- [ ] Colors match design spec
- [ ] Icons are appropriate
- [ ] Loading states show clearly
- [ ] No visual glitches

## 11. Performance

### Startup

- [ ] App launches in <2 seconds
- [ ] Initial map load is fast
- [ ] Location acquired quickly
- [ ] No crash on launch

### Runtime

- [ ] Memory usage is reasonable
- [ ] No memory leaks detected
- [ ] CPU usage is low
- [ ] Battery drain is minimal
- [ ] No crashes during use

### Data Loading

- [ ] API calls complete quickly (<2s)
- [ ] Loading indicators show
- [ ] Background refresh works
- [ ] Handles slow network gracefully

## 12. Edge Cases

### Unusual Inputs

- [ ] Very long street names truncate
- [ ] Special characters in names work
- [ ] Empty optional fields handled
- [ ] Extreme coordinates handled
- [ ] Invalid coordinates rejected

### Connection Issues

- [ ] Airplane mode handled
- [ ] WiFi to cellular handoff works
- [ ] Background/foreground transitions
- [ ] App suspend/resume works
- [ ] Force quit and restart works

### Boundary Conditions

- [ ] Zero reports displays properly
- [ ] One report works correctly
- [ ] Hundreds of reports handled
- [ ] All reports expired works
- [ ] Rapid submissions handled

## 13. Settings View

### Information Display

- [ ] Permission status shows correctly
- [ ] Version number displays
- [ ] Build number displays
- [ ] Links work properly

### Navigation

- [ ] Opens from toolbar button
- [ ] Dismisses with Done button
- [ ] Returns to map view
- [ ] State persists correctly

## Testing Environment

### Simulator Testing

```bash
# Set custom location
Features → Location → Custom Location
Enter: 37.7749, -122.4194

# Simulate location changes
Debug → Simulate Location → [Choose preset]

# Test background/foreground
Hardware → Home
Hardware → Lock
```

### Device Testing

- [ ] Test on physical iPhone
- [ ] Test with real GPS movement
- [ ] Test in areas with many reports
- [ ] Test in areas with no reports
- [ ] Test with poor cellular signal

## Regression Testing

After any code changes, verify:

- [ ] Existing features still work
- [ ] No new crashes introduced
- [ ] Performance hasn't degraded
- [ ] UI looks correct
- [ ] Data persists correctly

## Pre-Release Checklist

- [ ] All features tested and working
- [ ] No critical bugs remain
- [ ] Performance is acceptable
- [ ] UI is polished
- [ ] Error messages are helpful
- [ ] Location permissions clear
- [ ] API integration works
- [ ] WebSocket stable
- [ ] Accessibility verified
- [ ] Screenshots taken
- [ ] App Store description ready

## Automated Testing

Consider adding tests for:

- [ ] ParkingReportViewModel logic
- [ ] LocationManager permission flow
- [ ] APIClient request/response
- [ ] Date formatting utilities
- [ ] Error handling paths

## Bug Reporting Template

When you find a bug:

**Title:** Brief description

**Steps to Reproduce:**

1. Step one
2. Step two
3. Step three

**Expected:** What should happen

**Actual:** What actually happened

**Environment:**

- iOS version:
- Device/Simulator:
- App version:
- Backend status:

**Screenshots/Logs:** Attach if available

---

## Testing Tips

1. **Test incrementally** - Test each feature as you implement it
2. **Use breakpoints** - Debug issues immediately
3. **Check console** - Look for error messages
4. **Test edge cases** - Don't just test happy paths
5. **Get feedback** - Have others test the app
6. **Document issues** - Keep track of bugs found
7. **Retest fixes** - Verify bugs are actually fixed

## Success Criteria

✅ All core features work reliably
✅ No critical bugs or crashes
✅ Good performance on target devices
✅ UI is intuitive and polished
✅ Error handling is comprehensive
✅ Real-time updates work smoothly

---

Good luck with testing! 🧪
