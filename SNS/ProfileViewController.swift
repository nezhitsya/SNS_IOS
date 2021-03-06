//
//  ProfileViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var likesContainer: UIView!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var postContainer: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var about: UITextField!
    @IBOutlet weak var imageLoader: UIActivityIndicatorView!
    @IBOutlet weak var numberFollowing: UILabel!
    @IBOutlet weak var numberFollowers: UILabel!
    
    var databaseRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var user: AnyObject? = .none
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.user = Auth.auth().currentUser
        
        let userUid = Auth.auth().currentUser?.uid
        self.databaseRef.child("User").child(userUid!).observeSingleEvent(of: .value) { ( snapshot: DataSnapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.name.text = value?["name"] as? String
            self.nickname.text = value?["nickname"] as? String
            
            if(value?["description"] != nil) {
                self.about.text = value?["description"] as? String
            }

            if(value?["profilePic"] != nil) {
                let databaseProfilePic = value?["profilePic"] as! String

                let data: Data = try! Data(contentsOf: URL(string: databaseProfilePic)!)

                self.setProfilePicture(imageView: self.profilePicture, imageToSet: UIImage(data: data)!)
            }
            self.imageLoader.stopAnimating()
        }
        
        self.databaseRef.child("User").child(userUid!).child("followingCount").observe(.value, with: { (snapshot) in

            if(snapshot.exists()) {
                self.numberFollowing.text = "\(snapshot.value!)"
            } else {
                self.numberFollowing.text = "0"
            }
        })
        
        self.databaseRef.child("User").child(userUid!).child("followersCount").observe(.value, with: { (snapshot) in

            if(snapshot.exists()) {
                self.numberFollowers.text = "\(snapshot.value!)"
            } else {
                self.numberFollowers.text = "0"
            }
        })
    }
    
    @IBAction func didTapProfilePicture(_ sender: UITapGestureRecognizer) {
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: UIAlertController.Style.actionSheet)
        let viewPicture = UIAlertAction(title: "Picture", style: UIAlertAction.Style.default) { (action) in
            
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = UIColor.white
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
            
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertAction.Style.default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        try! Auth.auth().signOut()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let welcomeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "welcomeViewController")
        
        welcomeViewController.modalPresentationStyle = .fullScreen
        
        self.present(welcomeViewController, animated: true, completion: nil)
    }
    
    @IBAction func showComponents(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0) {
            UIView.animate(withDuration: 0.5, animations:  {
                self.postContainer.alpha = 1
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 0
            })
        } else if(sender.selectedSegmentIndex == 1) {
            UIView.animate(withDuration: 0.5, animations: {
                self.postContainer.alpha = 0
                self.mediaContainer.alpha = 1
                self.likesContainer.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.postContainer.alpha = 0
                self.mediaContainer.alpha = 0
                self.likesContainer.alpha = 1
            })
        }
    }
    
    @objc func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.imageLoader.startAnimating()
        setProfilePicture(imageView: self.profilePicture, imageToSet: image)
        
        let userUid = Auth.auth().currentUser?.uid
        let imageData = Data()
        let profilePicStorageRef = storageRef.child("User/\(userUid!)/profilePic")
        profilePicStorageRef.putData(imageData, metadata: nil) { metadata, error in
            
            if(error == nil) {
                profilePicStorageRef.downloadURL { (url, error) in
                    if(error == nil) {
                        self.databaseRef.child("User").child(userUid!).child("profilePic").setValue(url!.absoluteString)
                    }
                }
            }
            self.imageLoader.stopAnimating()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func setProfilePicture(imageView: UIImageView, imageToSet: UIImage) {
        imageView.layer.cornerRadius = 10.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
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
