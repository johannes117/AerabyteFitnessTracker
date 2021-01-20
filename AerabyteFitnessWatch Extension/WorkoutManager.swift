/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file contains the business logic, which is the interface to HealthKit.
*/

import Foundation
import HealthKit
import Combine
import CoreData

class WorkoutManager: NSObject, ObservableObject {
    
    //Declare Shared Instances
    let healthKitManager = HealthKitManager.sharedInstance
    let profileDataStore = ProfileDataStore.sharedInstance
    /// - Tag: DeclareSessionBuilder
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    var people: [NSManagedObject] = []

 
    
    
    // Publish the following:
    // - heartrate
    // - active calories
    // - distance moved
    // - elapsed time
    // - aerabytes
    
    /// - Tag: Publishers
    @Published var heartrate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedSeconds: Int = 0
    @Published var aerabytes: Int = 0
    
    
    // The app's workout state.
    var running: Bool = false
    
    /// - Tag: TimerSetup
    // The cancellable holds the timer publisher.
    var start: Date = Date()
    var cancellable: Cancellable?
    var accumulatedTime: Int = 0
    var accumulatedAerabytes: Int = 0
    var age: Int = 0
    
    private let userHealthProfile = UserHealthProfile()
    
  
    
    
    private func loadAndDisplayAgeSexAndBloodType() {
      do {
        let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
        userHealthProfile.age = userAgeSexAndBloodType.age
        userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
        userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
      } catch let error {
        //
      }
    }
    
    
    
    
    // Set up and start the timer.
    func setUpTimer() {
        start = Date()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.aerabytes = self.aerabyteTotal() + self.aerabytes
            }
        cancellable = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds = self.incrementElapsedTime()
            }
    }
    
    // Calculate the elapsed time.
    func incrementElapsedTime() -> Int {
        let runningTime: Int = Int(-1 * (self.start.timeIntervalSinceNow))
        return self.accumulatedTime + runningTime
    }
    
    // Provide the workout configuration.
    func workoutConfiguration() -> HKWorkoutConfiguration {
        /// - Tag: WorkoutConfiguration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        return configuration
    }
    
    // Start the workout.
    func startWorkout() {
        // Start the timer.
        loadAndDisplayAgeSexAndBloodType()
        setUpTimer()
        self.running = true
        // Create the session and obtain the workout builder.
        /// - Tag: CreateWorkout
        do {
            session = try HKWorkoutSession(healthStore: healthKitManager.healthStore, configuration: self.workoutConfiguration())
            builder = session.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }
        
        // Setup session and builder.
        session.delegate = self
        builder.delegate = self
        
        // Set the workout builder's data source.
        /// - Tag: SetDataSource
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthKitManager.healthStore,
                                                     workoutConfiguration: workoutConfiguration())
        
        // Start the workout session and begin data collection.
        /// - Tag: StartSession
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
            // The workout has started.
            
            
        }
    }
     
    
    // MARK: - State Control
    func togglePause() {
        // If you have a timer, then the workout is in progress, so pause it.
        if running == true {
            self.pauseWorkout()
        } else {// if session.state == .paused { // Otherwise, resume the workout.
            resumeWorkout()
        }
    }
    
    func pauseWorkout() {
        // Pause the workout.
        session.pause()
        // Stop the timer.
        cancellable?.cancel()
        // Save the elapsed time.
        accumulatedTime = elapsedSeconds
        running = false
    }
    
    func resumeWorkout() {
        // Resume the workout.
        session.resume()
        // Start the timer.
        setUpTimer()
        running = true
    }
    
    func endWorkout() {
        // End the workout session.
        session.end()
        cancellable?.cancel()
    }
    
    func resetWorkout() {
        // Reset the published values.
        DispatchQueue.main.async {
            self.elapsedSeconds = 0
            self.activeCalories = 0
            self.heartrate = 0
            self.distance = 0
            self.aerabytes = 0
        }
    }
    
    // MARK: - Update the UI
    // Update the published values.
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                /// - Tag: SetLabel
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                self.heartrate = roundedValue
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                self.activeCalories = Double( round( 1 * value! ) / 1 )
                return
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                let value = statistics.sumQuantity()?.doubleValue(for: meterUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                self.distance = roundedValue
                return
            default:
                return
            }
            
        }
    }
    
   
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        // Wait for the session to transition states before ending the builder.
        /// - Tag: SaveWorkout
        if toState == .ended {
            print("The workout has now ended.")
            
            builder.endCollection(withEnd: Date()) { (success, error) in
                self.builder.finishWorkout { (workout, error) in
                    // Optionally display a workout summary to the user.
                    self.resetWorkout()
                }
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    //adds aerabyte score to workoutSession method
    func pushScore() -> Int {
        let aerabyteData = (self.aerabytes)/12
        return Int(aerabyteData)
    }
    
    func aerabyteCalc (heartRate: Double) -> Int {
        
        let maxHR: Double = 220
        let realmaxHR = maxHR - Double(userHealthProfile.age ?? 20)
        
    var aerabyteCount = accumulatedAerabytes
        if heartRate < realmaxHR*0.5 {
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
    func aerabyteTotal() -> Int{
       let aerabyteScore: Int = Int((aerabyteCalc(heartRate: heartrate)))
        return self.accumulatedAerabytes + aerabyteScore
   }
}


// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            /// - Tag: GetStatistics
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            // Update the published values.
            updateForStatistics(statistics)
            
        }
    }
}

