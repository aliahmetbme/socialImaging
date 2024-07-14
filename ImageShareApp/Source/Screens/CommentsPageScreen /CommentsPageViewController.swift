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
        getCommentsFromDB()
        initialLayoutDesign()
        
        navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        

      
    }
    
    func initialLayoutDesign() {
        
        ppImage.layer.cornerRadius = 20
        ppImage.clipsToBounds = true
        ppImage.sd_setImage(with: URL(string: curretUserProfilePictureURL!))
        
        commentsLists.delegate = self
        commentsLists.dataSource = self
        
        addComment.layer.borderWidth = 1.0 // Kenarlık genişliği
        addComment.layer.cornerRadius = 20.0
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: addComment.frame.height))
        addComment.leftView = paddingView
        addComment.leftViewMode = .always
        addComment.delegate = self
        
        
        
    }
    
    
    
    @IBAction func addComment(_ sender: Any) {
        let fireStore = Firestore.firestore()
        let currentUserEmail = Auth.auth().currentUser?.email
        let curretUserProfilePictureURL = Auth.auth().currentUser?.photoURL?.absoluteString
        let comment = addComment.text
        
        if let userEmail = currentUserEmail {
            
            let documentID = UUID().uuidString
            
            fireStore.collection("Post").document(postID ?? "").collection("comments").document("\(documentID)").setData(
                ["userEmail" : userEmail,
                 "comment": comment!,
                 "userPP": curretUserProfilePictureURL!,
                 "timestamp" : FieldValue.serverTimestamp()
                ], merge: true) { error in
                if let error = error {
                    print("Error adding comment: \(error)")
                } else {
                    print("Comment successfully added!")
                }
            }

            getCommentsFromDB()
            
            
      }
    }
    
    func getCommentsFromDB() {
        let fireStore = Firestore.firestore()
        let commentsDocRef = fireStore.collection("Post").document(postID!).collection("comments")

        commentsDocRef.order(by: "timestamp", descending: true).addSnapshotListener { querySnapshot, error in
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                self.commentsList.removeAll() // Eski yorumları temizle
                for document in snapshot.documents {
                    let userEmail = document.get("userEmail") as? String
                    let imageUrl = document.get("userPP") as? String
                    let comment = document.get("comment") as? String
                    
                    let commentObj = CommentModel(imageUrl: imageUrl, useremail: userEmail, comment: comment)
                    self.commentsList.append(commentObj)
                }
                DispatchQueue.main.async {
                    self.commentsLists.reloadData() // TableView'i güncelle
                }
            }
        }
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height 
                
        UIView.animate(withDuration: 0.1) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) {
            self.view.transform = .identity
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
            view.endEditing(true)

    }
    
}

extension CommentsPageViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = commentsList[indexPath.row]
        let cell = commentsLists.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentViewCell
        

        cell.commentLabel.text = comment.comment
        cell.username.text = comment.useremail
        
        cell.ppImage.sd_setImage(with: URL(string: comment.imageUrl ?? ""))
        
        return cell
    }
    
    
}

