//
//  User.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/21/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class User: NSObject {
    
    static let usedDidLogoutNotification = NSNotification.Name(rawValue: "UserDidLogout")
    
    var name: String?
    var screenname: String?
    var profileurl: URL?
    var tagline: String?
    var dictionary: NSDictionary?
    var following: Int?
    var followersCount: Int?
    var backgroundurl: URL?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileurl = URL(string: profileUrlString)
        }
        tagline = dictionary["description"] as? String
        following = dictionary["friends_count"] as? Int
        followersCount = dictionary["followers_count"] as? Int
        
        let background = dictionary["profile_banner_url"] as? String
        if let background = background {
            backgroundurl = URL(string: background)
        }
   //     print(dictionary)
    }
    
    static var _currentUsers = [String: User]()
    static var _currentUser: User?
    
    class var currentUser: User?{
        get {
            if _currentUser == nil {
                if _currentUsers.isEmpty == true {
                    print("no users")
                }
                let defaults = UserDefaults.standard
                
                let usersData = defaults.object(forKey: "currentUserData") as? [String: Data]
                if let usersData = usersData {
                    for (userkey, uservalue) in usersData {
                        let dictionary = try! JSONSerialization.jsonObject(with: uservalue, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                        if _currentUsers[(_currentUser?.screenname)!] == nil {
                            _currentUsers[(_currentUser?.screenname)!] = _currentUser
                        }
                    }

                }
            }
            return _currentUser
        }
        set(user) {
            if user == nil {
                _currentUsers.removeValue(forKey: (_currentUser?.screenname)!)
                _currentUser = user
                
            }
            else {
                _currentUser = user
                _currentUsers[(_currentUser?.screenname)!] = _currentUser
            }
            
            let defaults = UserDefaults.standard
            
            if _currentUsers.isEmpty {
                defaults.removeObject(forKey: "currentUserData")
            }
            else {
                var userData = [String: Data]()
                for (userkey, uservalue) in _currentUsers {
                    let data = try! JSONSerialization.data(withJSONObject: uservalue.dictionary!, options: [])
                    userData[userkey] = data
                }
                defaults.set(userData, forKey: "currentUserData")
            }
            
            defaults.synchronize()
            
        }
    }
    
    class func changeUser(user: User) {
        if _currentUsers[user.screenname!] != nil {
            _currentUser = user
        }
    }
    
    class func delete(user: User) -> Bool {
        if _currentUser?.screenname == user.screenname {
            for (key, value) in _currentUsers {
                if value.screenname != _currentUser?.screenname {
                    _currentUser = value
                    break
                }
            }
        }
        if _currentUsers[user.screenname!] != nil {
            _currentUsers.removeValue(forKey: user.screenname!)
        }
        return _currentUsers.isEmpty
    }
}
