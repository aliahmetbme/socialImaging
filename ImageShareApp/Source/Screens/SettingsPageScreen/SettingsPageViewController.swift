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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        initialDesign()
        profilePicture.profileSettingsPagePictureDesign(cornerRadius: 75)
        passwordTextField.initialTextFieldDesign()
        usernameTextField.initialTextFieldDesign()
        nameTextField.initialTextFieldDesign()
        saveButton.initialButtonDesign()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let profilePictureURL = curretUserProfilePictureURL {
            profilePicture.sd_setImage(with: profilePictureURL)
        } else {
            profilePicture.setInitialImages()
        }
    }
       
    func initialDesign () {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profilePicture.image = selectedImage
            profileImageBuffer = selectedImage
            self.dismiss(animated: true, completion: nil)
        }
    }
        
    @objc func keyboardWillShow(_ notification: Notification) {
       guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height / (self.view.frame.size.height * 0.003)
                
        UIView.animate(withDuration: 0.1) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            self.navigationController?.navigationBar.isHidden = true
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1) {
            self.view.transform = .identity
            self.navigationController?.setNavigationBarHidden(true, animated: true)
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


// Actions
extension SettingsPageViewController {
    
    
    @IBAction func turnBackProfilePage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takeImage(_ sender: Any) {
        
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
    
    @IBAction func saveChanges () {
        
        print("deneme")
        
        // change name
        if (nameTextField.text != ""){
            updateDisplayName(newDisplayName: nameTextField.text!)
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
            changePassword(newPassword: passwordTextField.text!)
        }
        
        // change Profile Picture
        if let profileImageBuffer = profileImageBuffer {
            self.updateUserPhotoURL(selectedImage: profileImageBuffer)
        }
    }
}
