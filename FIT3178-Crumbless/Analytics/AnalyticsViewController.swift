//
//  AnalyticsViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 11/5/2023.
//

import UIKit

class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    
    let CELL_FOOD = "foodCell"
    
    var listenerType = ListenerType.consumedOrExpiredFoodItems
    weak var databaseController: DatabaseProtocol?
    
    var foodList: [Food] = []
    var consumedFoodList: [Food] = []
    var expiredFoodList: [Food] = []
    
    var chartView: UIView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Set up segmented control
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Set table view height constraint
        tableViewHeightContraint.constant = view.bounds.height * 0.25
        
        // Add the chart view as a subview
        if consumedFoodList.count + expiredFoodList.count == 0 {
            segmentedControl.isHidden = true
            chartView = setUpLabelView()
        } else {
            chartView = setUpPieChartView()
            segmentedControl.isHidden = false
        }
        view.addSubview(chartView)
    }
    
    // Update table content if segmented control value changed
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        // Update chart view
        updateChartView()
        
        // Update table view
        updateTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - Chart View
    
    func updateChartView() {
        // Create a new pie chart or message label
        var newChartView: UIView
        if consumedFoodList.count + expiredFoodList.count == 0 {
            segmentedControl.isHidden = true
            newChartView = setUpLabelView()
        } else {
            segmentedControl.isHidden = false
            newChartView = setUpPieChartView()
        }
        
        // Replace the chart view
        if let index = view.subviews.firstIndex(of: chartView) {
            chartView.removeFromSuperview()
            view.insertSubview(newChartView, at: index)
            chartView = newChartView
        }
    }
    
    func setUpLabelView() -> UILabel {
        // Create a no items message label view
        let labelView = UILabel.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width*0.8, height: view.bounds.width*0.8))
        labelView.text = "No food items consumed or expired yet."
        labelView.textAlignment = .center
        labelView.numberOfLines = 0
        labelView.center = CGPoint(x: view.center.x, y: view.center.y*0.63)
        
        return labelView
    }
    
    func setUpPieChartView() -> DonutChartView {
        // Create a pie chart view
        let pieChartView = DonutChartView(frame: CGRect(x: 0, y: 0, width: view.bounds.width*0.8, height: view.bounds.width))
        pieChartView.backgroundColor = .clear
        pieChartView.center = CGPoint(x: view.center.x, y: view.center.y*0.63)
        
        // Set the segments for the pie chart
        let consumedFoodSegment = Segment(name: "Consumed Food", colour: UIColor.systemYellow, value: CGFloat(consumedFoodList.count))
        let expiredFoodSegment = Segment(name: "Expired Food", colour: UIColor.systemBlue, value: CGFloat(expiredFoodList.count))
        pieChartView.segments = [consumedFoodSegment, expiredFoodSegment]
        
        return pieChartView
    }
    
    
    // MARK: - Database
    
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food]) {
        // General/Normal food items are not shown in this tab/table, hence do nothing
    }
    
    // Update consumed food list when database consumed food items change
    func onConsumedFoodItemsChange(change: DatabaseChange, consumedFoodItems: [Food]) {
        consumedFoodList = consumedFoodItems
        tableView.reloadData()
    }
    
    // Update expired food list when database expired food items change
    func onExpiredFoodItemsChange(change: DatabaseChange, expiredFoodItems: [Food]) {
        expiredFoodList = expiredFoodItems
        tableView.reloadData()
    }
    
    func onUsersChange(change: DatabaseChange, users: [User]) {
        // Users are not shown in this tab/table, hence do nothing
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure a food cell
        let foodCell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
        var content = foodCell.defaultContentConfiguration()
        
        // Show only food items in the food list
        let food = foodList[indexPath.row]
        content.text = food.name
        
        foodCell.contentConfiguration = content
        return foodCell
    }
    
    // Update the table content based on the selected segment
    func updateTableView() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            foodList = consumedFoodList
        case 1:
            foodList = expiredFoodList
        default:
            break
        }
        tableView.reloadData()
    }
    
}


/**
 References
 - Segmented control with table view: https://stackoverflow.com/questions/71361577/segmented-control-with-a-uitableview
 - Replacing chart view: https://stackoverflow.com/questions/30831444/swift-remove-subviews-from-superview
 - Using large navigation bar title: https://www.hackingwithswift.com/example-code/uikit/how-to-enable-large-titles-in-your-navigation-bar
 - Programatically setting table view height constraint: https://stackoverflow.com/questions/42794557/ios-dynamically-set-uitableview-height-in-swift
 */
