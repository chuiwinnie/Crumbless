//
//  AnalyticsViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 11/5/2023.
//

import UIKit

class AnalyticsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    @IBOutlet weak var tableView: UITableView!
    
    let CELL_FOOD = "foodCell"
    
    var consumedFoodList: [Food] = []
    var expiredFoodList: [Food] = []
    
    var listenerType = ListenerType.consumedOrExpiredFoodItems
    weak var databaseController: DatabaseProtocol?
    
    var chartView: UIView = UIView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Add the chart view as a subview
        if consumedFoodList.count + expiredFoodList.count == 0 {
            chartView = setUpLabelView()
        } else {
            chartView = setUpPieChartView()
        }
        view.addSubview(chartView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        // Update chart view
        updateChartView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    // MARK: - Chart
    
    func updateChartView() {
        // Create a new pie chart or message label
        var newChartView: UIView
        if consumedFoodList.count + expiredFoodList.count == 0 {
            newChartView = setUpLabelView()
        } else {
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
        let labelView = UILabel.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width*0.8, height: 20))
        labelView.text = "No food items consumed or expired yet."
        labelView.textAlignment = .center
        labelView.center = CGPoint(x: view.center.x, y: view.center.y*0.63)
        
        return labelView
    }
    
    func setUpPieChartView() -> PieChartView {
        // Create a pie chart view
        let pieChartView = PieChartView(frame: CGRect(x: 0, y: 0, width: view.bounds.width*0.8, height: view.bounds.width))
        pieChartView.backgroundColor = .clear
        pieChartView.center = CGPoint(x: view.center.x, y: view.center.y*0.63)
        
        // Set the segments for the pie chart
        let consumedFoodSegment = Segment(name: "Consumed Food", colour: UIColor.systemGreen, value: CGFloat(consumedFoodList.count))
        let expiredFoodSegment = Segment(name: "Expired Food", colour: UIColor.systemRed, value: CGFloat(expiredFoodList.count))
        pieChartView.segments = [consumedFoodSegment, expiredFoodSegment]
        
        return pieChartView
    }
    
    
    // MARK: - Database
    
    func onFoodItemsChange(change: DatabaseChange, foodItems: [Food]) {
        // do nothing
    }
    
    func onConsumedFoodItemsChange(change: DatabaseChange, consumedFoodItems: [Food]) {
        consumedFoodList = consumedFoodItems
        tableView.reloadData()
    }
    
    func onExpiredFoodItemsChange(change: DatabaseChange, expiredFoodItems: [Food]) {
        expiredFoodList = expiredFoodItems
        tableView.reloadData()
    }
    
    func onUsersChange(change: DatabaseChange, users: [User]) {
        // do nothing
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumedFoodList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a food cell
        let foodCell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
        var content = foodCell.defaultContentConfiguration()
        
        let food = consumedFoodList[indexPath.row]
        content.text = food.name
        
        foodCell.contentConfiguration = content
        return foodCell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
