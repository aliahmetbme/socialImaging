//
//  CommentsPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 26.06.2024.
//

import UIKit

class CommentsPageViewController: UIViewController, UITextFieldDelegate {
    
    var comments: [String]?
    @IBOutlet var ppImage: UIImageView!
    @IBOutlet var addComment: UITextField!
    @IBOutlet var commentsLists: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        ppImage.layer.cornerRadius = 20
        ppImage.clipsToBounds = true
        addComment.delegate = self
        commentsLists.delegate = self
        commentsLists.dataSource = self
        
        // Sol tarafta buton eklemek için bir UIButton oluşturun
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
                
        // UITextField'a sol view olarak butonu ata
        addComment.leftView = button
        addComment.leftViewMode = .always
        
        addComment.layer.borderWidth = 1.0 // Kenarlık genişliği
        addComment.layer.cornerRadius = 17.0
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: addComment.frame.height))
        addComment.leftView = paddingView
        addComment.leftViewMode = .always
        addComment.delegate = self
    }
    
    @objc func searchButtonTapped() {
        // Burada buton tıklandığında yapılacak işlemleri tanımlayabilirsiniz
        print("Search button tapped!")
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

extension CommentsPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = commentsLists.dequeueReusableCell(withIdentifier: "commentcell", for: indexPath) as! CommentViewCell
        
        cell.commentLabel.text = "Bu çok uzun bir metin. Bu metin sığmazsa, aşağı satıra geçmelidir."
        cell.username.text = "crayzBoy69"
        return cell
    }
    
    
}

