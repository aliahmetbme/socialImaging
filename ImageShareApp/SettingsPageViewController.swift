//
//  SettingsPageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 26.06.2024.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SettingsPageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var profilePicture: UIImageView!
    private var buttomConstraint: NSLayoutConstraint!

    var originalTransform: CGAffineTransform = .identity // originalTransform'u tanımlayın
    var currentTextField: UITextField?
    

    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureDesign()
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: passwordTextField.frame.height))
        passwordTextField.leftView = paddingView
        passwordTextField.leftViewMode = .always
        passwordTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1.0 // Kenarlık genişliği
        passwordTextField.layer.cornerRadius = 8.0
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        
        
        let paddingView_ = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: emailTextField.frame.height))
        emailTextField.leftView = paddingView_
        emailTextField.leftViewMode = .always
        emailTextField.delegate = self
        
        emailTextField.layer.borderWidth = 1.0 // Kenarlık genişliği
        emailTextField.layer.cornerRadius = 8.0
        emailTextField.layer.borderColor = UIColor.gray.cgColor

        let _paddingView_ = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: usernameTextField.frame.height))
        usernameTextField.leftView = _paddingView_
        usernameTextField.leftViewMode = .always
        usernameTextField.delegate = self
        
        usernameTextField.layer.borderWidth = 1.0 // Kenarlık genişliği
        usernameTextField.layer.cornerRadius = 8.0
        usernameTextField.layer.borderColor = UIColor.gray.cgColor

        let _padding_ = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameTextField.frame.height))
        nameTextField.leftView = _padding_
        nameTextField.leftViewMode = .always
        nameTextField.delegate = self
        
        nameTextField.layer.borderWidth = 1.0 // Kenarlık genişliği
        nameTextField.layer.cornerRadius = 8.0
        nameTextField.layer.borderColor = UIColor.gray.cgColor

    }
    
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
                            // Kullanıcı profilini güncelleyin
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = downloadURL
                            changeRequest?.commitChanges { error in
                                if let error = error {
                                    print("Error updating profile: \(error.localizedDescription)")
                                } else {
                                    print("Profile updated successfully")
                                }
                            }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
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
