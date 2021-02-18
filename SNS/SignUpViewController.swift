//
//  SignUpViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/17.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var email: SignUpTextField!
    @IBOutlet weak var password: SignUpTextField!
    @IBOutlet weak var signUp: UIButton!
    
    var databaseRef = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        signUp.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapSignup(_ sender: Any) {
        
        signUp.isEnabled = false
        
        Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            if(error == nil) {
                Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                    
                    if(error == nil) {
                        self.databaseRef.child("User").child((user?.user.uid)!).child("email").setValue(self.email.text!)
                        
                        self.performSegue(withIdentifier: "HandleViewSegue", sender: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func didTextChange(_ sender: UITextField) {
        
        if(email.text!.count > 0 && password.text!.count > 0) {
            signUp.isEnabled = true
        } else {
            signUp.isEnabled = false
        }
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
