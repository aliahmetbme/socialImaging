//
//  ProfilePageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class ProfilePageViewController: UIViewController {
    
    @IBOutlet var postsTable: UITableView!
    @IBOutlet var postCount: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profilepicture: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    let firebaseAuhtService = FireBaseAuthService()
    let firebaseDBService = FireBaseDBService()

   private var usersOwnPosts: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialSettings()
    }
    
    private func initialSettings () {
        navigationController?.navigationBar.isHidden = true
        profilepicture.initialPictureDesign()
        postsTable.delegate = self
        postsTable.dataSource = self
        
        if let profilePictureURL = Auth.auth().currentUser?.photoURL {
            profilepicture.sd_setImage(with: profilePictureURL)
        } else {
            profilepicture.setInitialImages()
        }

        if let Name = Auth.auth().currentUser?.displayName {
            nameLabel.text = Name
        }
        // getting UserName
        firebaseAuhtService.getUserName { userName in
            if let username = userName {
                self.usernameLabel.text = "@\(username)"
            }
        }
        
        // getting own Posts
        firebaseDBService.getUsersOwnPosts(tableView: postsTable, filterField: DBEndPoints.userUID.endPointsString) { ownPostData in
            self.usersOwnPosts = ownPostData
            self.postCount.text = "\(ownPostData.count)"
        }
    }
}

// Actions
extension ProfilePageViewController {
    
    @IBAction func logout(_ sender: Any) {
        do {
           try Auth.auth().signOut()
           performSegue(withIdentifier: "toLoginVc", sender: nil)
        } catch {
            print("Hata")
        }
    }
    
    @IBAction func goSettingsPage(_ sender: Any) {
        performSegue(withIdentifier: "toSettingsPage", sender: nil)
    }
}


// UITableView
extension ProfilePageViewController: UITableViewDelegate, UITableViewDataSource, UserPostViewCellProtocol {
    func clicked(indexPath: IndexPath) {
        let cell = postsTable.cellForRow(at: indexPath) as? UsersPostViewCell
        let post = usersOwnPosts[indexPath.row]
        
        firebaseDBService.setLikedofPosts(indexPath: indexPath ,postId: post.postId, likeButton: cell!.likeButton,likeCount: post.likeCount, table: postsTable)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "profiletocommentVC" {
            if let indexPath = sender as? IndexPath {
                let secondVC = segue.destination as! CommentsPageViewController
                
                let post = usersOwnPosts[indexPath.row]
                secondVC.postID = post.postId
            }
        }

    }
    
    func showComments(indexPath: IndexPath) {
        performSegue(withIdentifier: "profiletocommentVC", sender: indexPath)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersOwnPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postRow = usersOwnPosts[indexPath.row]
        let cell = postsTable.dequeueReusableCell(withIdentifier: "usersPostCell", for: indexPath) as! UsersPostViewCell
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
                        
        firebaseDBService.isPostLiked(postRow: postRow) { isLiked in
            if (isLiked) {
                cell.likeButton.setImage(iconLiked, for: .normal)
            } else {
                cell.likeButton.setImage(iconNonLiked, for: .normal)
            }
        }
        cell.cellProtocol = self
        cell.indexPath = indexPath
                
        cell.usersPostImage.sd_setImage(with: URL(string: postRow.postImageUrl ?? ""))
    
        firebaseAuhtService.getUserName(uid: postRow.userUID!) { username in
            if let username = username {
                cell.userNameLabe.text = "\(username)"
                cell.userNameUpperLabel.text = "\(username)"
            }
        }
        
        firebaseAuhtService.getUserPhotoURL(uid: postRow.userUID!) { usersProfileImageUrl  in
            if let url = usersProfileImageUrl {
                cell.userPPImage.sd_setImage(with: URL(string: url))
            } else {
                cell.userPPImage.setInitialImages()
            }
        }
        
        cell.likeCountLabel.text = "\(postRow.likeCount) likes"
        cell.descriptionLabel.text = postRow.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
