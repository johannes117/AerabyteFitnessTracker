//  AerabyteFitnessTracker
//
//  Created by Johannes du Plessis on 6/10/20.
//


import HealthKit

extension HKBiologicalSex {
  var stringRepresentation: String {
    switch self {
    case .notSet: return "Unknown"
    case .female: return "Female"
    case .male: return "Male"
    case .other: return "Other"
    @unknown default:
        fatalError()
    }
  }
}
