//
//  LoginViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/17.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var roundedCornerBtn: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var rootRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roundedCornerBtn.layer.cornerRadius = 4
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
            
            if(error == nil) {
                self.rootRef.child("User").child((user?.user.uid)!).child("nickname").observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
                    
                    if(snapshot.exists()) {
                        self.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
                    } else {
                        self.present(SignUpViewController(), animated: true, completion: nil)
                    }
                })
            }
        })
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
