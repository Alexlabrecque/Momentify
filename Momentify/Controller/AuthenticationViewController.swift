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
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import FBSDKLoginKit

class AuthenticationViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.delegate = self
        
        FBLoginButton.center = view.center
        view.addSubview(FBLoginButton)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        createUserButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
        logInButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
        
        createUserButton.isEnabled = false
        logInButton.isEnabled = false
        
        handleTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    //MARK:- Allow buttons to be pressed
    
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(AuthenticationViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(AuthenticationViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty
        else {
            createUserButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            logInButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
            
            createUserButton.isEnabled = false
            logInButton.isEnabled = false
            
            return
        }
        createUserButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        createUserButton.isEnabled = true
        logInButton.isEnabled = true
    }
    
    
    
    //MARK:- Create User
    
    @IBAction func createUserButtonPressed(_ sender: Any) {
        
        if emailTextField.text?.isEmpty == true || emailTextField.text?.contains("@") == false {
            
            let alert = UIAlertController(title: "Unvalid Email Adress", message: "Please enter a valid one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else if passwordTextField.text?.isEmpty == true || (passwordTextField.text?.count)! < 6 {
            
            let alert = UIAlertController(title: "Unvalid Password", message: "Password must include at least 6 chararcters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else {
        print("seems all right")
            SVProgressHUD.show()
        
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in

                if error != nil {
                    print(error!)
                    SVProgressHUD.dismiss()
                    
                    let alert = UIAlertController(title: "Unvalid Email Adress", message: "Please enter a valid one", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    
                    return
                } else {
                
                    let uid = user?.uid
                    self.setUserInformation(email: self.emailTextField.text!, name: "", occupation: "", uid: uid!)
                
                    SVProgressHUD.dismiss()
                
                    self.performSegue(withIdentifier: "goToCreateProfile", sender: self)
                }
            }
        
        }
    }
    
    func setUserInformation(email: String, name: String, occupation: String, uid: String) {
        
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["email": email, "name": name, "occupation": occupation])
    }
    
    
    
    //MARK:- Log In

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
        print(credential)
        
//        Auth.auth().signIn(with: credential) { (user, error) in
//            if let error = error {
//                return
//            }
//
//            _ = user?.uid
//
//            self.performSegue(withIdentifier: "goToCreateProfile", sender: self)
//
//        }

                Auth.auth().signIn(with: credential) { (user, error) in
                    if error != nil {
                        return
                    }
                    
                    
                    _ = user?.uid
        
                    self.performSegue(withIdentifier: "goToCreateProfile", sender: self)
        
                }
        //
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // Needed for FBSDKLoginDelegate
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
