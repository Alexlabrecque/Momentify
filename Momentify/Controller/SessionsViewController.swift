//
//  SessionsViewController.swift
//
//
//  Created by Alexandre Labrecque on 18-04-03.
//

import UIKit
import FacebookLogin
import Firebase
import SVProgressHUD
import FBSDKLoginKit

class SessionsViewController: UIViewController {
    
    @IBOutlet weak var sessionTableView: UITableView!
    
    var ref : DatabaseReference?
    
    var currentSessions = [Session]()
    var currentAttendees = [SessionAttendees]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyIfUserIsLoggedIn()

        configureTableView()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK :- Fetch Sessions
    
    func deleteThenFetchSessions() {
        self.currentSessions.removeAll()
        self.currentAttendees.removeAll()
        
        fetchSessions()
    }
    
    func fetchSessions() {
        // bug if there is no sessions
        let ref = Database.database().reference()
        
        ref.child("sessions").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {

                var session = Session()
                
                session.sessionID = snapshot.key
                session.numberOfCoworkers = dictionary["numberOfCoworkers"] as? String
                session.sessionDescription = dictionary["sessionDescription"] as? String
                session.sessionEndTime = dictionary["sessionEndTime"] as? String
                session.sessionLocation = dictionary["sessionLocation"] as? String
                session.sessionStartTime = dictionary["sessionStartTime"] as? String
                session.sessionTitle = dictionary["sessionTitle"] as? String
                
                self.currentSessions.append(session)
                print("There is \(self.currentSessions.count) object inside of current sessions")
                
            }
            
            Database.database().reference(withPath: "sessions").removeAllObservers()
        }
        
        ref.child("attendees").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let sessionAttendes = SessionAttendees()
                
                sessionAttendes.hostID = dictionary["hostID"] as? String

                ref.child("users").child(sessionAttendes.hostID!).observeSingleEvent(of: .value, with: { (userSnapshot) in
                    if let userDictionary = userSnapshot.value as? [String: AnyObject] {

                        sessionAttendes.hostName = userDictionary["name"] as? String
                        
                        DispatchQueue.main.async {
                            self.configureTableView()
                            self.sessionTableView.reloadData()
                        }
                    }
                })
                self.currentAttendees.append(sessionAttendes)
            }
            Database.database().reference(withPath: "attendees").removeAllObservers()
        }
    }

    
    
    // Mark : - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        verifyIfUserIsLoggedIn()
        
        deleteThenFetchSessions()
        
        // UIBarButton bug
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToFilter", sender: self)
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToCreate", sender: self)
    }
    
    @IBAction func notificationsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToNotifications", sender: self)
    }
 
    // MARK :- Logged In Verification
    
    func verifyIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            // User logged in via email
            print("user is logged in with email.")
            print(Auth.auth().currentUser?.uid as Any)
        }else if FBSDKAccessToken.current() != nil{
            // User logged in via Facebook
            print("user is logged in with Facebook.")
        }else {
            // User not logged in
            print("user is not logged in.")
            performSegue(withIdentifier: "goToAuth", sender: self)
        }
    }
    
}

extension SessionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let session = currentSessions[indexPath.row]
        let attendee = currentAttendees[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath) as! SessionTableViewCell
        
        cell.setSession(session: session, attendee: attendee)
        
        return cell
    }
    
    
    func configureTableView() {
        sessionTableView.rowHeight = 350.0
    }
    
}



