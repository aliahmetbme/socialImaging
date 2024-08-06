//
//  FireBaseAuthService.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.07.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseStorage
import SDWebImage

class FireBaseAuthService: UIViewController {
    
    /// - User Sign In
    func signIn(user: LoginUser,completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: user.email, password: user.password, completion: completion)
    }
    /// - Google Sign In

    func signInGoogle( viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false)
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
            guard error == nil else {
                print("Google sign in error: \(error!.localizedDescription)")
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                print("User or ID token is nil.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // Firebase'e giriş yapma
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase authentication error: \(error.localizedDescription)")
                    completion(false)
                }
                
                self.setInitialUserPhoto(uid: (authResult?.user.uid)!)
                completion(true)
            }
        }
    }
    
    func changePassword(newPassword: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error updating password: \(error.localizedDescription)")
            } else {
                print("Password updated successfully.")
            }
        }
    }
    
    func updateUserPhotoURL(selectedImage: UIImage) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let storage = Storage.storage()
        
        if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
            let storageRef = storage.reference().child("profile_pictures").child("\(user.uid).jpg")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if error != nil {
                    print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.photoURL = downloadURL
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Error updating profile: \(error.localizedDescription)")
                            } else {
                                print("Profile updated successfully")
                            }
                        }
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    func updateDisplayName(newDisplayName: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
            } else {
                print("Display name updated successfully")
            }
        }
    }
    
    func setInitialUserPhoto(uid: String) {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let storage = Storage.storage()
        
        if let photoURL = user.photoURL {
            print("photoURL = \(photoURL)")
            
            // SDWebImage'i kullanarak asenkron olarak görüntüyü indir
            SDWebImageManager.shared.loadImage(with: photoURL, options: .highPriority, progress: nil) { (image, data, error, cacheType, finished, imageURL) in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                
                guard let image = image else {
                    print("Image download failed")
                    return
                }
                
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    let storageRef = storage.reference().child("profile_pictures").child("\(uid).jpg")
                    
                    storageRef.putData(imageData, metadata: nil) { metadata, error in
                        if error != nil {
                            print("Error uploading initial image: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        storageRef.downloadURL { url, error in
                            if let downloadURL = url {
                                let changeRequest = user.createProfileChangeRequest()
                                changeRequest.photoURL = downloadURL
                                changeRequest.commitChanges { error in
                                    if let error = error {
                                        print("Error updating profile: \(error.localizedDescription)")
                                    } else {
                                        print("Profile updated successfully")
                                    }
                                }
                            } else {
                                print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                            }
                        }
                    }
                } else {
                    print("Failed to convert image to JPEG data")
                }
            }
        } else {
            print("User has no photo URL")
        }
    }
    
    func getUserName(uid: String = Auth.auth().currentUser!.uid, completion: @escaping (String?) -> Void) {
        
        let userNameRef = Firestore.firestore().collection("User").document(uid)
        userNameRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = document, document.exists {
                let username = document.get("userName") as? String
                completion(username)
            } else {
                completion(nil)
            }
        }
    }

    func getUserPhotoURL(uid: String,completion: @escaping (String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_pictures").child("\(uid).jpg")
        
        storageRef.downloadURL { url, error in
            if error != nil {
                completion(nil)
                return
            }
            completion(url?.absoluteString)
        }
    }
    
}

