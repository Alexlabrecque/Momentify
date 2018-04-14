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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK :- Presenting User's Information
    
    func fetchUser() {

        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot)
            
            //Create User Object to store user info and load quicker to implement
            
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
        
        performSegue(withIdentifier: "logOutGoToAuth", sender: self)
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
