# CV Upload Feature Demo

This demo showcases the CV upload and parsing functionality for the IT Job Finder app.

## 🚀 Quick Start

### Run the Demo

```bash
# From the project root directory
flutter run -t lib/demo_main.dart
```

Or if you have a specific device:

```bash
# For Chrome
flutter run -t lib/demo_main.dart -d chrome

# For Android emulator
flutter run -t lib/demo_main.dart -d emulator-5554

# For iOS simulator
flutter run -t lib/demo_main.dart -d "iPhone 15"
```

## 📱 Features Demonstrated

### 1. **CV Upload Flow**
- File picker for PDF, DOC, DOCX files
- File size validation (5MB limit)
- Real-time upload progress tracking
- Cancel upload functionality
- Error handling with retry option

### 2. **AI CV Parsing**
- Simulated AI parsing with loading state
- Status polling mechanism
- Parse completion/failure handling

### 3. **Data Extraction Display**
The demo shows how the app extracts and displays:
- ✅ **Skills**: Technical and soft skills
- ✅ **Work Experience**: Job titles, companies, dates, descriptions
- ✅ **Education**: Degrees, majors, institutions, years
- ✅ **Languages**: Language proficiencies
- ✅ **Certifications**: Professional certifications

### 4. **UI Components**
- `UploadProgressIndicator`: Upload progress with percentage
- `UploadCompleteIndicator`: Success state with actions
- `UploadErrorIndicator`: Error state with retry
- Beautiful card-based data display
- Raw JSON preview for developers

## 📂 Files Created

```
lib/
├── demo_main.dart                          # Demo app entry point
├── services/
│   └── cv_upload_service.dart             # CV upload & parsing service
├── screens/
│   ├── cv_upload_screen.dart              # Main CV upload screen
│   └── demo/
│       └── cv_upload_demo_screen.dart     # Demo wrapper screen
├── widgets/
│   └── upload_progress_indicator.dart     # Upload progress widgets
└── models/
    ├── experience_model.dart               # Experience data model
    ├── education_model.dart                # Education data model
    └── portfolio_link_model.dart           # Portfolio & CV parse status
```

## 🧪 Testing the Demo

### Step 1: Launch the Demo
Run the command above to start the app.

### Step 2: Upload a CV
1. Tap the **"Upload CV"** floating action button
2. Select a PDF, DOC, or DOCX file (max 5MB)
3. Watch the upload progress

### Step 3: View AI Parsing
1. See the "AI is analyzing your CV..." state
2. Wait for parsing to complete (simulated ~2 seconds)

### Step 4: Review Parsed Data
1. View extracted information in organized sections
2. Check the raw JSON data at the bottom
3. Tap **"Use This Data"** to simulate importing the data

### Step 5: Test Again
- Tap **"Upload Again"** to try a different file
- Or tap the **Clear** icon (✕) in the app bar to reset

## 🔧 Mock Data

The service currently returns mock data for demonstration:

```json
{
  "skills": ["Flutter", "Dart", "Firebase", "REST API", "Git", "AWS"],
  "experiences": [
    {
      "jobTitle": "Senior Flutter Developer",
      "company": "Tech Company Inc.",
      "startDate": "2022-01-01",
      "endDate": null,
      "isCurrentlyWorking": true,
      "description": "Leading mobile app development team",
      "skills": ["Flutter", "Dart", "Firebase"]
    }
  ],
  "educations": [
    {
      "degree": "Bachelor of Computer Science",
      "major": "Computer Science",
      "institution": "University of Technology",
      "startYear": 2016,
      "endYear": 2020
    }
  ],
  "languages": ["English", "Vietnamese"],
  "certifications": ["AWS Certified Developer"]
}
```

## 🔌 Backend Integration

To integrate with a real backend, update the following methods in `lib/services/cv_upload_service.dart`:

### 1. Upload CV
```dart
Stream<double> uploadCV(File file) async* {
  // TODO: Replace with actual API call
  // Example:
  final dio = Dio();
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path),
  });
  
  await dio.post(
    'https://your-api.com/cv/upload',
    data: formData,
    onSendProgress: (sent, total) {
      yield sent / total;
    },
  );
}
```

### 2. Get Parse Status
```dart
Future<CVParseStatus> getCVParseStatus(String cvId) async {
  // TODO: Replace with actual API call
  final response = await dio.get('https://your-api.com/cv/$cvId/status');
  return CVParseStatus.values.byName(response.data['status']);
}
```

### 3. Get Parsed Data
```dart
Future<Map<String, dynamic>> getParsedCVData(String cvId) async {
  // TODO: Replace with actual API call
  final response = await dio.get('https://your-api.com/cv/$cvId/parsed');
  return response.data;
}
```

## 🎨 UI Customization

The demo uses Material 3 with dynamic color theming. To customize:

1. **Change Colors**: Edit `demo_main.dart`
   ```dart
   ColorScheme.fromSeed(
     seedColor: Colors.purple, // Change this
   )
   ```

2. **Adjust Upload Area**: Edit `cv_upload_screen.dart` → `_buildUploadArea()`

3. **Modify Data Display**: Edit `cv_upload_demo_screen.dart` → `_buildDataDisplay()`

## 📊 State Management

The upload screen manages these states:
- `initial`: Ready to upload
- `picking`: File picker is open
- `uploading`: File upload in progress
- `parsing`: AI is analyzing the CV
- `complete`: Parse complete, showing results
- `error`: An error occurred

## 🐛 Troubleshooting

### File Picker Not Working
Ensure you have the required permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Need access to pick CV files</string>
```

### Upload Progress Stuck
Check your internet connection and backend API status.

### Parse Never Completes
The mock implementation auto-completes after a delay. For real implementation, ensure your backend returns proper status updates.

## 📝 Next Steps

1. ✅ CV upload UI and flow - **COMPLETE**
2. ⏳ Integrate with real backend API
3. ⏳ Add edit functionality for parsed data
4. ⏳ Implement data persistence
5. ⏳ Add notification support for parse completion

## 💡 Tips

- The demo works on all platforms (iOS, Android, Web, Desktop)
- Use mock data to test UI without a backend
- File picker requires proper permissions on mobile
- Test with different file sizes to see validation
- Try canceling upload to test error handling

## 📚 Dependencies Used

- `file_picker: ^8.1.4` - File selection
- `flutter_riverpod: ^2.6.1` - State management
- `dio: ^5.7.0` - HTTP client (for future API integration)

---

**Happy Testing! 🎉**

For questions or issues, check the main project documentation.
