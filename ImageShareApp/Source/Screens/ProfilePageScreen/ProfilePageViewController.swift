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
    
    var postArray: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        profilepicture.profilePictureDesign()
                   
        postsTable.delegate = self
        postsTable.dataSource = self
        
        getUsersPostfromDB()
        initialSettings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        initialSettings()
        getUsersPostfromDB()
    }
    
    func initialSettings () {
        if let profilePictureURL = Auth.auth().currentUser?.photoURL?.absoluteString {
            profilepicture.sd_setImage(with: URL(string: profilePictureURL))
        } else {
            
        }
        
        if let Name = Auth.auth().currentUser?.displayName {
            nameLabel.text = Name
        }
        
        getUserName { userName in
            if let username = userName {
                self.usernameLabel.text = "@\(username)"
            }
        }
    }
    
    func getUsersPostfromDB () {
        
        let fireStoredb = Firestore.firestore()
        let userEmail = Auth.auth().currentUser?.email
        
        fireStoredb.collection("Post").whereField("email", isEqualTo: userEmail as Any).order(by:"date", descending: true).addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("Veri alınamadı: \(String(describing: error?.localizedDescription))")
                self.postCount.text = "\(self.postArray.count)"
                return
            } else {
                if let snapshot = querySnapshot, !snapshot.isEmpty {
                    self.postArray.removeAll()

                    for document in snapshot.documents {
                        // documanların özel idleri
                        let documentid = document.documentID
                       // any olarak döndürüyor Stringe çevirememiz lazım
                        let imageurl = document.get("imageUrl") as? String ?? ""
                        let email = document.get("email") as? String ?? ""
                        let date = document.get("date") as? String ?? ""
                        let description = document.get("comment") as? String ?? ""
                        let comments = document.get("comments") as? [String] ?? []
                        let likeCount = document.get("likeCount") as? Int ?? 0
                        let userProfileImageUrl = document.get("userProfileImage") as? String ?? ""
                        
                        let post = PostModel(email: email, imageUrl: imageurl, description: description, date: date, comments: comments, likeCount: likeCount, usersProfileImageUrl: userProfileImageUrl, postId: documentid)
                        
                        self.postArray.append(post)
                        
                        DispatchQueue.main.async {
                            self.postsTable.reloadData()
                        }  
                    }
                    self.postCount.text = "\(self.postArray.count)"

                } else {
                    print("Post Yok")
                }
            }
        }
    }
}

// Actions
extension ProfilePageViewController {
    
    @IBAction func logout(_ sender: Any) {
        do {
           try Auth.auth().signOut()
        } catch {
            print("Hata")
        }
        performSegue(withIdentifier: "toLoginVc", sender: nil)
    }
    
    @IBAction func goSettingsPage(_ sender: Any) {
        performSegue(withIdentifier: "toSettingsPage", sender: nil)

    }
}


// UITableView
extension ProfilePageViewController: UITableViewDelegate, UITableViewDataSource, UserPostViewCellProtocol {
    
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
        
        let cell = postsTable.dequeueReusableCell(withIdentifier: "usersPostCell", for: indexPath) as! UsersPostViewCell
        
        cell.cellProtocol = self
        cell.indexPath = indexPath
        
        let postRow = postArray[indexPath.row]

        cell.usersPostImage.sd_setImage(with: URL(string: postRow.imageUrl ?? ""))
        cell.descriptionLabel.text = postRow.description
        cell.likeCountLabel.text = "\(postRow.likeCount) likes"
        if (postRow.usersProfileImageUrl != "") {
            getUserPhotoURL(uid: postRow.usersProfileImageUrl) { usersProfileImageUrl  in
                if let url = usersProfileImageUrl {
                    cell.userPPImage.sd_setImage(with: URL(string: url))
                }
            }
        } else {
            cell.userPPImage.setInitialImages()
        }       
        cell.userNameLabe.text = postRow.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
