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
    @IBOutlet weak var sessionStartTimeTextField: UITextField!
    @IBOutlet weak var sessionEndTimeTextField: UITextField!
    @IBOutlet weak var sessionDescriptionTextField: UITextField!
    @IBOutlet weak var numberOfCoworkersTextField: UITextField!
    
    var ref : DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sessionTitleTextField.delegate = self
        self.sessionLocationTextField.delegate = self
        self.sessionStartTimeTextField.delegate = self
        self.sessionEndTimeTextField.delegate = self
        self.sessionDescriptionTextField.delegate = self
        self.numberOfCoworkersTextField.delegate = self
        
        ref = Database.database().reference()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK :- Add Session
    
    @IBAction func createSessionButtonPressed(_ sender: Any) {

            createSession()
        
    }
    
    func createSession() {
        
        let sessionRef = ref?.child("sessions").childByAutoId()
        let sessionID = sessionRef?.key
       
        ref?.child("sessions").child(sessionID!).child("sessionTitle").setValue(self.sessionTitleTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionLocation").setValue(self.sessionLocationTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionStartTime").setValue(self.sessionStartTimeTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionEndTime").setValue(self.sessionEndTimeTextField.text)
        ref?.child("sessions").child(sessionID!).child("sessionDescription").setValue(self.sessionDescriptionTextField.text)
        ref?.child("sessions").child(sessionID!).child("numberOfCoworkers").setValue(self.numberOfCoworkersTextField.text)
        
        ref?.child("attendees").child(sessionID!).child("hostID").setValue(Auth.auth().currentUser?.uid)

        _ = navigationController?.popViewController(animated: true)

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
