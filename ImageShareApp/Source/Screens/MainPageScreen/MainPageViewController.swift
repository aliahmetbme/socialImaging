//
//  MainPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class MainPageViewController: UIViewController {

    @IBOutlet private var postsList: UITableView!
    private var postArray: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        postsList.delegate = self
        postsList.dataSource = self
        
        postsList.rowHeight = UITableView.automaticDimension
        postsList.estimatedRowHeight = UITableView.automaticDimension
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getData () {
        let fireStoredb = Firestore.firestore()
        
        // addSnapshotListener dinleyici real time çalışabilmesi adına
        
        // .whereField(<#T##field: String##String#>, in: <#T##[Any]#>)
        // filtreleme yapabilmek adına
        
        // .order(by:"date", descending: true)
        // sıralama yapılır tarihe göre
        
        fireStoredb.collection("Post").order(by:"date", descending: true).addSnapshotListener { querySnapshot, error in
            if error != nil {
                print("Veri alınamadı: \(String(describing: error?.localizedDescription))")
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
                           self.postsList.reloadData() // TableView'i güncelle
                        }
                    }
                } else {
                    print("Post Yok")
                }
            }
        }
    }
}

extension MainPageViewController: UITableViewDelegate, UITableViewDataSource, PostViewCellProtocol {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "goCommentsVC" {
            if let indexPath = sender as? IndexPath {
                let secondVC = segue.destination as! CommentsPageViewController
                
                let post = postArray[indexPath.row]
                secondVC.postID = post.postId
            }
        }
    }
    
    func showComments(indexPath: IndexPath) {
        performSegue(withIdentifier: "goCommentsVC", sender: indexPath)
    }
    
    func clicked(indexPath: IndexPath) {
        
        if let cell = postsList.cellForRow(at: indexPath) as? PostViewCell {
            
            let iconLiked = UIImage(systemName: "heart.fill")
            let iconNonLiked = UIImage(systemName: "heart")
            let firestore = Firestore.firestore()
            var post = postArray[indexPath.row]
            let currentUserId = Auth.auth().currentUser?.uid  // Geçerli kullanıcının ID'sini alın
            
            if let userId = currentUserId {
                // Kullanıcının bu postu beğenip beğenmediğini kontrol et
                let likeDocRef = firestore.collection("Post").document(post.postId).collection("likes").document(userId)
                
                likeDocRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Kullanıcı zaten beğenmişse, beğeniyi kaldır
                        cell.likeButton.setImage(iconNonLiked, for: .normal)
                        post.likeCount -= 1
                        
                        // Firestore'dan beğenmeyi kaldır
                        firestore.collection("Post").document(post.postId).setData([
                            "likeCount": post.likeCount
                        ],merge: true)
                        
                        // Kullanıcıyı "likes" alt koleksiyonundan kaldır
                        likeDocRef.delete()
                    } else {
                        // Kullanıcı beğenmemişse, beğeniyi ekle
                        cell.likeButton.setImage(iconLiked, for: .normal)
                        post.likeCount += 1
                        
                        // Firestore'a beğeniyi ekle
                        firestore.collection("Post").document(post.postId).setData([
                            "likeCount": post.likeCount
                        ], merge: true)
                        
                        // Kullanıcıyı "likes" alt koleksiyonuna ekle
                        likeDocRef.setData([
                            "userId": userId,
                            "timestamp": FieldValue.serverTimestamp()
                        ])
                    }
                    
                    // Update the local postArray with the new likeCount
                    self.postArray[indexPath.row] = post
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // dequeueReusableCell : yeniden kullanılabilen
        // oluştur sonra cast ediyorsun sınıfa sınıftaki şeylere ulaşabilmen adına
        
        let postRow = postArray[indexPath.row]
        let cell = postsList.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostViewCell
        let firestore = Firestore.firestore()
        let currentUserId = Auth.auth().currentUser?.uid  // Geçerli kullanıcının ID'sini alın
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")

        if let userId = currentUserId {
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
            
            // her bir hücre için protocollerin kullanabilmek için
            cell.cellProtocol = self
            cell.indexPath = indexPath
            
            cell.descriptionLabel.text = postRow.description
            cell.usernameDown.text = postRow.email
            cell.usernameUpper.text = postRow.email
            cell.userpp.sd_setImage(with: URL(string: postRow.usersProfileImageUrl))
            cell.postImage.sd_setImage(with: URL(string: postRow.imageUrl ?? ""))
            cell.likeCount.text = "\(postRow.likeCount) likes"
            
            return cell
        }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    }
