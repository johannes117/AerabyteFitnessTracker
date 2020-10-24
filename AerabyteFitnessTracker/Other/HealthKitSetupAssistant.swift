//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 6/10/20.
//


import HealthKit

class HealthKitSetupAssistant {
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
      let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
      else {
        completion(false, HealthkitSetupError.dataTypeNotAvailable)
        return
    }
    
    //3. Prepare a list of types you want HealthKit to read and write
    let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                    activeEnergy,
                                                    HKObjectType.workoutType()]
    let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                   bloodType,
                                                   biologicalSex,
                                                   bodyMassIndex,
                                                   height,
                                                   bodyMass,
                                                   HKObjectType.workoutType()]
    
    //4. Request Authorization
    HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                         read: healthKitTypesToRead) { (success, error) in
                                          completion(success, error)
    }
  }
}
