//
//  HealthKitManager.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

class HealthKitManager: NSObject {
    
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    let healthStore = HKHealthStore()
    
    var anchor: HKQueryAnchor?
    
    var heartRateDelegate: HeartRateDelegate?
    
  
    
    func authorizeHealthKit(_ completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        let typesToShare = Set([HKObjectType.workoutType(), heartRateType])
        let typesToRead = Set([HKObjectType.workoutType(), heartRateType, HKObjectType.activitySummaryType()])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            print("Was authorization successful? \(success)")
            completion(success, error)
        }
    }
    
  
   

    
    class func loadPrancerciseWorkouts(completion:
        @escaping ([HKWorkout]?, Error?) -> Void) {
      //1. Get all workouts with the "Other" activity type.
      let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
      
      //2. Get all workouts that only came from this app.
       
      
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                            ascending: true)
      
      let query = HKSampleQuery(
        sampleType: .workoutType(),
        predicate: workoutPredicate,
        limit: 0,
        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
          DispatchQueue.main.async {
            //4. Cast the samples as HKWorkout
            guard
              let samples = samples as? [HKWorkout],
              error == nil
              else {
                completion(nil, error)
              return
            }
                                    
            completion(samples, nil)
          }
      }
      
      HKHealthStore().execute(query)
    }
   
}
