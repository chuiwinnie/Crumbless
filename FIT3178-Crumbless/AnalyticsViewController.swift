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
    
    var listenerType = ListenerType.consumedFoodItems
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
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
