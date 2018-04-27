//
//  SessionCellTableViewCell.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-26.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

protocol SessionCellDelegate1 {
    func joinButtonPressed(theseAttendeesJoin: SessionAttendees)
    func leaveButtonPressed(theseAttendeesLeave: SessionAttendees)
    func deleteButtonPressed(thisSession: Session)
}

class SessionCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var sessionLocation: UILabel!
    @IBOutlet weak var sessionStartTime: UILabel!
    @IBOutlet weak var sessionEndTime: UILabel!
    @IBOutlet weak var sessionDate: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var numberOfCoworkers: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var deleteSessionButton: UIButton!
    @IBOutlet weak var sessionBackground: UIView!
    @IBOutlet weak var lineBackground: UIView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    var delegate: SessionCellDelegate1?
    
    var thisSession = Session()
    var thisSessionsAttendees = SessionAttendees()
    var currentUser = User()
    
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        super.awakeFromNib()
        
        joinButton.layer.cornerRadius = 10
        joinButton.layer.borderWidth = 1
        joinButton.layer.borderColor = UIColor.orange.cgColor
        
        leaveButton.layer.cornerRadius = 10
        leaveButton.layer.borderWidth = 1
        leaveButton.layer.borderColor = UIColor.darkGray.cgColor
        
        deleteSessionButton.layer.cornerRadius = 10
        deleteSessionButton.layer.borderWidth = 1
        deleteSessionButton.layer.borderColor = UIColor.red.cgColor
        
        lineBackground.layer.cornerRadius = 10
        lineBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        sessionBackground.layer.cornerRadius = 10
        
        checkmarkImage.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSession(session: Session, attendee: SessionAttendees) {
        
        sessionTitle.text = session.sessionTitle
        sessionLocation.text = session.sessionLocation
        sessionStartTime.text = session.sessionStartTime
        sessionEndTime.text = session.sessionEndTime
        sessionDate.text = session.sessionDate
        
        sessionDescription.text = session.sessionDescription
        if attendee.attendees.count <= 1 {
            numberOfCoworkers.text = ("\(String(attendee.attendees.count)) person attending")
        } else {
            numberOfCoworkers.text = ("\(String(attendee.attendees.count)) people attending")
        }
        
        
        hostName.text = attendee.hostName
        
        self.thisSession = session
        self.thisSessionsAttendees = attendee
    }
    
    @IBAction func didPressJoinButton(_ sender: Any) {
        delegate?.joinButtonPressed(theseAttendeesJoin: self.thisSessionsAttendees)
    }
    
    @IBAction func didPressLeaveButton(_ sender: Any) {
        delegate?.leaveButtonPressed(theseAttendeesLeave: self.thisSessionsAttendees)
    }
    
    
    @IBAction func didPressDeleteSession(_ sender: Any) {
        delegate?.deleteButtonPressed(thisSession: self.thisSession)
    }
    
}
