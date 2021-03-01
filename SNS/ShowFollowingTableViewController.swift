//
//  ShowFollowingTableViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/28.
//

import UIKit
import Firebase

class ShowFollowingTableViewController: UITableViewController {
    
    var listFollowing = [NSDictionary?]()
    var databaseRef = Database.database().reference()
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef.child("following").child(self.user!.uid).queryOrdered(byChild: "nickname").observe(.childAdded, with: { (snapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            
            self.listFollowing.append(snapshot)
            
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listFollowing.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followingUserCell", for: indexPath)

        cell.textLabel?.text = self.listFollowing[indexPath.row]?["nickname"] as? String
        cell.detailTextLabel?.text = self.listFollowing[indexPath.row]?["name"] as? String

        return cell
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
