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
    
    func getAllPosts(completion: @escaping (([PostModel]) -> Void)){
        let query: Query = firestore.collection(DBEndPoints.Post.endPointsString)
            .order(by: DBEndPoints.date.endPointsString, descending: true)
        var postArray: [PostModel] = []

        query.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching posts: \(error)")
                completion([])
                return
            }
            
            postArray.removeAll()
            
            for document in querySnapshot!.documents {
                let post = self.createPostModel(from: document)
                postArray.append(post)
            }
            
            DispatchQueue.main.async {
                completion(postArray)
            }
        }
    }
    
    func observePostChanges(postArray: [PostModel], tableView: UITableView, completion: @escaping (([PostModel],IndexPath?) -> Void)) {
        
    let query: Query = firestore.collection(DBEndPoints.Post.endPointsString).order(by: DBEndPoints.date.endPointsString, descending: true)
    
    var posts = postArray
        
        query.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching posts: \(error)")
                return
            }
            
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                print("Snapshot boş veya hatalı.")
                completion([],nil)
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified){
                    let modifiedPost = self.createPostModel(from: diff.document)
                    
                    if let index = postArray.firstIndex(where: { $0.postId == modifiedPost.postId }) {
                        posts[index] = modifiedPost
                        
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: index, section: 0)
                            completion(posts,indexPath)
                        }
                    }
                }
            }
        }
    }

    func createPostModel(from document: DocumentSnapshot) -> PostModel {
        let documentId = document.documentID
        let postImageUrl = document.get("imageUrl") as? String ?? ""
        let userUID = document.get("userUID") as? String ?? ""
        let date = document.get("date") as? String ?? ""
        let description = document.get("comment") as? String ?? ""
        let comments = document.get("comments") as? [String] ?? []
        let likeCount = document.get("likeCount") as? Int ?? 0
        
        return PostModel(
            postImageUrl: postImageUrl,
            userUID: userUID,
            description: description,
            date: date,
            comments: comments,
            likeCount: likeCount,
            postId: documentId
        )
    }

func getUsersOwnPosts (tableView: UITableView, filterField: String, completion: @escaping (([PostModel]) -> Void)) {
        var postArray: [PostModel] = []
        
    let QUERY: Query = firestore.collection(DBEndPoints.Post.endPointsString)
        .order(by: DBEndPoints.date.endPointsString, descending: true).whereField(filterField, isEqualTo: userUID!)
        
    QUERY.addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("Veri alınamadı: POSTLAR YOK")
                return
            }
            
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                print("Snapshot boş.")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            postArray.removeAll()
            
            for document in snapshot.documents {
                let documentId = document.documentID
                let postImageUrl = document.get("imageUrl") as? String ?? ""
                let userUID = document.get("userUID") as? String ?? ""
                let date = document.get("date") as? String ?? ""
                let description = document.get("comment") as? String ?? ""
                let comments = document.get("comments") as? [String] ?? []
                let likeCount = document.get("likeCount") as? Int ?? 0
                
                let post = PostModel(
                    postImageUrl: postImageUrl,
                    userUID: userUID,
                    description: description,
                    date: date,
                    comments: comments,
                    likeCount: likeCount,
                    postId: documentId
                )
                
                postArray.append(post)
            }
            DispatchQueue.main.async {
                completion(postArray)
                tableView.reloadData()
           }
        }
    }
    
    func setLikedofPosts(indexPath: IndexPath, postId: String, likeButton: UIButton, likeCount: Int, table: UITableView) {
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
        let likeDocRef = firestore.collection("Post").document(postId).collection("likes").document(userUID!)
        var likeCount = likeCount
        
        likeDocRef.getDocument { [weak self] (document, error) in
            guard error == nil else {
                print("Error fetching document: \(String(describing: error))")
                return
            }
            
            if let document = document, document.exists {
                // Kullanıcı zaten beğenmişse, beğeniyi kaldır
                likeButton.setImage(iconNonLiked, for: .normal)
                likeCount -= 1
                
                // Firestore'dan beğenmeyi kaldır
                likeDocRef.delete()
                
            } else {
                // Kullanıcı beğenmemişse, beğeniyi ekle
                likeButton.setImage(iconLiked, for: .normal)
                likeCount += 1
                
                // Kullanıcıyı "likes" alt koleksiyonuna ekle
                likeDocRef.setData([
                    "userId": self?.userUID ?? "",
                    "timestamp": FieldValue.serverTimestamp()
                ])
            }
            
            // Firestore'a beğeniyi ekle veya kaldır
            self?.firestore.collection("Post").document(postId).updateData([
                "likeCount": likeCount
            ]) { error in
                if let error = error {
                    print("Error updating like count: \(error)")
                } 
            }
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
