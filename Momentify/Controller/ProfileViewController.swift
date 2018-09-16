//
//  ProfileViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 18-04-03.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import Firebase
import SVProgressHUD

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var userName: UITextView!
    @IBOutlet weak var userOccupation: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        
        editButton.layer.cornerRadius = 10
        editButton.layer.borderColor = UIColor.orange.cgColor
        editButton.layer.borderWidth = 1
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK :- Presenting User's Information
    
    func fetchUser() {
        
        var user = User()

        let uid = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference(forURL: "gs://momentify-83187.appspot.com/")
        
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                if self.userName.text.isEmpty {
                    self.userName.text = "Name"
                } else {
                    self.userName.text = dictionary["name"] as? String
                }
                
                if self.userOccupation.text.isEmpty {
                    self.userOccupation.text = "Occupation"
                } else {
                    self.userOccupation.text = dictionary["occupation"] as? String
                }
                
                user.profilePictureURL = dictionary["profilePictureURL"] as? String
                
                
                if let url = URL(string: user.profilePictureURL!) {
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
   
    
 
    // MARK :- Loggin Out
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            if FBSDKAccessToken.current() != nil {
                
                FBSDKLoginManager().logOut()
                //logged out of Facebook
            }
            
        } catch {
            print("Error, there was a problem signing out.")
        }
        navigationController?.popToRootViewController(animated: true)
        
        performSegue(withIdentifier: "profileToSignUpOrLogIn", sender: self)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // Needed to call FBSDKLoginManagerDelegate
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Needed to call FBSDKLoginManagerDelegate
    }
    
    
    
    // MARK :- Navigation
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
}
