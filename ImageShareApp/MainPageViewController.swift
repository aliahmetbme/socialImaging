//
//  MainPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class MainPageViewController: UIViewController {

    @IBOutlet var postsList: UITableView!
    var postArray: [PostModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        postsList.delegate = self
        postsList.dataSource = self
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    func getData () {
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
                    
                    for document in snapshot.documents {
                        // documanların özel idleri
                        //let documentid = document.documentID
                       // any olarak döndürüyor Stringe çevirememiz lazım
                        let imageurl = document.get("imageUrl") as? String ?? ""
                        let email = document.get("email") as? String ?? ""
                        let date = document.get("date") as? String ?? ""
                        let description = document.get("comment") as? String ?? ""
                        let comments = document.get("comments") as? [String] ?? []
                        
                        let post = PostModel(email: email, imageUrl: imageurl, description: description, date: date, comments: comments)
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
                secondVC.comments = post.comments
            }
        }
    }

    func showComments(indexPath: IndexPath) {
        performSegue(withIdentifier: "goCommentsVC", sender: indexPath)
    }
        
    func clicked(indexPath: IndexPath) {
        
        if let cell = postsList.cellForRow(at: indexPath) as? PostViewCell {
             let icon = UIImage(systemName: "heart.fill")
             cell.likeButton.setImage(icon, for: .normal)
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
        
        // her bir hücer için protocollerin kullanabilmek için
        cell.cellProtocol = self
        cell.indexPath = indexPath
        
        cell.descriptionLabel.text = postRow.description
        cell.usernameDown.text = postRow.email
        cell.usernameUpper.text = postRow.email
        
        cell.postImage.sd_setImage(with: URL(string: postRow.imageUrl ?? ""))
        return cell
    }
}


 
