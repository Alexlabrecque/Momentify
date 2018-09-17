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
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    
    var currentSessions = [Session]()
    var correctedOrderCurrentSessions = [Session]()
    var currentAttendees = [String: SessionAttendees]()
    var currentUser = User()
    var expiredID = [String]()
    
    //TEST
    var sessionsAttending = [String]()
    var sessionsNotAttending = [String]()
    //END OF TEST
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        do {
//            try Auth.auth().signOut()
//
//            if FBSDKAccessToken.current() != nil {
//
//                FBSDKLoginManager().logOut()
//                //logged out of Facebook
//            }
//        } catch {
//            print("Error, there was a problem signing out.")
//        }
        
        chatButton.isHidden = true
        filterButton.title = ""
        filterButton.isEnabled = false
        
        chatButton.layer.cornerRadius = 10
        createButton.layer.cornerRadius = createButton.frame.height/2
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.orange.cgColor
        
        sessionTableView.register(UINib.init(nibName: "SessionCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customSessionCell")
        sessionTableView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:0.0)
        let backgroundImage = UIImage(named: "HomeScreenBackground")
        let imageView = UIImageView(image: backgroundImage)
        sessionTableView.backgroundView = imageView


        verifyIfUserIsLoggedIn()
        
        fetchUser()
        
        configureTableView()

    }

    override func viewDidAppear(_ animated: Bool) {
        verifyIfUserIsLoggedIn()
        
        deleteThenFetchSessions()
        
        // UIBarButton bug
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - Fetch Data
    func fetchUser() {
        
        if let uid = Auth.auth().currentUser?.uid {
          print(uid)
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    
                    self.currentUser.name = dictionary["name"] as? String
                    self.currentUser.email = dictionary["email"] as? String
                    self.currentUser.occupation = dictionary["occupation"] as? String
                    self.currentUser.userID = uid
                }
            }, withCancel: nil)
        } else {
            print("error fetching user")
        }
        
    }
    
    
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

        let ref = Database.database().reference()
        
        ref.child("sessions").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {

                let session = Session()
                
                session.sessionID = snapshot.key
                session.sessionDescription = dictionary["sessionDescription"] as? String
                session.sessionEndTime = dictionary["sessionEndTime"] as? String
                session.sessionLocation = dictionary["sessionLocation"] as? String
                session.sessionDate = dictionary["sessionDate"] as? String
                session.sessionStartTime = dictionary["sessionStartTime"] as? String
                session.sessionTitle = dictionary["sessionTitle"] as? String

                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let stringDate = dateFormatter.string(from: currentDate as Date)

                
                if session.sessionDate != nil {
                    if session.sessionDate! < stringDate {
                        self.moveExpiredSession(session: session)
                        //print("session is expired")
                        self.expiredID.append(session.sessionID!)
                    } else {
                        self.currentSessions.append(session)
                        //print("session still ok")
                    }
                } else {
                    //print("session date = nil, bruh")
                }
                
                self.currentSessions = self.currentSessions.sorted (by:{  $1.sessionDate!.localizedCaseInsensitiveCompare($0.sessionDate!) == ComparisonResult.orderedDescending })
                
                
            }
            Database.database().reference(withPath: "sessions").removeAllObservers()
            
        }
        
        ref.child("attendees").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let sessionAttendes = SessionAttendees()
                
                sessionAttendes.hostID = dictionary["hostID"] as? String
                sessionAttendes.sessionID = snapshot.key
                sessionAttendes.hostName = dictionary["hostName"] as? String
                
                if dictionary["attendees"] != nil {
                    sessionAttendes.attendees = dictionary["attendees"] as! [String: String]
                    
                }
               

                ref.child("users").child(sessionAttendes.hostID!).observeSingleEvent(of: .value, with: { (userSnapshot) in
                    if let userDictionary = userSnapshot.value as? [String: AnyObject] {

                        sessionAttendes.hostName = userDictionary["name"] as? String
                        
                        if self.expiredID.contains(sessionAttendes.sessionID!) == true {
                            self.moveExpiredAttendees(attendees: sessionAttendes)
                        } else {
                            self.currentAttendees[snapshot.key] = sessionAttendes
                        }
                        
                        DispatchQueue.main.async {
                            self.configureTableView()
                            self.sessionTableView.reloadData()
                        }
                    }
                })
                
            }
            Database.database().reference(withPath: "attendees").removeAllObservers()
        }
        self.refreshControl.endRefreshing()
    }
    
    func sortByAttendence() {
        
        correctedOrderCurrentSessions.removeAll()
        sessionsAttending.removeAll()
        sessionsNotAttending.removeAll()

        print("There is \(currentSessions.count) sessions")
        print("There is \(currentAttendees.count) Attendees key")
        
        
        for isAttending in currentAttendees {

            if isAttending.value.attendees[currentUser.userID!] != nil {
                // User is attending
                print("user is attending, put at the top of 1st list")
                self.sessionsAttending.append(isAttending.key)
            } else {
                //User is not attending
                print("user is not attending, put at the bottom of 1st list")
                self.sessionsNotAttending.append(isAttending.key)
            }
        }
        
        
        for thisCurrentSession in currentSessions {
            for thisSession in sessionsAttending {
                if thisCurrentSession.sessionID == thisSession {
                    // User is attending, put session at the top
                    print("user is attending, put \(thisCurrentSession.sessionID!) at the top of final list")
                    correctedOrderCurrentSessions.append(thisCurrentSession)
                }
            }
        }
        print("first for loop done")
        for thisSession in sessionsNotAttending {
            print ("there is a problem here")
            for thisCurrentSession in currentSessions {
                if thisCurrentSession.sessionID == thisSession {
                    // User is not attending, put session at the bottom
                    print("user is not attending, put \(thisCurrentSession.sessionID!) at the bottom of final list")
                    correctedOrderCurrentSessions.append(thisCurrentSession)
                }
            }
        }
        print("original order")
        print(currentSessions)
        print("corrected order")
        print(correctedOrderCurrentSessions)
    }
    
    
    //MARK: - Delete Expired Sessions

    func moveExpiredSession(session: Session) {
        let sessionRef = Database.database().reference().child("sessions")
        let expiredSessionRef = Database.database().reference().child("expiredSessions")
        
        sessionRef.child(session.sessionID!).removeValue()
        
        expiredSessionRef.child(session.sessionID!).child("sessionTitle").setValue(session.sessionTitle)
        expiredSessionRef.child(session.sessionID!).child("sessionLocation").setValue(session.sessionLocation)
        expiredSessionRef.child(session.sessionID!).child("sessionDescription").setValue(session.sessionDescription)
        expiredSessionRef.child(session.sessionID!).child("sessionDate").setValue(session.sessionDate)
        expiredSessionRef.child(session.sessionID!).child("sessionStartTime").setValue(session.sessionStartTime)
        expiredSessionRef.child(session.sessionID!).child("sessionEndTime").setValue(session.sessionEndTime)
    }
    
    func moveExpiredAttendees(attendees: SessionAttendees) {
        let attendeesRef = Database.database().reference().child("attendees")
        let expiredAttendeesRef = Database.database().reference().child("expiredAttendees")
        
        attendeesRef.child(attendees.sessionID!).removeValue()
        
        expiredAttendeesRef.child(attendees.sessionID!).child("hostID").setValue(attendees.hostID)
        expiredAttendeesRef.child(attendees.sessionID!).child("hostName").setValue(attendees.hostName)
        expiredAttendeesRef.child(attendees.sessionID!).child("sessionID").setValue(attendees.sessionID)
        expiredAttendeesRef.child(attendees.sessionID!).child("attendees").setValue(attendees.attendees)
        
    }

    
    
    // MARK: - Navigation
    
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
    
 
    
    // MARK: - Logged In Verification
    
    func verifyIfUserIsLoggedIn() {
        
        if FBSDKAccessToken.current() != nil{
            
            print("user is logged in with Facebook.")
            
        }else if Auth.auth().currentUser?.uid != nil {
            
            fetchUser()
            print("user is logged in with email.")
            
        }else {

            print("user is not logged in.")
            performSegue(withIdentifier: "goToSignUpOrLogIn", sender: self)
        }
    }
    
}

extension SessionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.sortByAttendence()
        return self.correctedOrderCurrentSessions.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customSessionCell", for: indexPath) as! SessionCellTableViewCell
        
        Database.database().reference(withPath: "sessions").removeAllObservers()
        Database.database().reference(withPath: "attendees").removeAllObservers()
        
        self.sortByAttendence()
        let session = correctedOrderCurrentSessions[indexPath.row]
        let attendee = currentAttendees[session.sessionID!]

        
        if attendee != nil {
            cell.setSession(session: session, attendee: attendee!)
        }
        
        cell.selectionStyle = .none
        cell.delegate = self
            
        cell.deleteSessionButton.isHidden = true
        cell.deleteSessionButton.isEnabled = false
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0)
            
        if attendee?.hostID == self.currentUser.userID {
            print("user is the host")
                
            cell.deleteSessionButton.isHidden = false
            cell.deleteSessionButton.isEnabled = true
            
            cell.joinButton.isHidden = true
            cell.joinButton.isUserInteractionEnabled = false
            
            cell.leaveButton.isHidden = true
            cell.leaveButton.isUserInteractionEnabled = false
            
            cell.checkmarkImage.isHidden = true
            cell.lineBackground.layer.backgroundColor = UIColor(red:0.40, green:0.80, blue:0.38, alpha:1.0).cgColor
                
        } else if attendee?.attendees[self.currentUser.userID!] != nil {
            print("user is attending")
            cell.joinButton.isHidden = true
            cell.joinButton.isUserInteractionEnabled = false
            
            cell.leaveButton.isHidden = false
            cell.leaveButton.isUserInteractionEnabled = true
            
            cell.checkmarkImage.isHidden = true
            cell.lineBackground.layer.backgroundColor = UIColor(red:0.40, green:0.80, blue:0.38, alpha:1.00).cgColor

        } else {
            print("user is not attending")
            cell.joinButton.isHidden = false
            cell.joinButton.isUserInteractionEnabled = true
            
            cell.leaveButton.isHidden = true
            cell.leaveButton.isUserInteractionEnabled = false
            
            cell.checkmarkImage.isHidden = true
            cell.lineBackground.layer.backgroundColor = UIColor.orange.cgColor

        }
    
    return cell

    }
    
    
    func configureTableView() {
        sessionTableView.rowHeight = 275.0
        sessionTableView.separatorStyle = .none
    
        if #available(iOS 10.0, *) {
            sessionTableView.refreshControl = refreshControl
        } else {
            sessionTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshSessions(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.orange
        refreshControl.attributedTitle = NSAttributedString(string: "Looking for Coworking Sessions ...")
    }
    
    @objc private func refreshSessions(_ sender: Any) {
        self.deleteThenFetchSessions()

    }

    
}

extension SessionsViewController: SessionCellDelegate1 {
    
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
        alert.addAction(UIAlertAction(title: "Gracias amigo", style: .default, handler: { action in
            self.deleteThenFetchSessions()
        }))
        self.present(alert, animated: true)
        
    }
    
}
