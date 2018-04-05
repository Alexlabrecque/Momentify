//
//  AuthenticationViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 18-04-03.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import FacebookLogin
import Firebase
import SVProgressHUD
import FBSDKLoginKit

class AuthenticationViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //let FBLoginButton = LoginButton(readPermissions: [ .publicProfile ])
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.delegate = self
        
        FBLoginButton.center = view.center
        view.addSubview(FBLoginButton)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK :- Create User
    
    @IBAction func createUserButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
        
            if error != nil {
                print(error!)
            } else {
                print("Registration Succesfull")
                SVProgressHUD.dismiss()
    
                self.performSegue(withIdentifier: "goToNavigationController", sender: self)
            }
        }
    }
    
    
    //MARK :- Log In

    // Log in via email
    @IBAction func logInButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error != nil{
                print(error!)
            } else {
                print("Log In Successfull")
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToNavigationController", sender: self)
            }
        }
    }
    
    
    //Log in via Facebook
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                return
            }
            self.performSegue(withIdentifier: "goToNavigationController", sender: self)
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // to understand why would need this
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
