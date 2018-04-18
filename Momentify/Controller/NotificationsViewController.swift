//
//  NotificationsViewController.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 18-04-03.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

protocol mySessionsDelegate {
    func fetchMySessions(mySessions: SessionAttendees)

}

class NotificationsViewController: UIViewController {
    
    var delegate : mySessionsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getUserAndSession() {
        //delegate?.fetchMySessions(mySessions: <#T##SessionAttendees#>)
    }

}
