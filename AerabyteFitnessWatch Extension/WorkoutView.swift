/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file defines the workout view.
*/

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutSession: WorkoutManager
    let profileDataStore = ProfileDataStore.sharedInstance
    
    private let userHealthProfile = UserHealthProfile()
    
    private func loadAndDisplayAgeSexAndBloodType() {
      do {
        let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
        userHealthProfile.age = userAgeSexAndBloodType.age
        userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
        userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
      } catch let error {
        print(error)
      }
    }
    
   
    var body: some View {
        VStack(alignment: .leading) {
            // The workout elapsed time.
            Text("\(elapsedTimeString(elapsed: secondsToHoursMinutesSeconds(seconds: workoutSession.elapsedSeconds)))")
                .font(.largeTitle)
                .foregroundColor(Color.red)
                .frame(alignment: .leading)
                .font(Font.system(size: 32, weight: .semibold, design: .default).monospacedDigit())
                
            // The Aerabyte Score.
            Text("\(workoutSession.pushScore()) Aerabytes")
            .font(Font.system(size: 26, weight: .regular, design: .default).monospacedDigit())
            .frame(alignment: .leading)
            
            // The current heartrate.
            Text("\(workoutSession.heartrate, specifier: "%.1f") ❤")
            .font(Font.system(size: 26, weight: .regular, design: .default).monospacedDigit())
            
            let maxHR: Double = 220
            let realmaxHR = maxHR - Double(userHealthProfile.age ?? 20)
            
            // percentage of Current heartrate
            Text("\((workoutSession.heartrate / realmaxHR) * 100 , specifier: "%.1f") %")
            .font(Font.system(size: 26, weight: .regular, design: .default).monospacedDigit())
            Spacer().frame(width: 1, height: 8, alignment: .leading)
             
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
    }
    
    // Convert the seconds into seconds, minutes, hours.
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Convert the seconds, minutes, hours into a string.
    func elapsedTimeString(elapsed: (h: Int, m: Int, s: Int)) -> String {
        return String(format: "%d:%02d:%02d", elapsed.h, elapsed.m, elapsed.s)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView().environmentObject(WorkoutManager())
    }
}
