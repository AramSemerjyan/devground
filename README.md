# DevGround

**A lightweight, cross-platform development playground and code editor built with Flutter**

DevGround (formerly dartpad_lite) is a desktop application that provides an integrated development environment for quickly writing, compiling, and running code across multiple programming languages. Built with Flutter, it offers a native experience on macOS, Linux, and Windows.

## 🚀 Key Features

- **Multi-Language Support**: Write and execute code in 10+ languages including:
  - Compiled languages: Dart, C, C++, Swift
  - Interpreted languages: Python, JavaScript, Shell
  - Markup & data formats: HTML, CSS, JSON, XML
  
- **Monaco Editor Integration**: Professional code editing experience powered by Monaco Editor with:
  - Syntax highlighting for all supported languages
  - IntelliSense and code completion
  - Multiple themes and customization options

- **Interactive Execution**: Real-time code compilation and execution with:
  - Streaming output for long-running processes
  - Interactive stdin support for C/C++/Swift programs
  - Terminal-like behavior with smart buffering

- **Project Management**:
  - File picker and drag-and-drop support for importing files
  - Code history tracking with timestamped logs
  - Multi-window support for parallel development
  - Persistent settings and SDK path configuration

- **Developer-Friendly UI**:
  - Command palette for quick actions
  - Clean, modern interface
  - Customizable toolbar and editor settings
  - Support for code formatting and validation

## 🛠️ Technical Highlights

- Built with **Flutter 3+** for native desktop performance
- WebView integration for Monaco Editor rendering
- Cross-platform process execution with PTY/stdbuf fallbacks
- Asynchronous compilation with streaming results
- Local storage for preferences and history

## 📦 Use Cases

- Quick prototyping and experimentation across languages
- Learning and teaching programming concepts
- Testing code snippets without setting up full IDEs
- Portable development environment on any desktop platform

## 🎯 Perfect For

- Students learning multiple programming languages
- Developers who need a quick scratchpad for code experiments
- Educators demonstrating code examples in real-time
- Anyone wanting a lightweight alternative to heavy IDEs

## Getting Started

This project requires Flutter 3.9.2 or higher.

### Prerequisites

- Flutter SDK
- Platform-specific SDKs for languages you want to use (gcc, g++, swift, node, python3, etc.)

### Running the Application

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d macos  # or linux/windows

# Build release
flutter build macos --release
```

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
