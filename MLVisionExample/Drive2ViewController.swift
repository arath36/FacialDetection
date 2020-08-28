//
//  Drive2ViewController.swift
//  MLVisionExample
//
//  Created by Austin Rath on 2/16/20.
//  Copyright © 2020 Google Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class Drive2ViewController: UIViewController {
    
    @IBOutlet weak var StartRideButton: UIButton!
    @IBOutlet weak var startRideView: UIView!
    
    var tripData: Trip?
    
    var database: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   try! Auth.auth().signOut()
        if (Auth.auth().currentUser == nil) {
            // need to log in
            let logInVC = LogInViewController()
            self.present(logInVC, animated: false)
        }
        
        
        

        startRideView.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    
    @IBAction func StartRidePressed(_ sender: Any) {

        performSegue(withIdentifier: "driveSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let trip = tripData {
            database = Firestore.firestore()
            
            database.collection("Users").document(Auth.auth().currentUser!.uid).collection("trips").addDocument(data: ["alerts" : trip.alerts, "secondsSuccessful": trip.successfulSeconds, "mileage": trip.mileage, "timestamp": trip.time])
            
        }
        tripData = nil

    }
    
    @IBAction func unwindToDrive(segue:UIStoryboardSegue) {
        
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
