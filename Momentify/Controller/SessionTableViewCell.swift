//
//  SessionTableViewCell.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-09.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

protocol SessionCellDelegate {
    func joinButtonPressed(theseAttendeesJoin: SessionAttendees)
    func leaveButtonPressed(theseAttendeesLeave: SessionAttendees)
    func deleteButtonPressed(thisSession: Session)
}

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var sessionLocation: UILabel!
    @IBOutlet weak var sessionStartTime: UILabel!
    @IBOutlet weak var sessionEndTime: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var numberOfCoworkers: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var deleteSessionButton: UIButton!
    
    
    var delegate: SessionCellDelegate?
    
    var thisSession = Session()
    var thisSessionsAttendees = SessionAttendees()
    var currentUser = User()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinButton.layer.cornerRadius = 10
        leaveButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setSession(session: Session, attendee: SessionAttendees) {
        
        sessionTitle.text = session.sessionTitle
        sessionLocation.text = session.sessionLocation
        sessionStartTime.text = session.sessionStartTime
        sessionEndTime.text = session.sessionEndTime
        sessionDescription.text = session.sessionDescription
        numberOfCoworkers.text = ("\(String(attendee.attendees.count)) attendees")
        
        hostName.text = attendee.hostName
        
        self.thisSession = session
        self.thisSessionsAttendees = attendee
        
    }
 
    
    @IBAction func didPressJoinButton(_ sender: Any) {
        delegate?.joinButtonPressed(theseAttendeesJoin: self.thisSessionsAttendees)
    }
    
    @IBAction func didPressedLeaveButton(_ sender: Any) {
        delegate?.leaveButtonPressed(theseAttendeesLeave: self.thisSessionsAttendees)
    }
    
    
    @IBAction func didPressedDeleteSession(_ sender: Any) {
        delegate?.deleteButtonPressed(thisSession: self.thisSession)
    }
}


