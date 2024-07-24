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
    let firebaseAuhtService = FireBaseAuthService()
    let firebaseDBService = FireBaseDBService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialSettings()
    }
    
    private func initialSettings () {
        navigationController?.navigationBar.isHidden = true
        
        postsList.delegate = self
        postsList.dataSource = self
        
        postsList.rowHeight = UITableView.automaticDimension
        postsList.estimatedRowHeight = UITableView.automaticDimension
        
        firebaseDBService.getPosts(tableView: postsList) { postData in
            self.postArray = postData
            self.postsList.reloadData()
        }
       
    }

}

// TableView
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
        
        let cell = postsList.cellForRow(at: indexPath) as? PostViewCell
        
        firebaseDBService.setLikedofPosts(post: postArray[indexPath.row], likeButton: cell!.likeButton) {updatedPost in
            self.postArray[indexPath.row] = updatedPost!
            cell?.reloadInputViews()
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
        let iconLiked = UIImage(systemName: "heart.fill")
        let iconNonLiked = UIImage(systemName: "heart")

        
        firebaseDBService.isPostLiked(postRow: postRow) { isLiked in
            if (isLiked) {
                cell.likeButton.setImage(iconLiked, for: .normal)
            } else {
                cell.likeButton.setImage(iconNonLiked, for: .normal)
            }
        }
            
        // her bir hücre için protocollerin kullanabilmek için
        cell.cellProtocol = self
        cell.indexPath = indexPath
        
        cell.descriptionLabel.text = postRow.description
    
        firebaseAuhtService.getUserName(uid: postRow.userUID!) { username in
                if let username = username {
                    cell.usernameUpper.text = username
                    cell.usernameDown.text = username
            }
        }
                
        firebaseAuhtService.getUserPhotoURL(uid: postRow.userUID!) { usersProfileImageUrl  in
                if let url = usersProfileImageUrl {
                    cell.userpp.sd_setImage(with: URL(string: url))
                } else {
                    cell.userpp.setInitialImages()
                }
            }
            
            cell.postImage.sd_setImage(with: URL(string: postRow.postImageUrl ?? ""))
            cell.likeCount.text = "\(postRow.likeCount) likes"
            
            return cell
        }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
