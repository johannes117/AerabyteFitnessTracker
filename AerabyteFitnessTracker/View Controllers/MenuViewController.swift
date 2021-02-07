//
//  MenuViewController.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

import UIKit
import HealthKit
import Foundation

class MenuViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance;
    let profileDataStore = ProfileDataStore.sharedInstance;
    private let userHealthProfile = UserHealthProfile()


    @IBOutlet weak var weeklyTotal: UILabel!
    @IBOutlet weak var dailyTotal: UILabel!
    @IBOutlet weak var startWorkoutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
        healthKitManager.requestAuthorization()
        func calcDaily(){
        //DAILY AERABYTE CALCULATION
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        var csvString = "Time,Date,Heartrate(BPM)\n"
        healthKitManager.healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion: {(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm:ss"

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
            
            var dayComponent    = DateComponents()
            dayComponent.day    = -1 // For removing one day (yesterday): -1
            let theCalendar     = Calendar.current
            let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
            
            let predicate = HKQuery.predicateForSamples(withStart: nextDate, end: Date(), options: HKQueryOptions())
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate: predicate, limit: 8640, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard let results = results else { return }
                    var runningSum = 0.0
                    var aerabyteAccumulated = 0
                    for quantitySample in results {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        csvString += "\(timeFormatter.string(from: quantitySample.startDate)),\(dateFormatter.string(from: quantitySample.startDate)),\(quantity.doubleValue(for: heartRateUnit))\n"
                        print("\(timeFormatter.string(from: quantitySample.startDate)),\(dateFormatter.string(from: quantitySample.startDate)),\(quantity.doubleValue(for: heartRateUnit))")
                        runningSum += quantity.doubleValue(for: heartRateUnit)
                        func aerabyteCalc (heartRate: Double) -> Int {
                            let maxHR: Double = 220
                            let realmaxHR = maxHR - Double(self.userHealthProfile.age ?? 20)
                            
                            var aerabyteCount = 0
                            if heartRate < realmaxHR * 0.5 {
                               aerabyteCount += 1
                           }
                           else if heartRate >= realmaxHR*0.5 && heartRate < realmaxHR*0.55 {
                               aerabyteCount +=  2
                           }
                           else if heartRate >= realmaxHR*0.55 && heartRate < realmaxHR*0.6 {
                               aerabyteCount +=  3
                           }
                           else if heartRate >= realmaxHR*0.6 && heartRate < realmaxHR*0.65 {
                               aerabyteCount +=  4
                           }
                           else if heartRate >= realmaxHR*0.65 && heartRate < realmaxHR*0.7 {
                               aerabyteCount +=  5
                           }
                           else if heartRate >= realmaxHR*0.7 && heartRate < realmaxHR*0.75 {
                               aerabyteCount += 6
                           }
                           else if heartRate >= realmaxHR*0.75 && heartRate < realmaxHR*0.8 {
                               aerabyteCount +=  7
                           }
                           else if heartRate >= realmaxHR*0.8 && heartRate < realmaxHR*0.85 {
                               aerabyteCount +=  8
                           }
                           else if heartRate >= realmaxHR*0.85 && heartRate < realmaxHR*0.9 {
                               aerabyteCount +=  9
                           }
                           else if heartRate >= realmaxHR*0.9 {
                               aerabyteCount +=  10
                           }
                               return Int(aerabyteCount)
                       }
                        let roundedValue = quantity.doubleValue(for: heartRateUnit)
                        let aerabyteScore: Int = Int((aerabyteCalc(heartRate: roundedValue)))
                        aerabyteAccumulated += aerabyteScore
                        print("Aerabyte Score: ", aerabyteAccumulated)
                    }
                    
                    if results.count != 0 {
                       // print("running Sum: ", (Int(runningSum) / results.count))
                        DispatchQueue.main.async {
                            self.dailyTotal.text = (String(aerabyteAccumulated / 12))
                        }
                    }
                    else {
                        print("0")
                    }
                  
            })
                self.healthKitManager.healthStore.execute(query)
            })
        }
        func calcWeekly(){
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        var csvString = "Time,Date,Heartrate(BPM)\n"
        healthKitManager.healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion: {(success, error) in
                let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "hh:mm:ss"

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
            
            var dayComponent    = DateComponents()
            dayComponent.day    = -7 // For removing one day (yesterday): -1
            let theCalendar     = Calendar.current
            let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
            
            let predicate = HKQuery.predicateForSamples(withStart: nextDate, end: Date(), options: HKQueryOptions())
                
                let query = HKSampleQuery(sampleType:heartRateType, predicate: predicate, limit: 8640, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
                    guard let results = results else { return }
                    var runningSum = 0.0
                    var aerabyteAccumulated = 0
                    for quantitySample in results {
                        let quantity = (quantitySample as! HKQuantitySample).quantity
                        let heartRateUnit = HKUnit(from: "count/min")
                        csvString += "\(timeFormatter.string(from: quantitySample.startDate)),\(dateFormatter.string(from: quantitySample.startDate)),\(quantity.doubleValue(for: heartRateUnit))\n"
                        print("\(timeFormatter.string(from: quantitySample.startDate)),\(dateFormatter.string(from: quantitySample.startDate)),\(quantity.doubleValue(for: heartRateUnit))")
                        runningSum += quantity.doubleValue(for: heartRateUnit)
                        func aerabyteCalc (heartRate: Double) -> Int {
                            let maxHR: Double = 220
                            let realmaxHR = maxHR - Double(self.userHealthProfile.age ?? 20)
                            
                            var aerabyteCount = 0
                            if heartRate < realmaxHR * 0.5 {
                               aerabyteCount += 1
                           }
                           else if heartRate >= realmaxHR*0.5 && heartRate < realmaxHR*0.55 {
                               aerabyteCount +=  2
                           }
                           else if heartRate >= realmaxHR*0.55 && heartRate < realmaxHR*0.6 {
                               aerabyteCount +=  3
                           }
                           else if heartRate >= realmaxHR*0.6 && heartRate < realmaxHR*0.65 {
                               aerabyteCount +=  4
                           }
                           else if heartRate >= realmaxHR*0.65 && heartRate < realmaxHR*0.7 {
                               aerabyteCount +=  5
                           }
                           else if heartRate >= realmaxHR*0.7 && heartRate < realmaxHR*0.75 {
                               aerabyteCount += 6
                           }
                           else if heartRate >= realmaxHR*0.75 && heartRate < realmaxHR*0.8 {
                               aerabyteCount +=  7
                           }
                           else if heartRate >= realmaxHR*0.8 && heartRate < realmaxHR*0.85 {
                               aerabyteCount +=  8
                           }
                           else if heartRate >= realmaxHR*0.85 && heartRate < realmaxHR*0.9 {
                               aerabyteCount +=  9
                           }
                           else if heartRate >= realmaxHR*0.9 {
                               aerabyteCount +=  10
                           }
                               return Int(aerabyteCount)
                       }
                        let roundedValue = quantity.doubleValue(for: heartRateUnit)
                        let aerabyteScore: Int = Int((aerabyteCalc(heartRate: roundedValue)))
                        aerabyteAccumulated += aerabyteScore
                        print("Aerabyte Score: ", aerabyteAccumulated)
                    }
                    
                    if results.count != 0 {
                       // print("running Sum: ", (Int(runningSum) / results.count))
                        DispatchQueue.main.async {
                            self.weeklyTotal.text = (String(aerabyteAccumulated / 12))
                        }
                    }
                    else {
                        print("0")
                    }
                  
            })
                self.healthKitManager.healthStore.execute(query)
            })
        }
        calcDaily()
        calcWeekly()
        
    }
    func setUpElements(){
        //Style the elements
    }
}
