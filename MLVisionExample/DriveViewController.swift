//
//  DriveViewController.swift
//  Street Focus Hack
//
//  Created by Matteo Agius on 2/15/20.
//  Copyright © 2020 Matteo Agius. All rights reserved.
//

import UIKit

class DriveViewController: ViewController {

    @IBOutlet weak var startRideView: UIView!
    
    @IBOutlet weak var StartRideButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startRideView.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    
    @IBAction func StartRidePressed(_ sender: Any) {
        StartRideButton.setTitle("End Ride", for: UIControl.State.normal)
        startRideView.backgroundColor = UIColor(red: 35, green: 138, blue: 251, alpha: 0.2)
        performSegue(withIdentifier: "driveSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
