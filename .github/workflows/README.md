# GitHub Actions Workflows

## Flutter CI Pipeline

The `flutter-ci.yml` workflow automatically runs on every commit and pull request to the main branches (main, master, develop).

### What it does:

1. **Analyze Job** (runs on Ubuntu):
   - Checks code formatting with `dart format`
   - Runs static analysis with `flutter analyze`
   - Ensures code quality standards are met

2. **Build Job** (runs on Linux, macOS, and Windows):
   - Builds the application for each platform
   - Verifies that the build completes successfully
   - Catches build-time errors before merging

### Running locally:

Before pushing your changes, you can run these checks locally:

```bash
# Format your code
dart format .

# Analyze your code
flutter analyze

# Build for your platform
flutter build linux --release   # on Linux
flutter build macos --release   # on macOS
flutter build windows --release # on Windows
```

### Troubleshooting:

- If the format check fails, run `dart format .` to auto-format your code
- If analyze fails, fix the reported issues in your code
- If build fails, check the build logs for specific error messages
