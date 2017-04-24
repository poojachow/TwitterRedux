//
//  TimelineViewController.swift
//  TwitterRedux
//
//  Created by Pooja Chowdhary on 4/21/17.
//  Copyright © 2017 Pooja Chowdhary. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBAction func onSignOutBarButton(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance?.logout()
    }
    
    @IBOutlet weak var tableView: UITableView!

    var isMoreDataLoading = false
    var tweets: [Tweet]!
    var tappedcell: TimelineCell!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        updateTimeline()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    func  onTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedLocation = tapGestureRecognizer.location(in: self.tableView)
        let indexpath = self.tableView.indexPathForRow(at: tappedLocation)
        let cell = self.tableView.cellForRow(at: indexpath!) as! TimelineCell

        tappedcell = cell
        performSegue(withIdentifier: "ShowProfile", sender: self)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        updateTimeline()
        refreshControl.endRefreshing()
    }
    
    func updateTimeline() {
        
        TwitterClient.sharedInstance?.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }, failure: { (error: NSError) in
            print("Error: \(error)")
        })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        cell.tweet = tweets[indexPath.row]
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapped(tapGestureRecognizer:)))
        cell.profileImageView.addGestureRecognizer(tap)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProfile" {
            
            let indexPath = tableView.indexPath(for: tappedcell)
            let destination = segue.destination as! NextTimelineViewController
            let tweet = tweets[(indexPath?.row)!]
            destination.user = tweet.user
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Code to load more results
                updateTimeline()
                tableView.reloadData()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateTimeline()
        tableView.reloadData()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
