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
        logInButton.layer.borderColor = UIColor.gray.cgColor
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
        emailTextField.addTarget(self, action: #selector(LogInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LogInViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty
            else {

                logInButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
                logInButton.layer.borderColor = UIColor.gray.cgColor
                

                logInButton.isEnabled = false
                
                return
        }

        logInButton.setTitleColor(UIColor.orange, for: UIControlState.normal)
        logInButton.layer.borderColor = UIColor.orange.cgColor
        

        logInButton.isEnabled = true
    }
    
    //Mark: - Log in
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        if emailTextField.text?.isEmpty == true || emailTextField.text?.contains("@") == false {
            
            let alert = UIAlertController(title: "Unvalid Email Adress", message: "Please enter a valid one", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else if passwordTextField.text?.isEmpty == true || (passwordTextField.text?.count)! < 6 {
            
            let alert = UIAlertController(title: "Unvalid Password", message: "Password must include at least 6 chararcters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        } else {
            SVProgressHUD.show()
        
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
                if error != nil{
                    print(error!)

                    SVProgressHUD.dismiss()
                        
                    let alert = UIAlertController(title: "Unvalid Email Adress", message: "Please enter a valid one", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                        
                    return
                } else {
                    print("Log In Successfull")
                    SVProgressHUD.dismiss()
                
                    self.performSegue(withIdentifier: "goToNavigationController", sender: self)
                }
                
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
