//
//  SessionTableViewCell.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-04-09.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

class SessionTableViewCell: UITableViewCell {

    @IBOutlet weak var sessionTitle: UILabel!
    @IBOutlet weak var sessionLocation: UILabel!
    @IBOutlet weak var sessionStartTime: UILabel!
    @IBOutlet weak var sessionEndTime: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    @IBOutlet weak var numberOfCoworkers: UILabel!
    @IBOutlet weak var hostName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        
    }
    


}
