//
//  CreateProfileViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-21.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePictureButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var occupationTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var currentUser = User()
    
    var selectedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.occupationTextField.delegate = self
        
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.borderColor = UIColor.orange.cgColor
        confirmButton.layer.borderWidth = 1
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileView)))
        profileImageView.isUserInteractionEnabled = true
        
        fetchUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        let pickerController = UIImagePickerController()
        present(pickerController, animated: true, completion: nil)
        
        pickerController.delegate = self
        pickerController.allowsEditing = true

    }
    
    @objc func handleSelectProfileView () {
        let pickerController = UIImagePickerController()
        present(pickerController, animated: true, completion: nil)
        
        pickerController.delegate = self
        pickerController.allowsEditing = true
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        
        if (usernameTextField.text?.isEmpty)! || (occupationTextField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Profile Incomplete", message: "Please enter your name and occupation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oups", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else {
            if FBSDKAccessToken.current() != nil || Auth.auth().currentUser?.uid != nil{
                let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                let storageRef = Storage.storage().reference().child("profileImage").child((Auth.auth().currentUser?.uid)!)
                var data = selectedImage?.jpegData(compressionQuality: 1.0)
                if data == nil {
                    data = UIImage(named: "ProfilePic")?.jpegData(compressionQuality: 1.0)
                }
                
                let uploadTask = storageRef.putData(data!, metadata: nil) { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        return
                    }
                                        
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        let profileImageURL = downloadURL.absoluteString
                        print("the profile image URL is \(profileImageURL)")
                        
                        ref.child("profilePictureURL").setValue(profileImageURL)
                        ref.child("userID").setValue(self.currentUser.userID)
                        ref.child("name").setValue(self.usernameTextField.text)
                        ref.child("occupation").setValue(self.occupationTextField.text)
                    }
                }
            }
        }
        performSegue(withIdentifier: "createProfileToNavigationController", sender: self)
    }
    
    func fetchUser() {
        if let uid = Auth.auth().currentUser?.uid {
            print(uid)
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.currentUser.name = dictionary["name"] as? String
                    self.currentUser.email = dictionary["email"] as? String
                    self.currentUser.occupation = dictionary["occupation"] as? String
                    self.currentUser.userID = uid
                    
                    if self.currentUser.name?.isEmpty == false && self.currentUser.occupation?.isEmpty == false {
                        self.performSegue(withIdentifier: "createProfileToNavigationController", sender: self)
                    }
                    
                }
            }, withCancel: nil)

            
            
        } else {
            print("error fetching user")
        }
        
        
    }
    
    
    //MARK:- TextField Delegate Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @ objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did select a picture")
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.selectedImage = editedImage
            profileImageView.image = self.selectedImage
            print("edited image")
            
        } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.selectedImage = image
            profileImageView.image = self.selectedImage
        }
        
        
        dismiss(animated: true, completion: nil)
    }
}

