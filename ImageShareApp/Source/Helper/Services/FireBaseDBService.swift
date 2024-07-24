//
//  FireBaseDBService.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.07.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import SDWebImage
import UIKit

class FireBaseDBService {
    let firestore = Firestore.firestore()
    let userUID = Auth.auth().currentUser?.uid
    
    func getPosts (tableView: UITableView, filterField: String? = nil ,completion:@escaping (([PostModel]) -> Void)) {
        
        var postArray: [PostModel] = []
        
        var query: Query = firestore.collection(DBEndPoints.Post.endPointsString)
            .order(by: DBEndPoints.date.endPointsString, descending: true)
        
        if let field = filterField {
            query = query.whereField(field, isEqualTo: "\(userUID!)")
        }
        
        query.addSnapshotListener {
            querySnapshot, error in
            
            if error != nil {
                print("Veri alınamadı: \(String(describing: error?.localizedDescription))")
                return
            } else {
                if let snapshot = querySnapshot, !snapshot.isEmpty {
                    
                    for document in snapshot.documents {
                        // documanların özel idleri
                        let documentid = document.documentID
                       // any olarak döndürüyor Stringe çevirememiz lazım
                        let postImageurl = document.get("imageUrl") as? String ?? ""
                        let userUID = document.get("userUID") as? String ?? ""
                        let date = document.get("date") as? String ?? ""
                        let description = document.get("comment") as? String ?? ""
                        let comments = document.get("comments") as? [String] ?? []
                        let likeCount = document.get("likeCount") as? Int ?? 0
                        
                        let post = PostModel(postImageUrl: postImageurl,
                                         userUID: userUID,
                                         description: description,
                                         date: date,
                                         comments: comments,
                                         likeCount: likeCount,
                                         postId: documentid)
                        
                        postArray.append(post)
                        
                        DispatchQueue.main.async {
                           tableView.reloadData()
                        }
                    }
                    completion(postArray)
                }
            }
        }
    }
    
    func setLikedofPosts(post: PostModel, likeButton: UIButton, completion: @escaping (PostModel?) -> Void) {
        
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
        let likeDocRef = firestore.collection("Post").document(post.postId).collection("likes").document(userUID!)
            
        likeDocRef.getDocument { (document, error) in
            guard error == nil else {
                print("Error fetching document: \(String(describing: error))")
                completion(nil)
                return
            }
            
            var updatedPost = post // PostModel'in bir kopyasını oluşturun
            
            if let document = document, document.exists {
                // Kullanıcı zaten beğenmişse, beğeniyi kaldır
                likeButton.setImage(iconNonLiked, for: .normal)
                updatedPost.likeCount -= 1
                
                // Firestore'dan beğenmeyi kaldır
                likeDocRef.delete()
            } else {
                // Kullanıcı beğenmemişse, beğeniyi ekle
                likeButton.setImage(iconLiked, for: .normal)
                updatedPost.likeCount += 1
                
                // Kullanıcıyı "likes" alt koleksiyonuna ekle
                likeDocRef.setData([
                    "userId": self.userUID!,
                    "timestamp": FieldValue.serverTimestamp()
                ])
            }
            print("updatedPost.likeCount \(updatedPost.likeCount )")
            // Firestore'a beğeniyi ekle veya kaldır
            self.firestore.collection("Post").document(updatedPost.postId).updateData([
                "likeCount": updatedPost.likeCount
            ])
            
            // Güncellenmiş post modelini completion ile geri döndür
            completion(updatedPost)
        }
    }

    
    func isPostLiked(postRow: PostModel, completion: @escaping ((Bool) -> Void)) {
    
        let likeDocRef = firestore.collection(DBEndPoints.Post.endPointsString).document(postRow.postId).collection(DBEndPoints.likes.endPointsString).document(userUID!)
        
        likeDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getPostsComments(postID: String, commentsTable: UITableView, completion: @escaping (([CommentModel]) -> Void)) {
        
        let commentsDocRef = firestore.collection("Post").document(postID).collection("comments")
        
        commentsDocRef.order(by: "timestamp", descending: true).addSnapshotListener { querySnapshot, error in
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                var commentsList: [CommentModel] = []
                for document in snapshot.documents {
                    let username = document.get("username") as? String
                    let userUID = document.get("userUID") as? String
                    let comment = document.get("comment") as? String
                    
                    let commentObj = CommentModel(userUID: userUID, userName: username, comment: comment)
                    
                    commentsList.append(commentObj)
                    
                    DispatchQueue.main.async {
                        commentsTable.reloadData() // TableView'i güncelle
                    }
                }
                completion(commentsList)
            }
        }
    }
}
