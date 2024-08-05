//
//  UploadImageViewController.swift
//  ImageShareApp
//
//  Created by Ali ahmet Erdoğdu on 23.06.2024.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadImageViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var comment: UITextField!
    @IBOutlet var openCamerabutton: UIButton!
    @IBOutlet var uploadbutton: UIButton!
    @IBOutlet var uploadImage: UIImageView!
    
    let initialImage = UIImage(named: "uploadimage")

    var selectedImage: UIImage?
    var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialDesign()
        initialSettings()
        checkIsShouldEnabledUploadButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialDesign()
        initialSettings()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImage = info[.editedImage] as? UIImage
        uploadImage.image = selectedImage?.resized(to: CGSize(width: uploadImage.frame.width, height: uploadImage.frame.height))
        
        self.dismiss(animated: true)
    }
    
    private func initialSettings () {
        self.uploadImage.image = UIImage(named: "uploadimage")
        self.comment.text = ""
    }
    
    private func initialDesign() {
        navigationController?.navigationBar.isHidden = true
        uploadImage.image = initialImage
        uploadImage.layer.cornerRadius = 20

        uploadbutton.initialButtonDesign()
        openCamerabutton.initialButtonDesign(imagePadding: 20)
        
        comment.initialTextFieldDesign(cornerRadius:20)
        comment.delegate = self
        
        let gestureRecognizer  = UITapGestureRecognizer(target: self, action: #selector(takeImageFromGallary))
        uploadImage.addGestureRecognizer(gestureRecognizer)

    }
    
    private func checkIsShouldEnabledUploadButton () {
        if (uploadImage.image == initialImage || comment.text == "") {
            uploadbutton.isEnabled = false
        } else {
            uploadbutton.isEnabled = true

        }
    }
            
    private func showErrorMessage (title:String , message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

// Actions
extension UploadImageViewController {
    
    @IBAction func openCameraTakeImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.showsCameraControls = true
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @objc func takeImageFromGallary () {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func uploadPost(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        let fireStoreDataBase = Firestore.firestore()
        let mediaFolder = storageReferance.child("media") // Direk uydurma bir id veriyor, farklılaştırma adına
        let uuid = UUID().uuidString
        let imageReferance = mediaFolder.child("\(uuid).jpg") // child direk dosya açıyor altına
        let userUID = Auth.auth().currentUser?.uid
        
        if let ImageData = selectedImage?.jpegData(compressionQuality: 0.5) {
            self.uploadbutton.isEnabled = false
            imageReferance.putData(ImageData) { StorageMetadata, error in
                if error != nil {
                    self.showErrorMessage(title: "Error", message:  (error?.localizedDescription ?? "Try again"))
                } else {
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                            
                            if let postImageUrl = url?.absoluteString { // resmin storage'dan linkini alıyor, url'i string e çevirip veriyor
                                
                                let post = PostUploadModel(imageUrl: postImageUrl,
                                                           userUID: userUID,
                                                           comment: self.comment.text!,
                                                           date: (FieldValue.serverTimestamp()),
                                                           likeCount: 0).toDictionary()
                                
                                fireStoreDataBase.collection("Post").addDocument(data: post) { error in
                                    if error != nil {
                                        self.checkIsShouldEnabledUploadButton()
                                        self.showErrorMessage(title: "Error", message: error?.localizedDescription ?? "Try again")
                                    } else {
                                        self.initialSettings()
                                        self.checkIsShouldEnabledUploadButton()
                                        self.showErrorMessage(title: "Congrulation", message: "Successful")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// UITextFieldDelegate yöntemleri
extension UploadImageViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("comment editing = \(comment.text!)")
        checkIsShouldEnabledUploadButton()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("comment edit finished = \(comment.text!)")
        checkIsShouldEnabledUploadButton()

    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        comment.text = ""
        print("comment cleared = \(comment.text!)")
        checkIsShouldEnabledUploadButton()
        return true // TextField'ın temizlenmesine izin vermek için true döndür
    }
}
