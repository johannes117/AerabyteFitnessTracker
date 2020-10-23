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

class WorkoutDataStore {
  class func save(prancerciseWorkout: PrancerciseWorkout,
                  completion: @escaping ((Bool, Error?) -> Swift.Void)) {
    let healthStore = HKHealthStore()
    let workoutConfiguration = HKWorkoutConfiguration()
    workoutConfiguration.activityType = .other
    let builder = HKWorkoutBuilder(healthStore: healthStore,
                                   configuration: workoutConfiguration,
                                   device: .local())
    
    builder.beginCollection(withStart: prancerciseWorkout.start) { (success, error) in
      guard success else {
        completion(false, error)
        return
      }
    }
    
    let samples = self.samples(for: prancerciseWorkout)
    
    builder.add(samples) { (success, error) in
      guard success else {
        completion(false, error)
        return
      }
      
      builder.endCollection(withEnd: prancerciseWorkout.end) { (success, error) in
        guard success else {
          completion(false, error)
          return
        }
        
        builder.finishWorkout { (workout, error) in
          let success = error == nil
          completion(success, error)
        }
      }
    }
  }
  
  private class func samples(for workout: PrancerciseWorkout) -> [HKSample] {
    //1. Verify that the energy quantity type is still available to HealthKit.
    guard let energyQuantityType = HKSampleType.quantityType(
      forIdentifier: .activeEnergyBurned) else {
          fatalError("*** Energy Burned Type Not Available ***")
    }
    
    //2. Create a sample for each PrancerciseWorkoutInterval
    let samples: [HKSample] = workout.intervals.map { interval in
      let calorieQuantity = HKQuantity(unit: .kilocalorie(),
                                       doubleValue: interval.totalEnergyBurned)
      
      return HKCumulativeQuantitySeriesSample(type: energyQuantityType,
                                                    quantity: calorieQuantity,
                                                    start: interval.start,
                                                    end: interval.end)
    }
    
    return samples
  }
  
  class func loadPrancerciseWorkouts(completion:
      @escaping ([HKWorkout]?, Error?) -> Void) {
    //1. Get all workouts with the "Other" activity type.
    let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
    
    //2. Get all workouts that only came from this app.
    let sourcePredicate = HKQuery.predicateForObjects(from: .default())
    
    //3. Combine the predicates into a single predicate.
    let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
      [workoutPredicate, sourcePredicate])
    
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                          ascending: true)
    
    let query = HKSampleQuery(
      sampleType: .workoutType(),
      predicate: compound,
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
