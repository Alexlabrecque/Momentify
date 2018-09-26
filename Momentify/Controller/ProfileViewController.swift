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
    @IBOutlet weak var hoursCoworkedLabel: UILabel!
    @IBOutlet weak var sessionsJoinedLabel: UILabel!
    
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        
        editButton.layer.cornerRadius = editButton.frame.height/2
        editButton.layer.backgroundColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
        
        fetchUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK :- Presenting User's Information
    
    func fetchUser() {

        let uid = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference(forURL: "gs://momentify-83187.appspot.com/")
        
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? NSDictionary {
                print(snapshot)
                let value = snapshot.value as? NSDictionary
                
                if self.userName.text.isEmpty {
                    self.userName.text = "Name"
                } else {
                    self.userName.text = value?["name"] as? String
                }
                
                if self.userOccupation.text.isEmpty {
                    self.userOccupation.text = "Occupation"
                } else {
                    self.userOccupation.text = value?["occupation"] as? String
                }
                
                self.user.hoursCoworked = value?["hoursCoworked"] as? Int
                self.user.sessionsJoined = value?["sessionsJoined"] as? Int
                
                self.user.profilePictureURL = value?["profilePictureURL"] as? String
                
                if let url = URL(string: self.user.profilePictureURL!) {
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
                    self.hoursCoworkedLabel.text = "\(self.user.hoursCoworked!)"
                    self.sessionsJoinedLabel.text = "\(self.user.sessionsJoined!)"
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
