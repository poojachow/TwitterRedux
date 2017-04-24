//
//  AccountCell.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/21/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    @IBOutlet weak var accountView: UIView!

    @IBOutlet weak var viewLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    var user: User! {
        didSet {
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenname!)"
            if let profileUrlString = user?.profileurl {
                profileImageView.setImageWith(profileUrlString)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
