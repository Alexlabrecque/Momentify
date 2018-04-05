//
//  SessionsViewController.swift
//
//
//  Created by Alexandre Labrecque on 18-04-03.
//

import UIKit
import FacebookLogin
import Firebase
import SVProgressHUD
//import FBSDKCoreKit
import FBSDKLoginKit

class SessionsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Mark : - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        verifyIfUserIsLoggedIn()
        
        // UIBarButton bug
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToFilter", sender: self)
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToCreate", sender: self)
    }
    
    @IBAction func notificationsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNotifications", sender: self)
    }
 
    // MARK :- Logged In Verification
    
    func verifyIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            // User logged in via email
        }else if FBSDKAccessToken.current() != nil{
            // User logged in via Facebook
        }else {
            // User not logged in
            performSegue(withIdentifier: "goToAuth", sender: self)
        }
    }
    
    
}


