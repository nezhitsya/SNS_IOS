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
            
            if(key != self.user?.uid) {
                self.usersArray.append(snapshot)
                self.followUsersTableView.insertRows(at: [IndexPath(row: self.usersArray.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
            }
        })

        // self.clearsSelectionOnViewWillAppear = false

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        cell.detailTextLabel?.text = user?["nickname"] as? String

        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowUser" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let user = usersArray[indexPath.row]
//                let controller = segue.destination as? UserProfileViewController
//                controller?.otherUser = user
//            }
//        }
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
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
