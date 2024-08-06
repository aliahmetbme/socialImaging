//
//  SettingsPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 26.06.2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class SettingsPageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    var profileImageBuffer: UIImage?
    @IBOutlet var saveButton: UIButton!
    let curretUserProfilePictureURL = Auth.auth().currentUser?.photoURL
    let firebaseAuthService = FireBaseAuthService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        initialDesign()
    }
       
    private func initialDesign () {
        if let profilePictureURL = curretUserProfilePictureURL {
            profilePicture.sd_setImage(with: profilePictureURL)
        } else {
            profilePicture.setInitialImages()
        }
        profilePicture.profileSettingsPagePictureDesign(cornerRadius: 75)
        passwordTextField.initialTextFieldDesign()
        usernameTextField.initialTextFieldDesign()
        nameTextField.initialTextFieldDesign()
        saveButton.initialButtonDesign()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profilePicture.image = selectedImage
            profileImageBuffer = selectedImage
            self.dismiss(animated: true, completion: nil)
        }
    }
}


// Actions
extension SettingsPageViewController {
    
    
    @IBAction private func turnBackProfilePage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func takeImage(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let pickerController = UIImagePickerController()
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let chooseCamera = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            
            pickerController.delegate = self
            pickerController.sourceType = .camera
            pickerController.showsCameraControls = true
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let chooseGallary = UIAlertAction(title: "Photo Gallary", style: .default) { UIAlertAction in
            
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
        
        alert.addAction(chooseCamera)
        alert.addAction(chooseGallary)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction private func saveChanges () {
        
        // change name
        if (nameTextField.text != ""){
            firebaseAuthService.updateDisplayName(newDisplayName: nameTextField.text!)
        }
        
        // change user name
        if (usernameTextField.text != "") {
            if let uid = Auth.auth().currentUser?.uid  {
                Firestore.firestore().collection("User").document(uid).setData(["userName": usernameTextField.text!]) {
                    error in if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                }
            }
        }
        
        // change password
        if (passwordTextField.text != "") {
            firebaseAuthService.changePassword(newPassword: passwordTextField.text!)
        }
        
        // change Profile Picture
        if let profileImageBuffer = profileImageBuffer {
            firebaseAuthService.updateUserPhotoURL(selectedImage: profileImageBuffer)
        }
    }
}
