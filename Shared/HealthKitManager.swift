//
//  HealthKitManager.swift
//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 22/10/20.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    let healthStore = HKHealthStore()
    
    var anchor: HKQueryAnchor?
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // Requesting authorization.
        /// - Tag: RequestAuthorization
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
           
        ]
        guard
          let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
          let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
          let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
          let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
          let height = HKObjectType.quantityType(forIdentifier: .height),
          let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
          let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
          let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
          else {
            
            return
        }
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        heartRate,
                                                        HKObjectType.workoutType()]
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       heartRate,
                                                       HKObjectType.workoutType()]
        // Request authorization for those quantity types.
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
                                              
        }
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
        }
    }
    
    
    
    class func loadWorkouts(completion:
        @escaping ([HKWorkout]?, Error?) -> Void) {
      //1. Get all workouts with the "Other" activity type.
      let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)

      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                            ascending: false)
            
      let query = HKSampleQuery(
        sampleType: .workoutType(),
        predicate: workoutPredicate,
        limit: 10,
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
    
    //HealthKitSetupAssistant:
    private enum HealthkitSetupError: Error {
      case notAvailableOnDevice
      case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
      //1. Check to see if HealthKit Is Available on this device
      guard HKHealthStore.isHealthDataAvailable() else {
        completion(false, HealthkitSetupError.notAvailableOnDevice)
        return
      }
      
      //2. Prepare the data types that will interact with HealthKit
      guard
        let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
        let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
        let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
        let height = HKObjectType.quantityType(forIdentifier: .height),
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
        let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
        else {
          completion(false, HealthkitSetupError.dataTypeNotAvailable)
          return
      }
      //3. Prepare a list of types you want HealthKit to read and write
      let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                      activeEnergy,
                                                      heartRate,
                                                      HKObjectType.workoutType()]
      let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                     bloodType,
                                                     biologicalSex,
                                                     bodyMassIndex,
                                                     height,
                                                     bodyMass,
                                                     heartRate,
                                                     HKObjectType.workoutType()]
      
      //4. Request Authorization
      HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                           read: healthKitTypesToRead) { (success, error) in
                                            completion(success, error)
      }
    }

}
