//
//  HandleViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/18.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HandleViewController: UIViewController {

    @IBOutlet weak var nickname: SignUpTextField!
    @IBOutlet weak var descript: SignUpTextField!
    @IBOutlet weak var start: UIButton!
    
    var rootRef = Database.database().reference()
    var user: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.user = Auth.auth().currentUser!
    }
    
    @IBAction func didTapStart(_ sender: AnyObject) {
        
        let handle: Void = self.rootRef.child("handles").child(self.nickname.text!).observeSingleEvent(of: .value, with: { [self] (snapshot: DataSnapshot) in
            
            if(!snapshot.exists()) {
                self.rootRef.child("User").child(self.user.uid).child("nickname").setValue(self.nickname.text!)
                
                self.rootRef.child("User").child(self.user.uid).child("description").child("description").setValue(self.descript.text!)
                
                self.rootRef.child("handles").child(self.nickname.text!).setValue((self.user?.user.uid))
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
