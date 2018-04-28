//
//  LogInViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-28.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.layer.cornerRadius = 10
        logInButton.layer.borderColor = UIColor.orange.cgColor
        logInButton.layer.borderWidth = 1
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        logInButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
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

                logInButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
                

                logInButton.isEnabled = false
                
                return
        }

        logInButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        

        logInButton.isEnabled = true
    }
    
    //Mark: - Log in
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
    // MARK: - Navigation

    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "logInToSignUpOrLogIn", sender: self)
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
