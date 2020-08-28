//
//  AnalyticsViewController.swift
//  MLVisionExample
//
//  Created by Austin Rath on 2/16/20.
//  Copyright © 2020 Google Inc. All rights reserved.
//

import UIKit
import Firebase



class AnalyticsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var database: Firestore!
    var averageTrip = 0
    var totalAlerts = 0
    @IBOutlet weak var averageTripLabel: UILabel!
    @IBOutlet weak var totalAlertLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
  
    var tripArray: [Trip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = Firestore.firestore()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        database.collection("Users").document(Auth.auth().currentUser!.uid).collection("trips").addSnapshotListener { (querySnapShot, error) in
            if let query = querySnapShot {
                self.tripArray = []
                var totalTrip = 0
                self.totalAlerts = 0
                for document in query.documents {
                    let localTrip = document.data()["secondsSuccessful"] as? Int ?? 0
                    totalTrip = totalTrip + localTrip
                    let localAlerts = document.data()["alerts"] as? Int ?? 0
                    self.totalAlerts = self.totalAlerts + localAlerts
                    var time = document.data()["timestamp"] as? Timestamp
                    var localTripArr = Trip()
                    localTripArr.alerts = localAlerts
                    localTripArr.successfulSeconds = localTrip
                    localTripArr.time = time
                    self.tripArray.append(localTripArr)
                }
                self.averageTrip = totalTrip/query.documents.count
                lifeInsuranceDiscount = (self.averageTrip/self.totalAlerts)*2
                autoInsuranceDiscount = lifeInsuranceDiscount + 2


            }
            // set the labels here
            self.averageTripLabel.text = String(self.averageTrip)
            self.totalAlertLabel.text = String(self.totalAlerts)
            self.tableView.reloadData()
                        
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = "Trip " + String(indexPath.row + 1)
        cell.alertLabel.text = "Alerts: \(tripArray[indexPath.row].alerts)"
        cell.lengthLabel.text = "Total Length: \(tripArray[indexPath.row].successfulSeconds)"
        
        return cell
     }
    

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func convertTimestamp(serverTimestamp: Double) -> String {
        let x = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: x)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium

        return formatter.string(from: date as Date)
    }
}
