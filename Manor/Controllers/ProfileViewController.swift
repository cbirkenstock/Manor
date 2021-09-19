//
//  ProfileViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/9/21.
//

import UIKit
import PhotosUI
import Firebase
import Amplify
import AmplifyPlugins

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    let usersRef = Database.database().reference().child("users")
    var user: User! = Firebase.Auth.auth().currentUser
    var commaUserEmail: String = ""
    let photoManager = PhotoManagerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.delegate = self
        lastName.delegate = self
        
        if let commaUserEmail = self.user.email?.replacingOccurrences(of: ".", with: ",") {
            self.commaUserEmail = commaUserEmail
        }
        
        self.profilePictureButton.backgroundColor = .systemRed
        
        self.loadInfo()
        
        
        profilePictureButton.layer.cornerRadius = profilePictureButton.bounds.height/2
        
        profilePictureButton.clipsToBounds = true
    }
    
    
    @IBAction func firstNameEditingBegan(_ sender: Any) {
        self.firstName.text = ""
    }
    
    
    @IBAction func lastNameEditingBegan(_ sender: Any) {
        self.lastName.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == firstName {
            self.usersRef.child("\(self.commaUserEmail)/firstName").setValue(firstName.text)
        } else {
            self.usersRef.child("\(self.commaUserEmail)/lastName").setValue(lastName.text)
        }
        
        return true
    }
    
    @IBAction func ProfilePicturePressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.photoManager.processPickerResultOld(imagePicker: picker, info: info, isTextMessage: false, isGroupMessage: false, isEventChat: false)
        /*picker.dismiss(animated: true, completion: nil)
         
         var selectedImageFromPicker: UIImage?
         
         if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
         selectedImageFromPicker = editedImage
         } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
         selectedImageFromPicker = originalImage
         }
         
         if let selectedImage = selectedImageFromPicker {
         let imageName = NSUUID().uuidString
         let storage = Storage.storage()
         let ref = storage.reference().child("Contact_images").child(imageName)
         
         if let uploadData = selectedImage.jpegData(compressionQuality: 0.2) {
         ref.putData(uploadData, metadata: nil) { metaData, err in
         if err != nil {
         print("failed to upload image:", err!)
         return
         }
         ref.downloadURL { url, err in
         if err != nil {
         print("failed to download URL", err!)
         } else if let imageURl = url?.absoluteString {
         
         }
         }
         }
         }
         }*/
    }
    
    func loadInfo() {
        usersRef.child(self.commaUserEmail).observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            if let firstName = postDict["firstName"] as? String, let lastName = postDict["lastName"] as? String {
                
                self.firstName.text = firstName
                self.lastName.text = lastName
                
                if let profileImageUrl = postDict["profileImageUrl"] as? String {
                    
                    Amplify.Storage.downloadData(key: profileImageUrl) { result in
                        switch result {
                        case .success(let data):
                            print("Success downloading image", data)
                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    //self.imageCache.setObject(image, forKey: NSImageURL)
                                    self.profilePictureButton.setBackgroundImage(image, for: .normal)
                                }
                            }
                        case .failure(let error):
                            print("failure downloading image", error)
                        }
                    }
                }
            }
        })
    }
}



