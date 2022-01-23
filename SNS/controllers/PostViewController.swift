//
//  PostViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postToolbar: UIToolbar!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintInitialValue = CGFloat()
    var databaseRef = Database.database().reference()
    var imagePicker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.postToolbar.isHidden = false

        postTextView.textContainerInset = UIEdgeInsets(top: 30, left: 20, bottom: 20, right: 20)
        postTextView.text = "text ..."
        postTextView.textColor = UIColor.lightGray
        postTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableKeyboardHideOnTap()
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
    }
    
    private func enableKeyboardHideOnTap() {
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration, animations: {
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue
            self.postToolbar.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.postToolbar.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(postTextView.textColor == UIColor.lightGray) {
            postTextView.text = ""
            postTextView.textColor = UIColor.black
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        var attributedString = NSMutableAttributedString()
        
        if(self.postTextView.text.count > 0) {
            attributedString = NSMutableAttributedString(string: self.postTextView.text+"\n\n")
        } else {
            attributedString = NSMutableAttributedString(string: "text...\n\n")
        }
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        
        let oldWith: CGFloat = textAttachment.image!.size.width
        let scaleFactor: CGFloat = oldWith / (postTextView.frame.size.width - 50)
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        attributedString.append(attrStringWithImage)
        
        postTextView.attributedText = attributedString
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapPost(_ sender: Any) {
        
        var imageArray = [AnyObject]()
        
        self.postTextView.attributedText.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, self.postTextView.text.count), options: []) { (value, range, true) in
            
            if(value is NSTextAttachment) {
                let attachment = value as! NSTextAttachment
                var image: UIImage? = nil
                
                if(attachment.image != nil) {
                    image = attachment.image!
                    imageArray.append(image!)
                } else {
                    print("이미지를 삽입해주세요.")
                }
            }
        }
        
        let user = Auth.auth().currentUser
        let postLength = postTextView.text.count
        let numImages = imageArray.count
        let key = self.databaseRef.child("posts").childByAutoId().key
        let storageRef = Storage.storage().reference()
        let pictureStorageRef = storageRef.child("User/\(user!.uid)/media/\(key!)")
        let image = imageArray[0] as! UIImage
        let lowResImageData = image.jpegData(compressionQuality: 0.50)
        
        if(postLength > 0 && numImages > 0) {
            pictureStorageRef.putData(lowResImageData!, metadata: nil) { metadata, error in
                
                if(error == nil) {
                    pictureStorageRef.downloadURL { (url, error) in
                        let childUpdates = ["/posts/\(user!.uid)/\(key!)/text":self.postTextView.text!, "/posts/\(user!.uid)/\(key!)/timestamp":"\(NSDate().timeIntervalSince1970)", "/posts/\(user!.uid)/\(key!)/picture":url!.absoluteString]
                        self.databaseRef.updateChildValues(childUpdates)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        } else if(postLength > 0) {
            let childUpdates = ["/posts/\(user!.uid)/\(key!)/text":self.postTextView.text!, "/posts/\(user!.uid)/\(key!)/timestamp":"\(NSDate().timeIntervalSince1970)"]
            self.databaseRef.updateChildValues(childUpdates)
            dismiss(animated: true, completion: nil)
        } else if(numImages > 0) {
            pictureStorageRef.putData(lowResImageData!, metadata: nil) { metadata, error in
                
                if(error == nil) {
                    pictureStorageRef.downloadURL { (url, error) in
                        let childUpdates = ["/posts/\(user!.uid)/\(key!)/timestamp":"\(NSDate().timeIntervalSince1970)", "/posts/\(user!.uid)/\(key!)/picture":url!.absoluteString]
                        self.databaseRef.updateChildValues(childUpdates)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
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
