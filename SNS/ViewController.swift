//
//  ViewController.swift
//  SNS
//
//  Created by 이다영 on 2021/02/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener{ (auth, user) in
            
            if user != nil {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarControllerView")
                
                homeViewController.modalPresentationStyle = .fullScreen
                
                self.present(homeViewController, animated: true, completion: nil)
            }
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
