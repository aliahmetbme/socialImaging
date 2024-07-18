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
        profilepicture.initialPictureDesign()
        getUsersPostfromDB()
        initialSettings()
        
        postsTable.delegate = self
        postsTable.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialSettings()
        getUsersPostfromDB()
    }
    
    private func initialSettings () {
        navigationController?.navigationBar.isHidden = true

        if let profilePictureURL = Auth.auth().currentUser?.photoURL {
            profilepicture.sd_setImage(with: profilePictureURL)
        } else {
            profilepicture.setInitialImages()
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
    
    private func getUsersPostfromDB () {
        
        let fireStoredb = Firestore.firestore()
        let userUID = Auth.auth().currentUser?.uid
        
        fireStoredb.collection("Post").whereField("userUID", isEqualTo: userUID as Any).order(by:"date", descending: true).addSnapshotListener { querySnapshot, error in
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
                        let postImageUrl = document.get("imageUrl") as? String ?? ""
                        let userUID = document.get("userUID") as? String ?? ""
                        let date = document.get("date") as? String ?? ""
                        let description = document.get("comment") as? String ?? ""
                        let comments = document.get("comments") as? [String] ?? []
                        let likeCount = document.get("likeCount") as? Int ?? 0
                       
                        let post = PostModel(postImageUrl: postImageUrl, userUID: userUID ,description: description, date: date, comments: comments, likeCount: likeCount, postId: documentid)
                        
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
        
        setLikedofPosts(cell: cell!, postArray: postArray, indexPath: indexPath, likeButton: cell!.likeButton) { updatedPost in
            self.postArray[indexPath.row] = updatedPost!
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
        let firestore = Firestore.firestore()
        let currentUserId = Auth.auth().currentUser?.uid  // Geçerli kullanıcının ID'sini alın
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")
        
        let cell = postsTable.dequeueReusableCell(withIdentifier: "usersPostCell", for: indexPath) as! UsersPostViewCell
        
        cell.cellProtocol = self
        cell.indexPath = indexPath
                
        if let userId = Auth.auth().currentUser?.uid {
            // Kullanıcının bu postu beğenip beğenmediğini kontrol et
            let likeDocRef = firestore.collection("Post").document(postRow.postId).collection("likes").document(userId)
            
            likeDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    cell.likeButton.setImage(iconLiked, for: .normal)
                } else {
                    cell.likeButton.setImage(iconNonLiked, for: .normal)

                }
            }
        }

        cell.usersPostImage.sd_setImage(with: URL(string: postRow.postImageUrl ?? ""))
        cell.descriptionLabel.text = postRow.description
        cell.likeCountLabel.text = "\(postRow.likeCount) likes"
        
    
        getUserName(uid: postRow.userUID!) { username in
            if let username = username {
                cell.userNameLabe.text = "\(username)"
                cell.userNameUpperLabel.text = "\(username)"
            }
        }
        
        getUserPhotoURL(uid: postRow.userUID!) { usersProfileImageUrl  in
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
