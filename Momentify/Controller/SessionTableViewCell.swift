//
//  SessionTableViewCell.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-09.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

protocol SessionCellDelegate {
    func joinButtonPressed(title: String)
}

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var sessionLocation: UILabel!
    @IBOutlet weak var sessionStartTime: UILabel!
    @IBOutlet weak var sessionEndTime: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var numberOfCoworkers: UILabel!
    @IBOutlet weak var hostName: UILabel!
    
    var delegate: SessionCellDelegate?
    
    var thisSession = Session()
    var thisSessionsAttendees = SessionAttendees()
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        numberOfCoworkers.text = session.numberOfCoworkers
        hostName.text = attendee.hostName
        
        self.thisSession = session
        self.thisSessionsAttendees = attendee
        
    }
 
    
    @IBAction func didPressJoinButton(_ sender: Any) {
        delegate?.joinButtonPressed(title: thisSession.sessionTitle!)
    }
    
}


