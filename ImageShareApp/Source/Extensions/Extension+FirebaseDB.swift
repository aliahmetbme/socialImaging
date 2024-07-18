//
//  Extension+FirebaseDB.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 18.07.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import SDWebImage
import UIKit


extension UIViewController {
    
    func setLikedofPosts (cell: UITableViewCell, postArray: [PostModel], indexPath: IndexPath, likeButton: UIButton, completion:@escaping (PostModel?) -> Void) {
        
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
        let firestore = Firestore.firestore()
        var post = postArray[indexPath.row]
        let currentUserId = Auth.auth().currentUser?.uid
        let likeDocRef = firestore.collection("Post").document(post.postId).collection("likes").document(currentUserId!)
            
        likeDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Kullanıcı zaten beğenmişse, beğeniyi kaldır
                likeButton.setImage(iconNonLiked, for: .normal)
                post.likeCount -= 1
                
                // Firestore'dan beğenmeyi kaldır
                firestore.collection("Post").document(post.postId).setData([
                    "likeCount": post.likeCount
                ],merge: true)
                
                // Kullanıcıyı "likes" alt koleksiyonundan kaldır
                likeDocRef.delete()
            } else {
                // Kullanıcı beğenmemişse, beğeniyi ekle
                likeButton.setImage(iconLiked, for: .normal)
                post.likeCount += 1
                
                // Firestore'a beğeniyi ekle
                firestore.collection("Post").document(post.postId).setData([
                    "likeCount": post.likeCount
                ], merge: true)
                
                // Kullanıcıyı "likes" alt koleksiyonuna ekle
                likeDocRef.setData([
                    "userId": currentUserId!,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            }
            
            // Update the local postArray with the new likeCount
            completion(post)
        }
    }
}
