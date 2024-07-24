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

    var postArray: [PostModel] = []
    
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
        // getting Posts
        firebaseDBService.getPosts(tableView: postsTable, filterField: DBEndPoints.userUID.endPointsString) { postData in
            self.postArray = postData
            self.postCount.text = "\(postData.count)"
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
        
        firebaseDBService.setLikedofPosts( post: postArray[indexPath.row], likeButton: cell!.likeButton) { updatedPost in
            self.postArray[indexPath.row] = updatedPost!
            self.postsTable.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "profiletocommentVC" {
            if let indexPath = sender as? IndexPath {
                let secondVC = segue.destination as! CommentsPageViewController
                
                let post = postArray[indexPath.row]
                secondVC.postID = post.postId
            }
        }

    }
    
    func showComments(indexPath: IndexPath) {
        performSegue(withIdentifier: "profiletocommentVC", sender: indexPath)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postRow = postArray[indexPath.row]
        let cell = postsTable.dequeueReusableCell(withIdentifier: "usersPostCell", for: indexPath) as! UsersPostViewCell
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
                
        cell.cellProtocol = self
        cell.indexPath = indexPath
        
        firebaseDBService.isPostLiked(postRow: postRow) { isLiked in
            if (isLiked) {
                cell.likeButton.setImage(iconLiked, for: .normal)
            } else {
                cell.likeButton.setImage(iconNonLiked, for: .normal)
            }
        }
                
        cell.usersPostImage.sd_setImage(with: URL(string: postRow.postImageUrl ?? ""))
        cell.descriptionLabel.text = postRow.description
        cell.likeCountLabel.text = "\(postRow.likeCount) likes"
        
    
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
