//
//  ProfileHeader.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/22/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class ProfileHeader: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    
    var user: User! {
        didSet {
            userNameLabel.text = user.name
            screenNameLabel.text = "@\((user.screenname)!)"
            if let followers = user.followersCount {
                followersLabel.text = String(followers)
            }
            else {
                followersLabel.text = "0"
            }
            if let following = user.following {
                followingLabel.text = String(following)
            }
            else {
                followingLabel.text = "0"
            }
            if let profileUrlString = user.profileurl {
                profileImageView.setImageWith(profileUrlString)
            }
        }
    }
    
    var count: Int! {
        didSet {
            tweetsCountLabel.text = String(count)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
