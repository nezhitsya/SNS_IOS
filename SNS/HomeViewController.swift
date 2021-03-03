//
//  HomeViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var databaseRef = Database.database().reference()
    var post: [NSDictionary?] = []
    var userData: AnyObject? = .none
    var defaultImgaeViewHeightConstraint: CGFloat = 70.0
    var listFollowers = [NSDictionary?]()
    var listFollowing = [NSDictionary?]()
    
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var activeLoading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self

        let userUid = Auth.auth().currentUser?.uid

        self.databaseRef.child("User").child(userUid!).observeSingleEvent(of: .value) { ( snapshot: DataSnapshot) in

            self.userData = snapshot.value as? NSDictionary

            self.databaseRef.child("posts").child(userUid!).observe(.childAdded, with: { (snapshot: DataSnapshot) in

//                if snapshot.childrenCount > 0 {
//                    self.post.append(snapshot.value as? NSDictionary)
//                    self.homeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
//                    self.activeLoading.stopAnimating()
//                }
                let key = snapshot.key
                let snapshot = snapshot.value as? NSDictionary
                snapshot?.setValue(key, forKey: "key")
                
                self.post.append(snapshot!)
                self.homeTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.automatic)
                self.activeLoading.stopAnimating()
            }) {(error) in
                print(error.localizedDescription)
            }
        }

        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(stopAnimating), userInfo: nil, repeats: false)
        
        self.homeTableView.rowHeight = UITableView.automaticDimension
        self.homeTableView.estimatedRowHeight = 215
        
        self.databaseRef.child("following").child(userUid!).observe(.childAdded, with: { (snapshot) in
            
            let snapshot = snapshot.value as? NSDictionary
            self.listFollowing.append(snapshot)
        })
        
        self.databaseRef.child("followers").child(userUid!).observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "uid")
            self.listFollowers.append(snapshot)
        })
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
        let imageTap = UIGestureRecognizer(target: self, action: #selector(self.didTapImage))
        let repostTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapRepost))
        let replyTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapReply))
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapLike))
        
        cell.postImage.addGestureRecognizer(imageTap)
        cell.repost.addGestureRecognizer(repostTap)
        cell.reply.addGestureRecognizer(replyTap)
        cell.like.addGestureRecognizer(likeTap)
        
        if(post[(self.post.count - 1) - (indexPath.row)]!["picture"] != nil) {
            cell.postImage.isHidden = false
            cell.imageViewHeightConstraint.constant = defaultImgaeViewHeightConstraint
            
            let picture = post[(self.post.count - 1) - (indexPath.row)]!["picture"] as! String
            let url = NSURL(string: picture)
            
            cell.postImage.layer.cornerRadius = 10
            cell.postImage.layer.borderWidth = 2
            cell.postImage.layer.borderColor = UIColor.white.cgColor
            cell.postImage!.sd_setImage(with: url as URL?, placeholderImage: UIImage(named: "Logo"))
        } else {
            cell.postImage.isHidden = true
            cell.imageViewHeightConstraint.constant = 0
        }

        let value = self.userData as! NSDictionary
        cell.configure(profilePic: nil, name: value["name"] as! String, nickname: value["nickname"] as! String, post: posts)

        return cell
    }
    
    @objc open func stopAnimating() {
        self.activeLoading.stopAnimating()
    }
    
    @objc func didTapImage(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    @objc func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @objc func didTapRepost(sender: UITapGestureRecognizer) {
        
    }
    
    @objc func didTapReply(sender: UITapGestureRecognizer) {
        print("Tap Comment!")
    }
    
    @objc func didTapLike(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.homeTableView)
        let indexPath = self.homeTableView.indexPathForRow(at: tapLocation)! as IndexPath
        let post = self.post[(self.post.count - 1) - indexPath.row]
        var childUpdates = [String: Any]()
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
