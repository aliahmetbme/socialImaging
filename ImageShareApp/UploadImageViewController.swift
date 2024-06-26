//
//  UploadImageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var comment: UITextField!
    @IBOutlet var openCamerabutton: UIButton!
    @IBOutlet var uploadbutton: UIButton!
    @IBOutlet var uploadImage: UIImageView!
    
    let initialImage = UIImage(named: "uploadimage")

    var selectedImage: UIImage?
    var currentTextField: UITextField?

    var originalTransform: CGAffineTransform = .identity // originalTransform'u tanımlayın

    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadImage.image = initialImage
        
        //checkIsShouldEnabledUploadButton()
        comment.delegate = self
             
        uploadImage.layer.cornerRadius = 20
        uploadbutton.layer.cornerRadius = 15
        uploadbutton.configuration?.imagePadding = 10
        openCamerabutton.layer.cornerRadius = 15
        openCamerabutton.configuration?.imagePadding = 20
        uploadbutton.clipsToBounds = true
        openCamerabutton.clipsToBounds = true
        //comment.layer.cornerRadius = 10
        comment.leftView =  UIView(frame: CGRect(x: 0, y: 0, width: 10, height: comment.frame.height))
        comment.leftViewMode = .always
        comment.clipsToBounds = true
        
        let gestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(takeImageFromGallary))
        uploadImage.addGestureRecognizer(gestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    func checkIsShouldEnabledUploadButton () {
        if (uploadImage.image == initialImage && comment.text == "") {
            uploadbutton.isEnabled = false
        } else {
            uploadbutton.isEnabled = true

        }
    }
    
    
    @objc func takeImageFromGallary () {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // TODO:
        // resim boyutunu tekrar ele al
        // ya aynısını koyup backgroundu yok et
        
        // uploadImage.backgroundColor = .systemBackground
        // uploadImage.image = info[.editedImage] as? UIImage

        selectedImage = info[.editedImage] as? UIImage
        
        // ya boyunu ayarla
        uploadImage.image = selectedImage?.resized(to: CGSize(width: uploadImage.frame.width, height: uploadImage.frame.height))
        
        self.dismiss(animated: true)
                            
    }
    
    @IBAction func openCameraTakeImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.showsCameraControls = true
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadPost(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        
        let mediaFolder = storageReferance.child("media")
        // child direk dosya açıyor altına
        
        if let ImageData = selectedImage?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString // Direk uydurma bir id veriyor, farklılaştırma adına
            
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            
            imageReferance.putData(ImageData) { StorageMetadata, error in
                if error != nil {
                    self.showErrorMessage(title: "Error", message:  (error?.localizedDescription ?? "Try again"))
                } else {
                    imageReferance.downloadURL { url, Error in
                        if error == nil {
                            // resmin storage'dan linkini alıyor
                            let imageUrl = url?.absoluteString // url'i string e çevirip veriyor
                            
                            if let ImageUrl = imageUrl {
                                
                                let fireStoreDataBase = Firestore.firestore()
                                
                                let comments:[String] = ["Çok güzel olmuş", "Çok beğendim", "çok iğrenç"]
                                
                                let fireStorePost = ["imageUrl" : ImageUrl, "comment": self.comment.text!, "email" : Auth.auth().currentUser!.email!, "date" : FieldValue.serverTimestamp(), "comments": comments  ] as [String : Any]
                                                               
                                fireStoreDataBase.collection("Post").addDocument(data: fireStorePost) { error in
                                    if error != nil {
                                        
                                        self.showErrorMessage(title: "Error", message: error?.localizedDescription ?? "Try again")
                                        print("Hata \(String(describing: error?.localizedDescription))")
                                        
                                    } else {
                                        
                                        self.showErrorMessage(title: "Congrulation", message: "Successful")
                                        print("Successfully Uploaded")
                                        
                                        self.uploadImage.image = UIImage(named: "uploadimage")
                                        self.comment.text = ""
                                    }
                                }
                            } else {
                                self.showErrorMessage(title: "Hatttaaaa", message: error?.localizedDescription ?? "Try again")
                                print( "Hatttaaaa")
                            }
                        }  else {
                            self.showErrorMessage(title: "Hatta", message: error?.localizedDescription ?? "Try again")
                            print( "Hattta")
                        }
                    }
                }
            }
        }
    }
    
    func showErrorMessage (title:String , message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
    }
        
    @objc func keyboardWillShow(_ notification: Notification) {
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            // currentTextField güncellenmiş olmalı
            guard let textField = currentTextField else { return }
            
            let textFieldFrame = textField.convert(textField.bounds, to: nil)
            let maxY = textFieldFrame.maxY
            let keyboardY = keyboardFrame.origin.y
            
            if maxY > keyboardY {
                let keyboardHeight = maxY - keyboardY
                
                UIView.animate(withDuration: 0.1) {
                    self.originalTransform = self.view.transform
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }
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

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
