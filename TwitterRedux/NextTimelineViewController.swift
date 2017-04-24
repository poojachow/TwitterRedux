//
//  NextTimelineViewController.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/22/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class NextTimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var user: User!
    var tweets: [Tweet]!
    var headerView: ProfileHeader!
    let overlay = UIVisualEffectView()
    let defaultOffset = UIEdgeInsetsMake(55, 0, 0, 0)
    var originalOverlayEffect: UIVisualEffect!
    var originalTransform: CGAffineTransform!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        updateTimeline()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        headerView = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)?[0] as! ProfileHeader
        headerView.user = user
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        if let background = user.backgroundurl {
            let image = UIImageView()
            image.setImageWith(background)
            tableView.backgroundView = image
            tableView.backgroundView?.contentMode = .scaleAspectFill
            tableView.backgroundView?.clipsToBounds = true
            overlay.frame = tableView.frame
        }
        self.tableView.contentInset = defaultOffset
        originalTransform = self.tableView.backgroundView?.transform
        originalOverlayEffect = self.overlay.effect
        tableView.reloadData()
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        updateTimeline()
        self.tableView.backgroundView?.transform = CGAffineTransform(scaleX: 2, y: 2)
        UIView.animate(withDuration: 1) {
            self.overlay.effect = UIBlurEffect(style: .extraLight)
            self.tableView.backgroundView?.transform = self.originalTransform
        }
        self.overlay.effect = originalOverlayEffect
        refreshControl.endRefreshing()
    }
    
    
    func updateTimeline() {
        if user == nil {
            
            user = User.currentUser
            TwitterClient.sharedInstance?.userTimeline(screenname: nil, success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.headerView.count = tweets.count
                self.tableView.reloadData()
            })
        }
        else {
            
            TwitterClient.sharedInstance?.userTimeline(screenname: user.screenname!, success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.headerView.count = tweets.count
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweetsCount = tweets?.count {
            return tweetsCount
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherProfileCell", for: indexPath) as! ProfileCell
        cell.tweet = tweets[indexPath.row]
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("i m here")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Dynamic sizing header
        if let header = tableView.tableHeaderView {
            let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = header.frame
            
            // If we don't have this check, viewDidLayoutSubviews() will get
            // repeatedly, causing the app to hang.
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                header.frame = headerFrame
                tableView.tableHeaderView = header
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
