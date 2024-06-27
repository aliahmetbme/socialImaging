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

    @IBOutlet var profilepicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        profilepicture.layer.cornerRadius = 75
        profilepicture.clipsToBounds = true
        // Do any additional setup after loading the view.
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
