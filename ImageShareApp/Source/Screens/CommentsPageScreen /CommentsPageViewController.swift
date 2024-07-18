//
//  CommentsPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 26.06.2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CommentsPageViewController: UIViewController, UITextFieldDelegate {
    
    var commentsList:[CommentModel] = []
    let curretUserProfilePictureURL = Auth.auth().currentUser?.photoURL?.absoluteString

    var postID: String?
    @IBOutlet var ppImage: UIImageView!
    @IBOutlet var addComment: UITextField!
    @IBOutlet var commentsLists: UITableView!
    @IBOutlet var addCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsLists.delegate = self
        commentsLists.dataSource = self
        initialLayoutDesign()
        getCommentsFromDB()
    }
    
    private func initialLayoutDesign() {
        navigationController?.navigationBar.isHidden = true
        ppImage.initialPictureDesign(cornerRadius: 20)
        addComment.initialTextFieldDesign(cornerRadius:20)
        ppImage.sd_setImage(with: URL(string: Auth.auth().currentUser?.photoURL?.absoluteString ?? ""))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        initialLayoutDesign()
    }
    
    private func getCommentsFromDB() {
        let fireStore = Firestore.firestore()
        let commentsDocRef = fireStore.collection("Post").document(postID!).collection("comments")

        commentsDocRef.order(by: "timestamp", descending: true).addSnapshotListener { querySnapshot, error in
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                self.commentsList.removeAll() // Eski yorumları temizle
                for document in snapshot.documents {
                    let username = document.get("username") as? String
                    let userUID = document.get("userUID") as? String
                    let comment = document.get("comment") as? String
                    
                    let commentObj = CommentModel(userUID: userUID, userName: username, comment: comment)
                    self.commentsList.append(commentObj)
                }
                DispatchQueue.main.async {
                    self.commentsLists.reloadData() // TableView'i güncelle
                }
            }
        }
    }
}

// Actions
extension CommentsPageViewController {
    @IBAction private  func addComment(_ sender: Any) {
        let fireStore = Firestore.firestore()
        let currenUserUID = Auth.auth().currentUser?.uid
        let comment = addComment.text!
        let commentID = UUID().uuidString

        getUserName(uid: currenUserUID!) { userName in
            if let username = userName {
                let data = UploadCommentModel(userUID: currenUserUID, username: username, comment: comment, timestamp: FieldValue.serverTimestamp()).toDictionary()
                fireStore.collection("Post").document(self.postID!).collection("comments").document("\(commentID)").setData(data)
            }
        }
               
        getCommentsFromDB()
        addComment.text = ""
    }
}

// Table View
extension CommentsPageViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = commentsList[indexPath.row]
        let cell = commentsLists.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentViewCell
        
        cell.commentLabel.text = comment.comment
        cell.username.text = comment.userName
        
        getUserPhotoURL(uid: comment.userUID!) { usersProfileImageUrl  in
            if let url = usersProfileImageUrl {
                cell.ppImage.sd_setImage(with: URL(string: url))
            } else {
                cell.ppImage.setInitialImages()
            }
        }
        return cell
    }
    
    
}

