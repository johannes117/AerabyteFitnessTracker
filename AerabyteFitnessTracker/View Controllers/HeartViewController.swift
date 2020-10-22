//
//  HeartViewController.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

//
//  ViewController.swift
//  Workout Tracker
//
//  Created by Sarah Olson on 3/6/17.
//  Copyright © 2017 Sarah Olson. All rights reserved.
//

import UIKit
import HealthKit

class HeartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let healthKitManager = HealthKitManager.sharedInstance
    
    var datasource: [HKQuantitySample] = []
    
    var heartRateQuery: HKQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        healthKitManager.authorizeHealthKit { (success, error) in
            print("Was healthkit successful? \(success)")
            self.retrieveHeartRateData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func retrieveHeartRateData() {
        
        if let query = healthKitManager.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            self.healthKitManager.heartRateDelegate = self
            self.healthKitManager.healthStore.execute(query)
        }
    }
}
extension HeartViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath)
        cell.textLabel?.text = "\(datasource[indexPath.row].quantity)"
        return cell
    }
}

extension HeartViewController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            
            self.datasource.append(contentsOf: heartRateSamples)
            self.tableView.reloadData()
        }
    }
}



