//
//  SummaryViewController.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 26/1/21.
//

import UIKit
import HealthKit

class SummaryViewController: UITableViewController {
    
    let healthKitManager = HealthKitManager.sharedInstance;
    let profileDataStore = ProfileDataStore.sharedInstance;
    private let userHealthProfile = UserHealthProfile()
    
    var workouts: HKWorkout?
    private let SummaryCellID = "SummaryCell"
    
    var aerabyteScore = 0;
    
 

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier:
          SummaryCellID, for: indexPath)
        cell.detailTextLabel?.text = String("Aerabyte Score: ")
        return cell
        
       
        
    }
    

}

