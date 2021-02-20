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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(profilePic: String?, name: String, nickname: String, post: String) {
        self.post.text = post
        self.nickname.text = nickname
        self.name.text = name
        
        if((profilePic) != nil) {
            let imageData = NSData(contentsOf: NSURL(string: profilePic!)! as URL)
            self.profilePic.image = UIImage(data: imageData! as Data)
        } else {
            self.profilePic.image = UIImage(named: "Logo")
        }
    }

}
