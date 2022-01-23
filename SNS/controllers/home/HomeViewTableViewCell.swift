//
//  HomeViewTableViewCell.swift
//  SNS
//
//  Created by 이다영 on 2021/02/20.
//

import UIKit

class HomeViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var post: UITextView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reply: UIButton!
    @IBOutlet weak var repost: UIButton!
    @IBOutlet weak var like: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(profilePic: String?, name: String, nickname: String, post: String) {
        self.post.text = post
        self.nickname.text = nickname
        self.name.text = name
        
        if((profilePic) != nil) {
            let imageData: Data = try! Data(contentsOf: URL(string: profilePic!)!)
            self.profilePic.image = UIImage(data: imageData)
        } else {
            self.profilePic.image = UIImage(named: "Logo")
        }
    }

}
