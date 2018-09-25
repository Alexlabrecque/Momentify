//
//  AttendeeCellTableViewCell.swift
//  Momentify
//
//  Created by Alexandre Labrecque on 2018-09-24.
//  Copyright © 2018 Alexandre Labrecque. All rights reserved.
//

import UIKit

class AttendeeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userOccupation: UILabel!
    @IBOutlet weak var attendeeBackground: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
        attendeeBackground.layer.masksToBounds = false
        attendeeBackground.layer.cornerRadius = 10
        
        
        attendeeBackground.layer.shadowColor = UIColor.black.cgColor
        attendeeBackground.layer.shadowOffset = CGSize(width: -1, height: 1)
        attendeeBackground.layer.shadowOpacity = 0.45
        attendeeBackground.layer.shadowRadius = 1.75
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
