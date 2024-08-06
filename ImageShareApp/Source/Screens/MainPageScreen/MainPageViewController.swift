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

    @IBOutlet private var PostsList: UITableView!
    private var postArray: [PostModel] = []
    private let firebaseAuhtService = FireBaseAuthService()
    private let firebaseDBService = FireBaseDBService()
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        tableViewInitialSettings()
        initialSettings()
        fetchAllPost()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // taking post again when back to page
        fetchAllPost()
    }
    // observing post changes real time
    private func fetchAndObserveChanges() {
        self.firebaseDBService.observePostChanges(postArray: self.postArray, tableView: self.PostsList) { updatedPostArray, indexPath in
            self.postArray = updatedPostArray
            
            if let indexPath = indexPath {
                self.PostsList.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    private func fetchAllPost() {
        firebaseDBService.getAllPosts { postData in
            self.postArray = postData
            self.PostsList.reloadData()
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull for refresh")
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        PostsList.refreshControl = refreshControl
    }
    
    @objc private func refreshTableView() {
        firebaseDBService.getAllPosts { postData in
            self.postArray = postData
            self.PostsList.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    private func initialSettings () {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func tableViewInitialSettings () {
        PostsList.delegate = self
        PostsList.dataSource = self
        
        PostsList.rowHeight = UITableView.automaticDimension
        PostsList.estimatedRowHeight = UITableView.automaticDimension
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
        let cell = PostsList.cellForRow(at: indexPath) as? PostViewCell
        let post = postArray[indexPath.row]
        
        firebaseDBService.setLikedofPosts(indexPath: indexPath, postId: post.postId, likeButton: cell!.likeButton, likeCount: post.likeCount, table: PostsList)
        // observing liked changes
        fetchAndObserveChanges()

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postRow = postArray[indexPath.row]
        let cell = PostsList.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostViewCell

        cell.cellProtocol = self
        cell.indexPath = indexPath
        cell.descriptionLabel.text = postRow.description
        cell.likeCount.text = "\(postRow.likeCount) likes"
       
        cell.usernameDown.text = "loading ..."
        cell.usernameUpper.text = "loading ..."
        cell.userpp.isHidden = true
       
        firebaseDBService.isPostLiked(postRow: postRow) { isLiked in
            DispatchQueue.main.async {
                if isLiked {
                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            }
        }

        firebaseAuhtService.getUserName(uid: postRow.userUID!) { username in
            DispatchQueue.main.async {
                if let username = username {
                    cell.usernameUpper.text = username
                    cell.usernameDown.text = username
                }
            }
        }

        firebaseAuhtService.getUserPhotoURL(uid: postRow.userUID!) { usersProfileImageUrl in
            DispatchQueue.main.async {
                cell.userpp.isHidden = false
                if let url = usersProfileImageUrl {
                    cell.userpp.sd_setImage(with: URL(string: url))
                } else {
                    cell.userpp.setInitialImages()
                }
            }
        }

        cell.postImage.sd_setImage(with: URL(string: postRow.postImageUrl ?? ""))

        return cell
    }
        
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
