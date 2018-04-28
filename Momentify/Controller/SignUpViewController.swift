//
//  SignUpViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-28.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.borderColor = UIColor.orange.cgColor
        signUpButton.layer.borderWidth = 1
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)
        
        signUpButton.isEnabled = false
        
        handleTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - Navigation

    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "signUpToSignUpOrLogIn", sender: self)
    }
    
    //MARK:- Allow buttons to be pressed
    
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(AuthenticationViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(AuthenticationViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty
            else {
                signUpButton.setTitleColor(UIColor.lightText, for: UIControlState.normal)

                signUpButton.isEnabled = false
                
                return
        }
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)

        
        signUpButton.isEnabled = true
    }
    
    //MARK:- Create User
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
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
        newUserReference.setValue(["email": email, "name": name, "occupation": occupation, "userID": uid])
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
