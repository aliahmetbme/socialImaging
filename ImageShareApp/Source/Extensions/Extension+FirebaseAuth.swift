//
//  Extension+FirebaseAuth.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 14.07.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UIKit

extension UIViewController {
    
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
    
    func updateUserPhotoURL(downloadURL: URL) {
        
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = downloadURL
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully")
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
    
    func getUserName(completion: @escaping (String?) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
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
        } else {
            completion(nil)
        }
    }
    
}
