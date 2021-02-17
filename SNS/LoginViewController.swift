//
//  LoginViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/17.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var roundedCornerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roundedCornerBtn.layer.cornerRadius = 4
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
