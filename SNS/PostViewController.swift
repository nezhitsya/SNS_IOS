//
//  PostViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var postTextView: UITextView!
    
    var databaseRef = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        postTextView.textContainerInset = UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20)
        postTextView.text = "text ..."
        postTextView.textColor = UIColor.lightGray
        postTextView.delegate = self
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        postTextView.text = ""
        postTextView.textColor = UIColor.black
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func didTapPost(_ sender: Any) {
        
        if(postTextView.text.count > 0) {
            let key = self.databaseRef.child("posts").childByAutoId().key
            let user = Auth.auth().currentUser
            
            let childUpdates = ["/posts/\(user!.uid)/\(key)/text": postTextView.text!, "/posts/\(user!.uid)/\(key)/timestamp": "\(NSDate().timeIntervalSince1970)"]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
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
