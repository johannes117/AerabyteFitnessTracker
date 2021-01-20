

import UIKit
import HealthKit

class WorkoutsTableViewController: UITableViewController {
    
    let healthKitManager = HealthKitManager.sharedInstance;
    let profileDataStore = ProfileDataStore.sharedInstance;


  private enum WorkoutsSegues: String {
    case showCreateWorkout
    case finishedCreatingWorkout
  }
  
  private var workouts: [HKWorkout]?
  private let aerabyteWorkoutCellID = "AerabyteWorkoutCell"
  
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    return formatter
  }()
    
  override func viewDidLoad() {
    super.viewDidLoad()
    clearsSelectionOnViewWillAppear = false
    
}
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadWorkouts()
  }
  
  func reloadWorkouts() { 
    HealthKitManager.loadWorkouts { (workouts, error) in
      self.workouts = workouts
      self.tableView.reloadData()
    }
    
  }
    
    }


extension WorkoutsTableViewController {
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return workouts?.count ?? 0
  }
      
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let workouts = workouts else {
      fatalError("""
               CellForRowAtIndexPath should \
               not get called if there are no workouts
               """)
    }
    
    //1. Get a cell to display the workout in
    let cell = tableView.dequeueReusableCell(withIdentifier:
      aerabyteWorkoutCellID, for: indexPath)
    
    //2. Get the workout corresponding to this row
    let workout = workouts[indexPath.row]
    
    //3. Show the workout's start date in the label
    cell.textLabel?.text = dateFormatter.string(from: workout.startDate)
 
    //4. Show the Calorie burn in the lower label
//    if let caloriesBurned =
//        workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
//      let formattedCalories = String(format: "CaloriesBurned: %.2f",
//                                     caloriesBurned)
//
//      cell.detailTextLabel?.text = formattedCalories
//    }
//    else {
//      cell.detailTextLabel?.text = nil
//    }
    print("Hello")
    let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
     
    
        var csvString = "Time,Date,Heartrate(BPM)\n"
        healthKitManager.healthStore.requestAuthorization(toShare: nil, read:[heartRateType], completion:{(success, error) in
            let sortByTime = NSSortDescriptor(key:HKSampleSortIdentifierEndDate, ascending:false)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm:ss"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: HKQueryOptions())
            
            let query = HKSampleQuery(sampleType:heartRateType, predicate: predicate, limit: 600, sortDescriptors:[sortByTime], resultsHandler:{(query, results, error) in
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
                        let realmaxHR = maxHR - 20 // Double(userHealthProfile.age ?? 20)
                        
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
                    print("running Sum: ", (Int(runningSum) / results.count))
                    DispatchQueue.main.async {
                        cell.detailTextLabel?.text = ("Avg Heart Rate: " + (String(Int(runningSum) / results.count)) + " Aerabyte Score: " + (String(aerabyteAccumulated / 12)))
                    }
                }
                else {
                    print("0")
                }
                
              
        })
            self.healthKitManager.healthStore.execute(query)
        })
    
    return cell
  }
    
}

