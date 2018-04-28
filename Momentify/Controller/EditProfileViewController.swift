//
//  EditProfileViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 18-04-05.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin
import FBSDKLoginKit

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var occupationTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var changePictureButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var user = User()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        self.occupationTextField.delegate = self
        
        self.fetchUser()
    
        self.nameTextField.textColor = UIColor.gray
        self.occupationTextField.textColor = UIColor.gray

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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                self.nameTextField.text = dictionary["name"] as? String
        
                self.occupationTextField.text = dictionary["occupation"] as? String
                
                self.user.profilePictureURL = dictionary["profilePictureURL"] as? String
                
                if let url = URL(string: self.user.profilePictureURL!) {
                    URLSession.shared.dataTask(with: url) { (data, res, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.profileImageView.image = UIImage(data: data!)
                            self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
                            self.profileImageView.contentMode = .scaleAspectFit
                        }
                        
                    }.resume()
                }

            }
        }, withCancel: nil)
        
    }
    
    
    
    //MARK :- Edit Profile
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
         if FBSDKAccessToken.current() != nil || Auth.auth().currentUser?.uid != nil{
            
            let uid = Auth.auth().currentUser?.uid
            let ref  = Database.database().reference().child("users").child(uid!)
            ref.updateChildValues(["name":nameTextField.text ?? "Name"])

            ref.updateChildValues(["occupation":occupationTextField.text ?? "Occupation"])
            
            let storageRef = Storage.storage().reference().child("profileImage").child((Auth.auth().currentUser?.uid)!)
            
            if let profileImg = selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        return
                    }
                    let profileImageURL = metadata?.downloadURL()?.absoluteString
                    
                    ref.updateChildValues(["name":self.nameTextField.text ?? "Name"])
                    ref.updateChildValues(["occupation":self.occupationTextField.text ?? "Occupation"])
                    ref.updateChildValues(["profilePictureURL": profileImageURL!])
                }
            }
         }
        
        let alert = UIAlertController(title: "Profile edited", message: "Congrats on your new identity", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Gracias amigo", style: .default, handler: { action in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)

        //else if log in with facebook ->

    }
    
    
    @IBAction func changePictureButtonPressed(_ sender: Any) {
        let pickerController = UIImagePickerController()
        present(pickerController, animated: true, completion: nil)
        
        pickerController.delegate = self
        pickerController.allowsEditing = true
    }
    
    @objc func handleSelectProfileView() {
        let pickerController = UIImagePickerController()
        present(pickerController, animated: true, completion: nil)
        
        pickerController.delegate = self
        pickerController.allowsEditing = true
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
