//
//  FollowUsersTableViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/26.
//

import UIKit
import Firebase

class FollowUsersTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var followUsersTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var user: User?
    var usersArray = [NSDictionary?]()
    var otherUser: AnyObject? = .none
    var loginUser: AnyObject? = .none
    var filteredUsers = [NSDictionary?]()
    var testArray = [NSDictionary?]()
    var databaseRef = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        databaseRef.child("User").queryOrdered(byChild: "nickname").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            
            self.loginUser = snapshot
            self.loginUser?.setValue(self.user?.uid, forKey: "uid")
            
            if(key != self.user?.uid) {
                self.usersArray.append(snapshot)
                self.followUsersTableView.insertRows(at: [IndexPath(row: self.usersArray.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
            }
        })
        
        databaseRef.child("User").child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            
            let uid = self.otherUser!["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            self.otherUser?.setValue(uid, forKey: "uid")
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return self.usersArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user: NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = self.usersArray[indexPath.row]
        }
        
        cell.textLabel?.text = user?["nickname"] as? String
        cell.detailTextLabel?.text = user?["name"] as? String

        return cell
    }
    
    public override func tableView(_ tableVew: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let follow = UITableViewRowAction(style: .default, title: "Follow") { (action, indexPath) in
            self.Follow()
        }
        follow.backgroundColor = UIColor.systemGray
        return [follow]
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//        }
//    }
    
    func Follow() {
        let followersRef = "followers/\(self.otherUser?["uid"] as! String)/\(self.loginUser!["uid"] as! String)"
        let followingRef = "following/" + (self.loginUser!["uid"] as! String) + "/" + (self.otherUser?["uid"] as! String)
        
        let followersData = ["nickname": self.loginUser!["nickname"] as! String, "name": self.loginUser!["name"] as! String]
        let followingData = ["nickname": self.loginUser!["nickname"] as! String, "name": self.loginUser!["name"] as! String]
        
        let childUpdates = [followersRef: followersData, followingRef: followingData]
        databaseRef.updateChildValues(childUpdates)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    
    func filterContent(searchText: String) {
        self.filteredUsers = self.usersArray.filter{ user in
            
            let username = user!["nickname"] as? String
            
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
    }
    
    @IBAction func didTapDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
