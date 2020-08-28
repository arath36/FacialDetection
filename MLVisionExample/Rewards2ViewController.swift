//
//  Rewards2ViewController.swift
//  MLVisionExample
//
//  Created by Austin Rath on 2/16/20.
//  Copyright © 2020 Google Inc. All rights reserved.
//

import UIKit
import UICircularProgressRing
import FirebaseAuth
import Firebase
import FirebaseStorage
import Kingfisher

var lifeInsuranceDiscount = 0
var autoInsuranceDiscount = 2

class Rewards2ViewController: UIViewController {
    var db: Firestore!

    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var lifeInsurancePBar: UICircularProgressRing!
    
    @IBOutlet weak var autoInsurancePBar: UICircularProgressRing!
    


    override func viewDidLoad() {
            super.viewDidLoad()
            db = Firestore.firestore()

            self.profilePicture.layer.cornerRadius = 50
            self.profilePicture.layer.masksToBounds = true
            profilePicture.image = UIImage(named: "yrZyBSUGhkeeqgmUtsBcdZixfSF3")
            profilePicture.contentMode = .scaleAspectFill
        
        
        
        
        /*
            if let presentedUserID = presentedUserID, presentedUserID != Auth.auth().currentUser!.uid {
                       
                       if presentedUserImage == nil {
                           let ref = Storage.storage().reference(forURL: "gs://bandz-27158.appspot.com/UserProfilePictures/\(presentedUserID).jpg")
                           ref.downloadURL(completion: { (url, error) in
                               guard let url = url else {
                                   return
                               }
                               
                               
                               
                               KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                                   self.presentedUserImage = image
                               })
            
                           })

                       }
            

            // Do any additional setup after loading the view.
        }
        
        */
        

        /*
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
        }
        */

    }

    override func viewWillAppear(_ animated: Bool) {
        lifeInsurancePBar.resetProgress()
        autoInsurancePBar.resetProgress()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        lifeInsurancePBar.startProgress(to: CGFloat(Int(lifeInsuranceDiscount)), duration: 2)
        autoInsurancePBar.startProgress(to: CGFloat(Int(autoInsuranceDiscount)), duration: 2)
    }


}
