//
//  HealthKitManager.swift
//  Workout Tracker
//
//  Created by Sarah Olson on 3/6/17.
//  Copyright © 2017 Sarah Olson. All rights reserved.
//

import Foundation
import HealthKit

protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

protocol ActivitySummaryDelegate {
    func activitySummariesUpdated(activitiesSummaries: [HKActivitySummary])
}


class HealthKitManager: NSObject {
    
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    let healthStore = HKHealthStore()
    
    var anchor: HKQueryAnchor?
    
    var heartRateDelegate: HeartRateDelegate?
    
    var activitySummaryDelegate: ActivitySummaryDelegate?
    
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
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return nil
        }

        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else {
                    return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        heartRateQuery.updateHandler = {(query, sampleObjects, deletedObjects, newAnchor, error) -> Void in

            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else {
                    return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        return heartRateQuery
    }
    
    func createActivitySummaryQuery() -> HKQuery? {
        
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year])
        var startDateComponents = calendar.dateComponents(unitFlags, from: Date())
        startDateComponents.calendar = calendar
        
        let summaries = HKQuery.predicateForActivitySummary(with: startDateComponents)
        let query = HKActivitySummaryQuery(predicate: summaries) { (query, summaries, error) in
            guard let activitySummaries = summaries else {
                return
            }
            self.activitySummaryDelegate?.activitySummariesUpdated(activitiesSummaries: activitySummaries)
        }
        return query
    }
}
