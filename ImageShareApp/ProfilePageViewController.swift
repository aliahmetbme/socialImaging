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
    @IBOutlet var profilepicture: UIImageView!
    let profilePictureURL = Auth.auth().currentUser?.photoURL?.absoluteString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        profilepicture.layer.cornerRadius = 75
        profilepicture.clipsToBounds = true
        profilepicture.sd_setImage(with: URL(string: profilePictureURL ?? "" ))
        // Do any additional setup after loading the view.
        
        postsTable.dataSource = self
        postsTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
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
    
    
    
    // TODO: Postları ekle
    // TODO: post sayısını gerçekten al
}

extension ProfilePageViewController: UITableViewDelegate, UITableViewDataSource {
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postsTable.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        return cell
    }
    
    
    
    
    
}
