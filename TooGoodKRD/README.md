# TooGoodKRD (SwiftUI)

A minimalist SwiftUI iOS app inspired by Too Good To Go, limited to Kurdistan (Duhok and Zakho). Customers can browse surplus/expiring items, filter by city and category, cash-free checkout via Stripe PaymentSheet (supports Apple Pay), select pick-up time, receive push notifications, and view store locations on a map. Businesses can register, add items, and manage them on a dashboard. Backend uses Firebase (Auth, Firestore, Cloud Functions, Messaging/FCM).

## Features
- Customer
  - Browse items from local businesses (surplus/expiring)
  - Filter by city (Duhok, Zakho) and category
  - Cash-free checkout using Stripe PaymentSheet (Apple Pay where available)
  - Select pick-up time
  - Push notifications for new items (subscribe by city)
  - Map with store pins; tap to view store details
- Business
  - Register business (name, location, category, contact)
  - Add items (name, quantity, expiry date, priceCents, pickup time)
  - Manage items (mark as claimed/sold)
- Backend
  - Firebase Auth, Firestore, Cloud Functions, Messaging (FCM)
  - Firestore security rules
  - Cloud Functions for PaymentIntent creation and push notifications on new items
  - Example data for Duhok and Zakho

## Tech
- SwiftUI, iOS 16+
- MapKit
- Stripe iOS SDK (PaymentSheet)
- Firebase: Auth, Firestore (+FirestoreSwift), Messaging, Functions
- XcodeGen for project generation

## Project structure
```
TooGoodKRD/
  XcodeGen/project.yml                 # Xcode project definition
  Config/Info.plist                    # App Info.plist
  Config/TooGoodKRD.entitlements       # Push + Apple Pay entitlements
  iOS/TooGoodKRD/                      # App sources
    Services/, Models/, ViewModels/, Views/, Components/
    Resources/Assets.xcassets/
  Firebase/
    firestore.rules
    firestore.indexes.json
    functions/
      package.json
      tsconfig.json
      src/index.ts
  SampleData/
    businesses.json
    items.json
```

## Prerequisites
- Xcode 15+
- iOS 16+ simulator or device
- Homebrew (to install XcodeGen)
- A Firebase project (iOS app) and APNs configured
- A Stripe account (test mode ok). Apple Pay optional
- An Apple Merchant ID if you want Apple Pay in PaymentSheet (e.g., merchant.com.your.merchant)

## Setup
1) Generate the Xcode project
- Install XcodeGen: `brew install xcodegen`
- From the repo root:
```
cd TooGoodKRD
xcodegen generate
open TooGoodKRD.xcodeproj
```

2) Firebase config
- Add iOS app in Firebase Console; bundle identifier must match `project.yml`.
- Place `GoogleService-Info.plist` at `iOS/TooGoodKRD/Resources/GoogleService-Info.plist`.
- Enable Auth (Email/Password), Firestore, and Cloud Messaging (upload APNs key).

3) Stripe PaymentSheet
- Get your Publishable Key and set it in `iOS/TooGoodKRD/AppConfig.swift`.
- If enabling Apple Pay within PaymentSheet, set your Merchant ID in `AppConfig.swift` and enable the capability in the project.

4) Cloud Functions
```
cd Firebase/functions
npm install
firebase functions:config:set stripe.secret="sk_test_..."
firebase deploy --only functions
```

5) Firestore Rules & Indexes
```
cd Firebase
firebase deploy --only firestore:rules,firestore:indexes
```

6) Seed sample data
- Call the callable `seedSampleData` from the Firebase Console or from a temporary client snippet to add demo businesses and items for Duhok and Zakho.

## Notes
- Prices are stored in cents (`priceCents`). Payment uses USD by default in this sample; adjust currency in `functions/src/index.ts` and UI if needed.
- For Apple Pay in PaymentSheet, you must test on a real device with a provisioned card.
- Push notifications require a real device for receipt; the app subscribes to `city_<City>` topics when the Map tab is used.

## Submission
- Physical goods are paid with Stripe (not IAP), which is compliant.
- Ensure production entitlements and APNs environment for release builds.

## License
Reference implementation. Use at your own risk.