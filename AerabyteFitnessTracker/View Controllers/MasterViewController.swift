

import UIKit

class MasterViewController: UITableViewController {
    let healthKitManager = HealthKitManager.sharedInstance;
  private let authorizeHealthKitSection = 2

  
  
  // MARK: - UITableView Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == authorizeHealthKitSection {
        healthKitManager.requestAuthorization()
        
    }
  }
}
