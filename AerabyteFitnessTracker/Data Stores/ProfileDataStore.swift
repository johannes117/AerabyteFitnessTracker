/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import HealthKit

class ProfileDataStore {
  class func getAgeSexAndBloodType() throws -> (age: Int,
                                                biologicalSex: HKBiologicalSex,
                                                bloodType: HKBloodType) {
    let healthKitStore = HKHealthStore()
    
    do {
      //1. This method throws an error if these data are not available.
      let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
      let biologicalSex =       try healthKitStore.biologicalSex()
      let bloodType =           try healthKitStore.bloodType()
      
      //2. Use Calendar to calculate age.
      let today = Date()
      let calendar = Calendar.current
      let todayDateComponents = calendar.dateComponents([.year],
                                                        from: today)
      let thisYear = todayDateComponents.year!
      let age = thisYear - birthdayComponents.year!
      
      //3. Unwrap the wrappers to get the underlying enum values.
      let unwrappedBiologicalSex = biologicalSex.biologicalSex
      let unwrappedBloodType = bloodType.bloodType
      
      return (age, unwrappedBiologicalSex, unwrappedBloodType)
    }
  }
  
  class func getMostRecentSample(for sampleType: HKSampleType,
                                 completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
    //1. Use HKQuery to load the most recent samples.
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                          end: Date(),
                                                          options: .strictEndDate)
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                          ascending: false)
    let limit = 1
    let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                    predicate: mostRecentPredicate,
                                    limit: limit,
                                    sortDescriptors: [sortDescriptor]) { (query, samples, error) in
      //2. Always dispatch to the main thread when complete.
      DispatchQueue.main.async {
        guard
          let samples = samples,
          let mostRecentSample = samples.first as? HKQuantitySample
          else {
            completion(nil, error)
            return
        }
        
        completion(mostRecentSample, nil)
      }
    }
    
    HKHealthStore().execute(sampleQuery)
  }
  
  class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
    //1.  Make sure the body mass type exists
    guard let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
      fatalError("Body Mass Index Type is no longer available in HealthKit")
    }
    
    //2.  Use the Count HKUnit to create a body mass quantity
    let bodyMassQuantity = HKQuantity(unit: HKUnit.count(),
                                      doubleValue: bodyMassIndex)
    let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType,
                                               quantity: bodyMassQuantity,
                                               start: date,
                                               end: date)
    
    //3.  Save the same to HealthKit
    HKHealthStore().save(bodyMassIndexSample) { (success, error) in
      if let error = error {
        print("Error Saving BMI Sample: \(error.localizedDescription)")
      } else {
        print("Successfully saved BMI Sample")
      }
    }
  }
}

