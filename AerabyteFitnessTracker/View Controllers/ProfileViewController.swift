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

import UIKit
import HealthKit

class ProfileViewController: UITableViewController {
  private enum ProfileSection: Int {
    case ageSexBloodType
    case weightHeightBMI
    case readHealthKitData
    case saveBMI
  }
  
  private enum ProfileDataError: Error {
    case missingBodyMassIndex
    
    var localizedDescription: String {
      switch self {
      case .missingBodyMassIndex:
        return "Unable to calculate body mass index with available profile data."
      }
    }
  }
  
  @IBOutlet private var ageLabel: UILabel!
  @IBOutlet private var bloodTypeLabel: UILabel!
  @IBOutlet private var biologicalSexLabel: UILabel!
  @IBOutlet private var weightLabel: UILabel!
  @IBOutlet private var heightLabel: UILabel!
  @IBOutlet private var bodyMassIndexLabel: UILabel!
  
  private let userHealthProfile = UserHealthProfile()
  
  private func updateHealthInfo() {
    loadAndDisplayAgeSexAndBloodType()
    loadAndDisplayMostRecentWeight()
    loadAndDisplayMostRecentHeight()
  }
  
  private func loadAndDisplayAgeSexAndBloodType() {
    do {
      let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
      userHealthProfile.age = userAgeSexAndBloodType.age
      userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
      userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
      updateLabels()
    } catch let error {
      displayAlert(for: error)
    }
  }
  
  private func updateLabels() {
    if let age = userHealthProfile.age {
      ageLabel.text = "\(age)"
    }

    if let biologicalSex = userHealthProfile.biologicalSex {
      biologicalSexLabel.text = biologicalSex.stringRepresentation
    }

    if let bloodType = userHealthProfile.bloodType {
      bloodTypeLabel.text = bloodType.stringRepresentation
    }
    
    if let weight = userHealthProfile.weightInKilograms {
      let weightFormatter = MassFormatter()
      weightFormatter.isForPersonMassUse = true
      weightLabel.text = weightFormatter.string(fromKilograms: weight)
    }
    
    if let height = userHealthProfile.heightInMeters {
      let heightFormatter = LengthFormatter()
      heightFormatter.isForPersonHeightUse = true
      heightLabel.text = heightFormatter.string(fromMeters: height)
    }
   
    if let bodyMassIndex = userHealthProfile.bodyMassIndex {
      bodyMassIndexLabel.text = String(format: "%.02f", bodyMassIndex)
    }
  }
  
  private func loadAndDisplayMostRecentHeight() {
    //1. Use HealthKit to create the Height Sample Type
    guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
      print("Height Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        
        return
      }
      
      //2. Convert the height sample to meters, save to the profile model,
      //   and update the user interface.
      let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
      self.userHealthProfile.heightInMeters = heightInMeters
      self.updateLabels()
    }
  }
  
  private func loadAndDisplayMostRecentWeight() {
    guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
      print("Body Mass Sample Type is no longer available in HealthKit")
      return
    }
    
    ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in
      guard let sample = sample else {
        if let error = error {
          self.displayAlert(for: error)
        }
        return
      }
      
      let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
      self.userHealthProfile.weightInKilograms = weightInKilograms
      self.updateLabels()
    }
  }
  
  private func saveBodyMassIndexToHealthKit() {
    guard let bodyMassIndex = userHealthProfile.bodyMassIndex else {
      displayAlert(for: ProfileDataError.missingBodyMassIndex)
      return
    }
    
    ProfileDataStore.saveBodyMassIndexSample(bodyMassIndex: bodyMassIndex,
                                             date: Date())
  }
  
  private func displayAlert(for error: Error) {
    let alert = UIAlertController(title: nil,
                                  message: error.localizedDescription,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "O.K.",
                                  style: .default,
                                  handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  //MARK:  UITableView Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let section = ProfileSection(rawValue: indexPath.section) else {
      fatalError("A ProfileSection should map to the index path's section")
    }
    
    switch section {
    case .saveBMI:
      saveBodyMassIndexToHealthKit()
    case .readHealthKitData:
      updateHealthInfo()
    default: break
    }
  }
}
