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
    @IBOutlet var commentsTable: UITableView!
    @IBOutlet var addCommentButton: UIButton!
    
    let firebaseAuthService = FireBaseAuthService()
    let firebaseDBService = FireBaseDBService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTable.delegate = self
        commentsTable.dataSource = self
        initialLayoutDesign()
        initialSettings()
    }
    
    private func initialSettings() {
        firebaseDBService.getPostsComments(postID: postID!, commentsTable: commentsTable) { commentsData in
            self.commentsList = commentsData
        }
    }
    
    private func initialLayoutDesign() {
        navigationController?.navigationBar.isHidden = true
        ppImage.initialPictureDesign(cornerRadius: 20)
        addComment.initialTextFieldDesign(cornerRadius:20)
        if let photoURL = Auth.auth().currentUser?.photoURL?.absoluteString {
            ppImage.sd_setImage(with: URL(string:  photoURL))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialLayoutDesign()
        initialSettings()
    }

}

// Actions
extension CommentsPageViewController {
    @IBAction private  func addComment(_ sender: Any) {
        let fireStore = Firestore.firestore()
        let currenUserUID = Auth.auth().currentUser?.uid
        let comment = addComment.text!
        let commentID = UUID().uuidString

        firebaseAuthService.getUserName(uid: currenUserUID!) { userName in
            if let username = userName {
                let data = UploadCommentModel(userUID: currenUserUID, username: username, comment: comment, timestamp: FieldValue.serverTimestamp()).toDictionary()
                fireStore.collection("Post").document(self.postID!).collection("comments").document("\(commentID)").setData(data)
            }
        }
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
        let cell = commentsTable.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentViewCell
        
        cell.commentLabel.text = comment.comment
        cell.username.text = comment.userName
        
        firebaseAuthService.getUserPhotoURL(uid: comment.userUID ?? "") { usersProfileImageUrl  in
            if let url = usersProfileImageUrl {
                cell.ppImage.sd_setImage(with: URL(string: url))
            } else {
                cell.ppImage.setInitialImages()
            }
        }
        return cell
    }
    
    
}

