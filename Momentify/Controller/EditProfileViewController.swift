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
import SVProgressHUD

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    let user = Auth.auth().currentUser
    
    var users = [User]()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var occupationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self
        self.occupationTextField.delegate = self
        
        self.fetchUser()
    
        self.nameTextField.textColor = UIColor.gray
        self.occupationTextField.textColor = UIColor.gray
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
            }
        }, withCancel: nil)
        
    }
    
    
    
    //MARK :- Edit Profile
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        let prntRefName  = Database.database().reference().child("users").child((user?.uid)!)
        prntRefName.updateChildValues(["name":nameTextField.text ?? "Name"])
        
        let prntRefOccupation  = Database.database().reference().child("users").child((user?.uid)!)
        prntRefOccupation.updateChildValues(["occupation":occupationTextField.text ?? "Occupation"])
        
        _ = navigationController?.popViewController(animated: true)

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
