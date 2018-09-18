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
    
    var delegate: SessionCellDelegate1?
    
    var thisSession = Session()
    var thisSessionsAttendees = SessionAttendees()
    var currentUser = User()
    var month = String()
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        super.awakeFromNib()
        
        joinButton.layer.cornerRadius = joinButton.frame.height/2
        joinButton.layer.borderWidth = 1
        joinButton.layer.borderColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        joinButton.layer.backgroundColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        
        leaveButton.layer.cornerRadius = leaveButton.frame.height/2
        leaveButton.layer.borderWidth = 1
        leaveButton.layer.borderColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        leaveButton.layer.backgroundColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        
        deleteSessionButton.layer.cornerRadius = deleteSessionButton.frame.height/2
        deleteSessionButton.layer.borderWidth = 1
        deleteSessionButton.layer.borderColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        deleteSessionButton.layer.backgroundColor = UIColor(red:1.00, green:0.75, blue:0.41, alpha:1.0).cgColor
        
        lineBackground.layer.cornerRadius = 10
        lineBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        sessionBackground.layer.cornerRadius = 10
        sessionBackground.layer.shadowColor = UIColor.black.cgColor
        sessionBackground.layer.shadowOffset = CGSize(width: -1, height: 1)
        sessionBackground.layer.shadowOpacity = 0.45
        sessionBackground.layer.shadowRadius = 1.75
        //sessionBackground.layer.borderWidth = 1
        //sessionBackground.layer.borderColor = UIColor(red:0.36, green:0.34, blue:0.42, alpha:1.0).cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setSession(session: Session, attendee: SessionAttendees) {
        
        sessionTitle.text = session.sessionTitle
        sessionLocation.text = session.sessionLocation
        sessionStartTime.text = session.sessionStartTime
        sessionEndTime.text = session.sessionEndTime
        
        let thisDate = session.sessionDate
        let month1 = thisDate![thisDate!.index((thisDate!.startIndex), offsetBy: 5)]
        let month2 = thisDate![thisDate!.index((thisDate!.startIndex), offsetBy: 6)]
        let day1 = thisDate![thisDate!.index((thisDate!.startIndex), offsetBy: 8)]
        let day2 = thisDate![thisDate!.index((thisDate!.startIndex), offsetBy: 9)]
        
        if month1 == "0" {
            if month2 == "1" {
                self.month = "Jan"
                
            } else if month2 == "2" {
                self.month = "Feb"
                
            } else if month2 == "3" {
                self.month = "Mar"
                
            } else if month2 == "4" {
                self.month = "Apr"
                
            } else if month2 == "5" {
                self.month = "May"
                
            } else if month2 == "6" {
                self.month = "Jun"
                
            } else if month2 == "7" {
                self.month = "Jul"
                
            } else if month2 == "8" {
                self.month = "Aug"
                
            } else if month2 == "9" {
                self.month = "Sept"
            }
        } else {
            if month2 == "0" {
                self.month = "Oct"
                
            } else if month2 == "1" {
                self.month = "Nov"
                
            } else if month2 == "2" {
                self.month = "Dec"
            }
        }
        sessionDate.text = "\(session.sessionWeekDay!)\n\(day1)\(day2)"
        
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
