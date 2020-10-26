//
//  MenuViewController.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

import UIKit

class MenuViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance;

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
        healthKitManager.requestAuthorization()
        
    }
    func setUpElements(){
        //Style the elements
    }
}
