//
//  AccountViewController.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/21/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var users: [User]!
    var originalLocation: CGPoint!
    var originalTransform: CGAffineTransform!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        users = Array(User._currentUsers.values)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return User._currentUsers.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
            let user = users[indexPath.row]
            cell.user = user
            if originalTransform != nil {
                cell.accountView.transform = originalTransform
            }
            if originalLocation != nil {
                cell.accountView.center = originalLocation
            }
            
            let swipeToDelete = UIPanGestureRecognizer(target: self, action: #selector(deleteAccount(swipe:)))
            swipeToDelete.delegate = self
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(swipeToDelete)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAccount", for: indexPath)
            return cell
        }
    }
    
    func deleteAccount(swipe: UIPanGestureRecognizer) {
        let swipedLocation = swipe.location(in: self.tableView)
        let indexpath = self.tableView.indexPathForRow(at: swipedLocation)
        let cell = self.tableView.cellForRow(at: indexpath!) as! AccountCell

        var translation = swipe.translation(in: view)
        
        
        if swipe.state == .began {
            originalLocation = cell.accountView.center
            originalTransform = cell.accountView.transform
        }
        else if swipe.state == .changed {
            UIView.animate(withDuration: 0.5, animations: {
                cell.accountView.center.x = self.originalLocation.x + translation.x

                cell.accountView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            })
        }
        else if swipe.state == .ended {
            if translation.x > view.frame.width * 2 / 3 {
                
                if User._currentUser != nil {
                    let userToDelete = users[(indexpath?.row)!]
                    print(userToDelete.screenname)
                    if User._currentUser == userToDelete {
                        TwitterClient.sharedInstance?.logout()
                    }
                    else {
                        let noUserLeft = User.delete(user: userToDelete)
                        if noUserLeft == true {
                            TwitterClient.sharedInstance?.logout()
                        }
                        else {
                            users = Array(User._currentUsers.values)
                            tableView.reloadData()
                        }
                    }
                }
            }
            else {
                cell.accountView.center = originalLocation
            //    cell.accountView.transform = originalSize
                cell.accountView.transform = originalTransform
            }
        }
        else {
            cell.accountView.center = originalLocation
        //    cell.accountView.frame = originalSize
            cell.accountView.transform = originalTransform
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print("change account")
            if users[indexPath.row] != nil {
                User.changeUser(user: users[indexPath.row])
                dismiss(animated: true, completion: nil)
            }
        }
        else {
            print("add account \(User._currentUser)")
            TwitterClient.sharedInstance?.login(success: {
                
                self.users = Array(User._currentUsers.values)
                self.tableView.reloadData()
                
                print(User._currentUser)
                for i in User._currentUsers {
                    print(i)
                }
            }, failure: { (error: Error) in
                print("Error: \(error.localizedDescription)")
            })
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
