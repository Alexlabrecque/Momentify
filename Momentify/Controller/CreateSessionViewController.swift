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
    
    var sessionDate: String?
    var sessionStartTime: String?
    var sessionEndTime: String?
    
    
    var ref : DatabaseReference?
    var userName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sessionTitleTextField.delegate = self
        self.sessionLocationTextField.delegate = self
        self.sessionDescriptionTextField.delegate = self
        
        self.initialDate()
        self.initialStartTime()
        self.initialEndTime()
        
        fetchUser()
        
        ref = Database.database().reference()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Add Session
    
    @IBAction func createSessionButtonPressed(_ sender: Any) {
            createSession()
    }
    
    
    func createSession() {
        
        let sessionRef = ref?.child("sessions").childByAutoId()
        let sessionID = sessionRef?.key
       
        ref?.child("sessions").child(sessionID!).child("sessionTitle").setValue(self.sessionTitleTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionLocation").setValue(self.sessionLocationTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionDescription").setValue(self.sessionDescriptionTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionDate").setValue(self.sessionDate)
        ref?.child("sessions").child(sessionID!).child("sessionStartTime").setValue(self.sessionStartTime)
        ref?.child("sessions").child(sessionID!).child("sessionEndTime").setValue(self.sessionEndTime)
        
        ref?.child("attendees").child(sessionID!).child("hostID").setValue(Auth.auth().currentUser?.uid)
        ref?.child("attendees").child(sessionID!).child("hostName").setValue(userName)
        ref?.child("attendees").child(sessionID!).child("sessionID").setValue(sessionID)
        ref?.child("attendees").child(sessionID!).child("attendees").child((Auth.auth().currentUser?.uid)!).setValue(userName)

        _ = navigationController?.popViewController(animated: true)

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
    
    func fetchUser() {
        
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            print(snapshot)
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                self.userName = dictionary["name"] as? String
            }
        }, withCancel: nil)
    }
    
    //MARK: - Date Format
    
    func initialDate() {
        self.sessionDate = dateToString(date: startTime.date as NSDate)
    }
    
    func initialStartTime() {
        self.sessionStartTime = hourToString(date: startTime.date as NSDate)
    }
    
    func initialEndTime() {
        self.sessionEndTime = hourToString(date: endTime.date as NSDate)
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        self.sessionStartTime = hourToString(date: startTime.date as NSDate)
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

