# 📸 PicConnect

## Overview

**Image Share App** is a social media application that allows users to share images, like posts, and comment on them. The app is designed with a modern user interface and provides real-time updates for a seamless user experience.

## Features

- **User Authentication:** Secure user login and registration with Firebase Authentication.
- **Image Sharing:** Upload and share images instantly.
- **Likes and Comments:** Users can like and comment on posts.
- **User Profiles:** Users can view and update their profiles, including profile pictures and personal information.
- **Real-Time Updates:** Posts and user interactions are updated in real-time using Firebase Firestore.
- **Asynchronous Image Loading:** Images are loaded asynchronously to improve performance and user experience.
- **Auto Layout:** Dynamic and responsive UI design using SnapKit.

## Usage

- **Sign Up/Login:** Users can sign up or log in using their email or Google account.
- **Profile Management:** Users can update their profile information and profile picture.
- **Post Images:** Users can upload images with descriptions, which will be displayed in the main feed.
- **Like and Comment:** Users can interact with posts by liking and commenting on them.

## Technologies Used

- **Swift:** The core programming language for the app.
- **Firebase:**
  - **Authentication:** For managing user sign-in and sign-up.
  - **Firestore:** For real-time database management.
  - **Storage:** For storing user-uploaded images.
- **SDWebImage:** For asynchronous image loading and caching.
- **Alamofire:** For network operations.
- **SnapKit:** For building UI with Auto Layout constraints.


## Some UI Images

<div style="display: flex; flex-direction: column; justify-content: space-between;">
  <div style="display: flex;">
    <img src="https://github.com/aliahmetbme/socialImaging/blob/main/ImageShareApp/Source/Resource/ProjectImages/2.jpg" alt="Banner 1" width="100%" />
    <img src="https://github.com/aliahmetbme/socialImaging/blob/main/ImageShareApp/Source/Resource/ProjectImages/3.jpg" alt="Banner 2" width="100%" />
  </div>
  <div style="display: flex;">
    <img src="https://github.com/aliahmetbme/socialImaging/blob/main/ImageShareApp/Source/Resource/ProjectImages/4.jpg" alt="Banner 3" width="100%" />
    <img src="https://github.com/aliahmetbme/socialImaging/blob/main/ImageShareApp/Source/Resource/ProjectImages/5.jpg" alt="Banner 4" width="100%" />
  </div>
</div>

## Configuration

1. **Firebase Setup:**
   - Create a Firebase project in the Firebase console.
   - Add an iOS app to your Firebase project.
   - Download the `GoogleService-Info.plist` file and add it to the projects under the Resources file DO NOT CHANGE THE NAME OF THE FILE.

2. **Dependencies:**
   - Ensure all required dependencies are installed via CocoaPods:
     ```bash
     pod install
     ```


