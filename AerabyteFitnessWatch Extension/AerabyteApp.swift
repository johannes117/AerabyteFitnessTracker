/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file defines the Aerabyte app.
*/

import SwiftUI
import CoreData

@main
struct AerabyteApp: App {
    // This is the business logic.
    var workoutManager = WorkoutManager()

    // Return the scene.
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(workoutManager)
            }
        }
    }
}

struct AerabyteApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}

// MARK: - Core Data stack
var persistentContainer: NSPersistentCloudKitContainer = {
/*
The persistent container for the application. This implementation
creates and returns a container, having loaded the store for the
application to it. This property is optional since there are legitimate
error conditions that could cause the creation of the store to fail.
*/
let container = NSPersistentCloudKitContainer(name: "AerabyteCore")
container.loadPersistentStores(completionHandler: { (storeDescription, error) in
if let error = error as NSError? {
// Replace this implementation with code to handle the error appropriately.
// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
/*
Typical reasons for an error here include:
* The parent directory does not exist, cannot be created, or disallows writing.
* The persistent store is not accessible, due to permissions or data protection when the device is locked.
* The device is out of space.
* The store could not be migrated to the current model version.
Check the error message to determine what the actual problem was.
*/
fatalError("Unresolved error \(error), \(error.userInfo)")
}
})
return container
}()
// MARK: - Core Data Saving support
func saveContext () {
let context = persistentContainer.viewContext
if context.hasChanges {
do {
try context.save()
} catch {
// Replace this implementation with code to handle the error appropriately.
// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
let nserror = error as NSError
fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
}
}
}
