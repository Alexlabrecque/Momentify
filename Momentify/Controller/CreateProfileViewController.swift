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
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.occupationTextField.delegate = self
        
        confirmButton.layer.cornerRadius = 10
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
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
    
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        if (usernameTextField.text?.isEmpty)! || (occupationTextField.text?.isEmpty)! {
            
            let alert = UIAlertController(title: "Profile Incomplete", message: "Please enter your name and occupation", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Oups", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else {
            if FBSDKAccessToken.current() != nil || Auth.auth().currentUser?.uid != nil{
            
                let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                let storageRef = Storage.storage().reference().child("profileImage").child((Auth.auth().currentUser?.uid)!)
                
                if let profileImg = selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                    storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        if error != nil {
                            return
                        }
                        let profileImageURL = metadata?.downloadURL()?.absoluteString
                        
                        ref.child("name").setValue(self.usernameTextField.text)
                        ref.child("occupation").setValue(self.occupationTextField.text)
                        ref.child("profilePictureURL").setValue(profileImageURL)
                    }
                }
                
                
            }
        
            performSegue(withIdentifier: "createProfileToNavigationController", sender: self)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did select a picture")
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.selectedImage = editedImage
            profileImageView.image = self.selectedImage
            
        } else if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.selectedImage = image
            profileImageView.image = self.selectedImage
        }
        
        
        dismiss(animated: true, completion: nil)
    }
}

