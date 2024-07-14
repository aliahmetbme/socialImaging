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
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureDesign()
        passwordTextField.initialTextFieldDesign()
        emailTextField.initialTextFieldDesign()
        usernameTextField.initialTextFieldDesign()
        nameTextField.initialTextFieldDesign()

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profilePicture.image = selectedImage
            
            let storage = Storage.storage()
            
            // Resmi Firebase Storage'a yükleyin ve URL'yi alın
            if let imageData = selectedImage.jpegData(compressionQuality: 0.5) {
                let storageRef = storage.reference().child("profile_pictures").child("\(Auth.auth().currentUser?.uid ?? "default").jpg")
                
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if error != nil {
                        print("Error uploading image: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        if let downloadURL = url {
                            self.imageURL = url
                        } else {
                            print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func profilePictureDesign() {
        profilePicture.layer.cornerRadius = 50
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.gray.cgColor
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.shadowOffset = CGSize(width: 5, height: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

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
            self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        if let url = imageURL {
            self.updateUserPhotoURL(downloadURL: url)
        }
    }
}
