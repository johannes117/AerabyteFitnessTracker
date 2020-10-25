
import UIKit

class CreateWorkoutTableViewController: UITableViewController {
  @IBOutlet private var startTimeLabel: UILabel!
  @IBOutlet private var durationLabel: UILabel!
  
  private var timer: Timer!
  
  var session = WorkoutSession()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      self.updateLabels()
    }
  }
  
  private func updateOKButtonStatus() {
    var isEnabled = false
    
    switch session.state {
    case .notStarted, .active:
      isEnabled = false
    case .finished:
      isEnabled = true
    }
    
    navigationItem.rightBarButtonItem?.isEnabled = isEnabled
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    session.clear()
    updateOKButtonStatus()
  }
  
  private lazy var startTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
  
  private lazy var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    return formatter
  }()
  
  func updateLabels() {
    switch session.state {
    case .active:
      startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
      let duration = Date().timeIntervalSince(session.startDate)
      durationLabel.text = durationFormatter.string(from: duration)
    case .finished:
      startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
      let duration = session.endDate.timeIntervalSince(session.startDate)
      durationLabel.text = durationFormatter.string(from: duration)
    default:
      startTimeLabel.text = nil
      durationLabel.text = nil
    }
  }
  
  //MARK: UITableView Datasource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch session.state {
    case .active, .finished:
      return 2
    case .notStarted:
      return 0
    }
  }
  
  //MARK: UITableView Delegate
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    var buttonTitle: String!
    var buttonColor: UIColor!
    
    switch session.state {
    case .active:
      buttonTitle = "STOP PRANCERCISING"
      buttonColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    case .notStarted:
      buttonTitle = "START PRANCERCISING!"
      buttonColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    case .finished:
      buttonTitle = "NEW PRANCERCISE"
      buttonColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    let buttonFrame = CGRect(x: 0, y: 0,
                             width: tableView.frame.size.width,
                             height: 44.0)
    
    let button = UIButton(frame: buttonFrame)
    button.setTitle(buttonTitle, for: .normal)
    button.addTarget(self,
                     action: #selector(startStopButtonPressed),
                     for: .touchUpInside)
    button.backgroundColor = buttonColor
    return button
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 44.0
  }
  
  func beginWorkout() {
    session.start()
    updateLabels()
    updateOKButtonStatus()
    tableView.reloadData()
  }
  
  func finishWorkout() {
    session.end()
    updateLabels()
    updateOKButtonStatus()
    tableView.reloadData()
  }
  
  @objc func startStopButtonPressed() {
    switch session.state {
    case .notStarted, .finished:
      displayStartPrancerciseAlert()
    case .active:
      finishWorkout()
    }
  }
  
  @IBAction func cancelButtonPressed(sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonPressed(sender: Any) {
    guard let currentWorkout = session.completeWorkout else {
      fatalError("Shouldn't be able to press the done button without a saved workout.")
    }
    
    WorkoutDataStore.save(prancerciseWorkout: currentWorkout) { (success, error) in
      if success {
        self.dismissAndRefreshWorkouts()
      } else {
        self.displayProblemSavingWorkoutAlert()
      }
    }
  }
  
  private func dismissAndRefreshWorkouts() {
    session.clear()
    dismiss(animated: true, completion: nil)
  }
  
  private func displayStartPrancerciseAlert() {
    let alert = UIAlertController(title: nil,
                                  message: "Start a Prancercise session? (Get those ankle weights ready)",
                                  preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes",
                                  style: .default) { (action) in
                                    self.beginWorkout()
    }
    
    let noAction = UIAlertAction(title: "No",
                                 style: .cancel,
                                 handler: nil)
    alert.addAction(yesAction)
    alert.addAction(noAction)
    present(alert, animated: true, completion: nil)
  }
  
  private func displayProblemSavingWorkoutAlert() {
    let alert = UIAlertController(title: nil,
                                  message: "There was a problem saving your workout",
                                  preferredStyle: .alert)
    let okayAction = UIAlertAction(title: "O.K.",
                                   style: .default,
                                   handler: nil)
    alert.addAction(okayAction)
    present(alert, animated: true, completion: nil)
  }
}
