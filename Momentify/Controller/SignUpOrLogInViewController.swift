//
//  SignUpOrLogInViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-28.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import Firebase

class SignUpOrLogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    var currentUser = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.borderWidth = 1
        signUpButton.layer.borderColor = UIColor.orange.cgColor
        
        logInButton.layer.cornerRadius = 10
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.orange.cgColor
        
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.delegate = self

        
        let newCenter = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 40)
        FBLoginButton.center = newCenter
        view.addSubview(FBLoginButton)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    
    // MARK: - Facebook Login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        print(credential)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                return
            }
            let uid = user?.uid
            
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    print(snapshot)
                    
                    self.currentUser.name = dictionary["name"] as? String
                    self.currentUser.email = dictionary["email"] as? String
                    self.currentUser.occupation = dictionary["occupation"] as? String
                    self.currentUser.userID = uid
                }
                if self.currentUser.name?.isEmpty == true || self.currentUser.occupation?.isEmpty == true {
                    self.setUserInformation(email: "Facebook Log in", name: "", occupation: "", uid: uid!)
                    
                    self.performSegue(withIdentifier: "goToCreateFBProfile", sender: self)
                } else {
                    self.performSegue(withIdentifier: "goToCreateFBProfile", sender: self)
                }
            }, withCancel: nil)
            
            
            //self.setUserInformation(email: "Facebook Log in", name: "", occupation: "", uid: uid!)
            
            //self.performSegue(withIdentifier: "goToCreateFBProfile", sender: self)
            
        }
    }
    
    func setUserInformation(email: String, name: String, occupation: String, uid: String) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["email": email, "name": name, "occupation": occupation, "userID": uid])
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    
    // MARK: - Navigation
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToLogIn", sender: self)
    }
}
