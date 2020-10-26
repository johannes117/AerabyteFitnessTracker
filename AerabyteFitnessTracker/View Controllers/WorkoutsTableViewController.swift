

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
    if let caloriesBurned =
        workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
      let formattedCalories = String(format: "CaloriesBurned: %.2f",
                                     caloriesBurned)
      
      cell.detailTextLabel?.text = formattedCalories
    }
    else {
      cell.detailTextLabel?.text = nil
    }
    if let aerabyteEarned =
        workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
      let formattedCalories = String(format: "CaloriesBurned: %.2f",
                                     aerabyteEarned)
      
      cell.detailTextLabel?.text = formattedCalories
    }
    else {
      cell.detailTextLabel?.text = nil
    }
   
    
    return cell
  }
}

