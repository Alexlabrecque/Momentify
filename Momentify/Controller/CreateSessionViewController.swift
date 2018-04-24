//
//  CreateSessionViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 18-04-03.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase

class CreateSessionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sessionTitleTextField: UITextField!
    @IBOutlet weak var sessionLocationTextField: UITextField!
    @IBOutlet weak var sessionDescriptionTextField: UITextField!
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    
    @IBOutlet weak var createSessionButton: UIButton!
    
    var sessionDate: String?
    var sessionStartTime: String?
    var sessionEndTime: String?
    var currentUser = User()
    
    
    var ref : DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sessionTitleTextField.delegate = self
        self.sessionLocationTextField.delegate = self
        self.sessionDescriptionTextField.delegate = self
        
        self.initialStartTime()
        self.initialEndTime()
        
        createSessionButton.layer.cornerRadius = 10
        
        verifyIfUserIsLoggedIn()
        
        ref = Database.database().reference()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        verifyIfUserIsLoggedIn()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Add Session
    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
            createSession()
    }
    
    
    func createSession() {
        // Patch for observer. If not present app crashes on SessionViewController when force unwrapping attendees [String : String]
        Database.database().reference(withPath: "attendees").removeAllObservers()
        
        let sessionRef = ref?.child("sessions").childByAutoId()
        let sessionID = sessionRef?.key
       
        ref?.child("sessions").child(sessionID!).child("sessionTitle").setValue(self.sessionTitleTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionLocation").setValue(self.sessionLocationTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionDescription").setValue(self.sessionDescriptionTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionDate").setValue(self.sessionDate)
        ref?.child("sessions").child(sessionID!).child("sessionStartTime").setValue(self.sessionStartTime)
        ref?.child("sessions").child(sessionID!).child("sessionEndTime").setValue(self.sessionEndTime)
        
        ref?.child("attendees").child(sessionID!).child("hostID").setValue(Auth.auth().currentUser?.uid)
        ref?.child("attendees").child(sessionID!).child("hostName").setValue(self.currentUser.name)
        ref?.child("attendees").child(sessionID!).child("sessionID").setValue(sessionID)
        ref?.child("attendees").child(sessionID!).child("attendees").child((Auth.auth().currentUser?.uid)!).setValue(self.currentUser.name)
        
        let alert = UIAlertController(title: "Session created", message: "Happy coworking!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Gracias amigo", style: .default, handler: { action in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)


    }
    
    
    
    //MARK: - TextField Delegate Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Fetch User Data
    
    func verifyIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            
            fetchUser()
            print("user is logged in with email.")
            
        }else if FBSDKAccessToken.current() != nil{
            
            fetchUser()
            print("user is logged in with Facebook.")
            
        }else {
            
            print("user is not logged in.")
            performSegue(withIdentifier: "goToAuth", sender: self)
        }
    }
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                self.currentUser.name = dictionary["name"] as? String
                self.currentUser.email = dictionary["email"] as? String
                self.currentUser.occupation = dictionary["occupation"] as? String
                self.currentUser.userID = uid
            }
        }, withCancel: nil)
    }
    
    
    //MARK: - Date Format
    
    func initialStartTime() {
        self.sessionStartTime = hourToString(date: startTime.date as NSDate)
        self.sessionDate = dateToString(date: startTime.date as NSDate)
    }
    
    func initialEndTime() {
        self.sessionEndTime = hourToString(date: endTime.date as NSDate)
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        self.sessionStartTime = hourToString(date: startTime.date as NSDate)
        self.sessionDate = dateToString(date: startTime.date as NSDate)
    }
    
    @IBAction func endTimeChanged(_ sender: Any) {
        self.sessionEndTime = hourToString(date: endTime.date as NSDate)
    }
    
    func dateToString(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringDate = dateFormatter.string(from: date as Date)

        return stringDate
    }
    
    func hourToString(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let stringDate = dateFormatter.string(from: date as Date)

        return stringDate
    }
    
    
    
}

