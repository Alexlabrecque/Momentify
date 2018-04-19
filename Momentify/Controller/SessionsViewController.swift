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
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var notifButton: UIButton!
    
    var ref : DatabaseReference?
    
    var currentSessions = [Session]()
    var currentAttendees = [SessionAttendees]()
    var currentUser = User()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.layer.cornerRadius = 10
        createButton.layer.cornerRadius = 10
        notifButton.layer.cornerRadius = 10
        
        verifyIfUserIsLoggedIn()

        configureTableView()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - Fetch User
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
    
    
    
    // MARK: - Fetch Sessions
    
    func deleteSessions(finished: () -> Void) {
        self.currentSessions.removeAll()
        self.currentAttendees.removeAll()
        
        finished()
    }
    
    func deleteThenFetchSessions() {
        deleteSessions {
            fetchSessions()
        }
        
    }
    
    func fetchSessions() {
        // bug if there is no sessions
        let ref = Database.database().reference()
        
        ref.child("sessions").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {

                var session = Session()
                
                session.sessionID = snapshot.key
                session.sessionDescription = dictionary["sessionDescription"] as? String
                session.sessionEndTime = dictionary["sessionEndTime"] as? String
                session.sessionLocation = dictionary["sessionLocation"] as? String
                session.sessionDate = dictionary["sessionDate"] as? String
                session.sessionStartTime = dictionary["sessionStartTime"] as? String
                session.sessionTitle = dictionary["sessionTitle"] as? String
                
                self.currentSessions.append(session)
                
            }
            
            Database.database().reference(withPath: "sessions").removeAllObservers()
        }
        
        ref.child("attendees").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                
                let sessionAttendes = SessionAttendees()
                
                sessionAttendes.hostID = dictionary["hostID"] as? String
                sessionAttendes.sessionID = snapshot.key
                sessionAttendes.hostName = dictionary["hostName"] as? String
                sessionAttendes.attendees = dictionary["attendees"] as! [String: String]

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

    
    
    // MARK: - Navigation
    
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
 
    // MARK: - Logged In Verification
    
    func verifyIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            
            fetchUser()
            print("user is logged in with email.")
            
        }else if FBSDKAccessToken.current() != nil{

            print("user is logged in with Facebook.")
            
        }else {

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
        cell.selectionStyle = .none
        cell.delegate = self
        
        cell.deleteSessionButton.isHidden = true
        cell.deleteSessionButton.isEnabled = false
        
        if attendee.attendees[self.currentUser.userID!] != nil {
            cell.joinButton.isHidden = true
            cell.joinButton.isUserInteractionEnabled = false
            
            cell.leaveButton.isHidden = false
            cell.leaveButton.isUserInteractionEnabled = true

        } else {
            cell.joinButton.isHidden = false
            cell.joinButton.isUserInteractionEnabled = true
            
            cell.leaveButton.isHidden = true
            cell.leaveButton.isUserInteractionEnabled = false
            
        }
        
        if attendee.hostID == self.currentUser.userID {
            cell.leaveButton.isEnabled = false
            
            cell.deleteSessionButton.isHidden = false
            cell.deleteSessionButton.isEnabled = true
        }
        
        
        
        return cell
    }
    
    
    func configureTableView() {
        sessionTableView.rowHeight = 365.0
    }

    
}

extension SessionsViewController: SessionCellDelegate {
    
    func joinButtonPressed(theseAttendeesJoin: SessionAttendees) {
        
        let thisRef = Database.database().reference()
        thisRef.child("attendees").child(theseAttendeesJoin.sessionID!).child("attendees").child(currentUser.userID!).setValue(currentUser.name)
        
        let alert = UIAlertController(title: "Session joined", message: "Happy FlowWorking Homie! :)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        self.deleteThenFetchSessions()
    }
    
    func leaveButtonPressed(theseAttendeesLeave: SessionAttendees) {
        
        let thisRef = Database.database().reference()
        thisRef.child("attendees").child(theseAttendeesLeave.sessionID!).child("attendees").child(currentUser.userID!).removeValue()
        
        let alert = UIAlertController(title: "Session leaved", message: "You leaved the session :(", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        

        self.deleteThenFetchSessions()
    }
    
    func deleteButtonPressed(thisSession: Session) {
        let thisRef = Database.database().reference()
        thisRef.child("sessions").child(thisSession.sessionID!).removeValue()
        thisRef.child("attendees").child(thisSession.sessionID!).removeValue()
        
        let alert = UIAlertController(title: "Session Deleted", message: "The session was deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
        
        self.deleteThenFetchSessions()
    }
    
}

