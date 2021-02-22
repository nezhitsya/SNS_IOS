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
    @IBOutlet weak var activeLoading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userUid = Auth.auth().currentUser?.uid
        self.databaseRef.child("User").child(userUid!).observeSingleEvent(of: .value) { ( snapshot: DataSnapshot) in

            self.userData = snapshot.value as? NSDictionary

            self.databaseRef.child("posts").child(userUid!).observe(.childAdded, with: { (snapshot: DataSnapshot) in

                if snapshot.childrenCount > 0 {
                    self.post.append(snapshot.value as? NSDictionary)
                    self.homeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
                    self.activeLoading.stopAnimating()
                }
            }) {(error) in
                print(error.localizedDescription)
            }
        }

        self.homeTableView.rowHeight = 100
        self.homeTableView.estimatedRowHeight = 140
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeViewTableViewCell", for: indexPath) as! HomeViewTableViewCell

        let posts = post[(self.post.count - 1) - (indexPath.row)]!["text"] as! String

        cell.configure(profilePic: nil, name: self.userData!.value(forKey: "name") as! String, nickname: self.userData!.value(forKey: "nickname") as! String, post: posts)
        
//        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeViewTableViewCell", for: indexPath) as! HomeViewTableViewCell
        
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
