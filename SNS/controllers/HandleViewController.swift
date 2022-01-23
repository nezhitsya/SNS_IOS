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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapStart(_ sender: AnyObject) {
        
        self.rootRef.child("handles").child(self.nickname.text!).observeSingleEvent(of: DataEventType.value, with: { (snapshot: DataSnapshot) in
            
            if(!snapshot.exists()) {
                self.rootRef.child("User").child((Auth.auth().currentUser?.uid)!).child("nickname").setValue(self.nickname.text!)
                
                self.rootRef.child("User").child((Auth.auth().currentUser?.uid)!).child("description").setValue(self.descript.text!)
                
                self.rootRef.child("handles").child(self.nickname.text!).setValue((Auth.auth().currentUser?.uid)!)
                
                self.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
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
