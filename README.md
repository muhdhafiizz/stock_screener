# Stock Screener App

## Introduction
The Stock Screener App is designed to help users analyze and track stocks efficiently. It provides authentication, a stock list, the ability to add stocks to a watchlist, and a detailed company overview.

## Setup Instructions

### Prerequisites
Ensure you have the following installed:
- Flutter SDK
- Dart
- Android Studio/Xcode (for mobile development)
- A GitHub account with repository access

### Installation Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/stock-screener-app.git
2. cd stock-screener-app
3. flutter pub get
4. flutter run

## Architecture Overview
The app follows the Clean Architecture principle with Provider for state management.

### Layers:
- Presentation Layer: UI components built with Flutter widgets.
- Application Layer: Business logic and state management using Provider.
- Data Layer: Handles API requests and local storage.

### Technologies Used:
- State Management: Provider
- Networking: HTTP for API calls
- Local Storage: Hive for caching
- Authentication: Firebase Authentication

### Features:
- User Authentication: Secure login and signup using Firebase.
- Stock List: Browse and search stocks with real-time data.
- Watchlist: Add and manage favorite stocks.
- Company Overview: View market cap, 52 weeks low, 52 weeks high, dividend yield and history chart per year.

## Future Improvements
- Implement real-time stock price updates using WebSockets.
- Integrate AI-based stock recommendations.
- Introduce dark mode for better user experience.

