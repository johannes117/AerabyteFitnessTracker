//
//  MenuViewController.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

import UIKit

class MenuViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance;

    @IBOutlet weak var startWorkoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
        healthKitManager.requestAuthorization()

        Utilities.styleFilledButton(startWorkoutButton)
    }
    func setUpElements(){
        //Style the elements
    }
}
