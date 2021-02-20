//
//  HomeViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var databaseRef = Database.database().reference()
    var post: [NSDictionary?] = []
    var userData: AnyObject? = .none
    
    @IBOutlet weak var homeTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth().currentUser
        self.databaseRef.child("User").child(user!.uid).observeSingleEvent(of: DataEventType.value) { ( snapshot: DataSnapshot) in
            
            self.userData = snapshot
            
            self.databaseRef.child("posts/\(user!.uid)").observeSingleEvent(of: .childAdded, with: { (snapshot: DataSnapshot) in
                
                self.post.append(snapshot.value as! NSDictionary)
                self.homeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
            })
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeViewTableViewCell", for: indexPath as IndexPath) as! HomeViewTableViewCell
        
        let posts = post[(self.post.count - 1) - indexPath.row]!["text"] as! String
    
        cell.configure(profilePic: nil, name: self.userData!.value(forKey: "name") as! String, nickname: self.userData!.value(forKey: "nickname") as! String, post: posts)
        
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
