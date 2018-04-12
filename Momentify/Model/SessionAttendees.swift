//
//  SessionAttendees.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-11.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

class SessionAttendees: NSObject {
    
    var sessionID: String?
    var attendees = [String : AnyObject]()
    var hostID: String?
    var hostName: String?

}
