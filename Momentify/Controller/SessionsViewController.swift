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

class SessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var sessionTableView: UITableView!
    
    var ref : DatabaseReference?
    
    var currentSessions = [Session]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK :- Fetch Sessions
    
    func fetchSessions() {
        // Triggers too quickly. When creating a session, Database don't have the time to enter all the properties before this methods gets called and crashes the app
        self.currentSessions.removeAll()
        Database.database().reference().child("sessions").observe(.childAdded) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(snapshot)
                
                var session = Session()
                
                session.numberOfCoworkers = dictionary["numberOfCoworkers"] as? String
                session.sessionDescription = dictionary["sessionDescription"] as? String
                session.sessionEndTime = dictionary["sessionEndTime"] as? String
                session.sessionLocation = dictionary["sessionLocation"] as? String
                session.sessionStartTime = dictionary["sessionStartTime"] as? String
                session.sessionTitle = dictionary["sessionTitle"] as? String
                
                
                
                self.currentSessions.append(session)
                
                DispatchQueue.main.async {
                    self.configureTableView()
                    self.sessionTableView.reloadData()
                }
            }
            Database.database().reference(withPath: "sessions").removeAllObservers()

        }
        
        

    }
    
    // Mark :- TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentSessions.count
        //return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath) as! SessionTableViewCell
        
//        cell.sessionTitle.text = "Coders with Coffee"
//        cell.sessionLocation.text = "23 Dundas Street"
//        cell.sessionStartTime.text = "1:00 pm"
//        cell.sessionEndTime.text = "3:00 pm"
//        cell.sessionDescription.text = "lets work"
//        cell.numberOfCoworkers.text = "4 people attending"
        
        cell.sessionTitle.text = self.currentSessions[indexPath.row].sessionTitle
        cell.sessionLocation.text = self.currentSessions[indexPath.row].sessionLocation
        cell.sessionStartTime.text = self.currentSessions[indexPath.row].sessionStartTime
        cell.sessionEndTime.text = self.currentSessions[indexPath.row].sessionEndTime
        cell.sessionDescription.text = self.currentSessions[indexPath.row].sessionDescription
        cell.numberOfCoworkers.text = self.currentSessions[indexPath.row].numberOfCoworkers
        
//        cell.numberOfCoworkers.text = self.currentSessions[indexPath.row].numberOfCoworkers
//        cell.sessionDescription.text = self.currentSessions[indexPath.row].sessionDescription
//        cell.sessionEndTime.text = self.currentSessions[indexPath.row].sessionEndTime
//        cell.sessionLocation.text = self.currentSessions[indexPath.row].sessionLocation
//        cell.sessionStartTime.text = self.currentSessions[indexPath.row].sessionStartTime
//        cell.sessionTitle.text = self.currentSessions[indexPath.row].sessionTitle
        
        return cell
    }
    
    
    func configureTableView() {
        sessionTableView.rowHeight = 230.0
    }
    
    
    // Mark : - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
        verifyIfUserIsLoggedIn()
        
        fetchSessions()
        
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
        if Auth.auth().currentUser != nil {
            // User logged in via email
        }else if FBSDKAccessToken.current() != nil{
            // User logged in via Facebook
        }else {
            // User not logged in
            performSegue(withIdentifier: "goToAuth", sender: self)
        }
    }
    
    
}


