//
//  SessionDetailsViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-09-21.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit
import Firebase

class SessionDetailsViewController: UIViewController {

    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var sessionTitle: UITextView!
    @IBOutlet weak var sessionLocation: UITextView!
    @IBOutlet weak var sessionStartTime: UITextView!
    @IBOutlet weak var sessionEndTime: UITextView!
    @IBOutlet weak var sessionDetails: UITextView!
    @IBOutlet weak var sessionAttendeesCount: UITextView!
    
    var thisSession = Session()
    var thisSessionAttendees = SessionAttendees()
    var attendeesID = [String]()
    var attendeesInfo = [User]()
    var attendeesProfilePicture = [String : UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendeesTableView.delegate = self
        attendeesTableView.dataSource = self

        sessionTitle.text = thisSession.sessionTitle
        sessionLocation.text = thisSession.sessionDescription
        sessionStartTime.text = thisSession.sessionStartTime
        sessionEndTime.text = thisSession.sessionEndTime
        sessionDetails.text = thisSession.sessionDescription
        
        if thisSessionAttendees.attendees.count <= 1 {
            sessionAttendeesCount.text = ("\(String(thisSessionAttendees.attendees.count)) person attending")
        } else {
            sessionAttendeesCount.text = ("\(String(thisSessionAttendees.attendees.count)) people attending")
        }
        
        attendeesID = Array(thisSessionAttendees.attendees.keys)
        
        self.attendeesTableView.register(UINib.init(nibName: "AttendeeCellTableViewCell", bundle: nil), forCellReuseIdentifier: "customAttendeeCell")
        self.attendeesTableView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        getAttendeesData()
        
        configureTableView()
        
    }
    
    // MARK: - Fetch Data
    
    func getAttendeesData() {
        let ref = Database.database().reference()
        
        for attendeeID in attendeesID {
            
            
            Database.database().reference().child("users").child(attendeeID).observeSingleEvent(of: .value, with: {
                (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let thisAttendee = User()
                    
                    thisAttendee.name = dictionary["name"] as? String
                    print(thisAttendee.name)
                    thisAttendee.email = dictionary["email"] as? String
                    thisAttendee.occupation = dictionary["occupation"] as? String
                    thisAttendee.userID = attendeeID
                    thisAttendee.profilePictureURL = dictionary["profilePictureURL"] as? String
                    
                    self.attendeesInfo.append(thisAttendee)
                    
                    if let url = URL(string: thisAttendee.profilePictureURL!) {
                        URLSession.shared.dataTask(with: url) { (data, res, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            let thisAttendeeProfilePicture = UIImage(data: data!)
                            self.attendeesProfilePicture[thisAttendee.userID!] = thisAttendeeProfilePicture!
                            
                            DispatchQueue.main.async {
                                print(self.attendeesProfilePicture.count)
                                self.configureTableView()
                                self.attendeesTableView.reloadData()
                            }
                            
                            }.resume()
                    }
                    
                }
            }, withCancel: nil)
            
            
        }
        
    }
    
    func getAttendeesProfilePictures() {
        
    }
    // MARK: - Navigation


}

extension SessionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attendeesProfilePicture.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customAttendeeCell", for: indexPath) as! AttendeeCellTableViewCell
        
        cell.userName.text = attendeesInfo[indexPath.row].name
        cell.userOccupation.text = attendeesInfo[indexPath.row].occupation
        
        cell.selectionStyle = .none
        
        cell.profileImageView.image = attendeesProfilePicture[attendeesInfo[indexPath.row].userID!]
        cell.profileImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.profileImageView.contentMode = .scaleAspectFit
                
        cell.backgroundColor = UIColor(white: 1, alpha: 0)

        return cell
    }
    
    func configureTableView() {
        attendeesTableView.rowHeight = 75.0
        attendeesTableView.separatorStyle = .none
    }


}
