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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
