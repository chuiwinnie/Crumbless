//
//  RecipeSearchResultsTableViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class RecipeSearchResultsTableViewController: UITableViewController {
    let SECTION_RECIPE = 0
    let SECTION_INFO = 1
    
    let CELL_RECIPE = "recipeCell"
    let CELL_INFO = "recipeNumberCell"
    
    let REQUEST_STRING = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=apples,+flour,+sugar&number=2"
    let apiKey = "25231069356d414fa201177ef0c1dfbd"
    
    var recipeList: [Recipe] = []
    var ingredients: [Food] = []
    var indicator = UIActivityIndicatorView()
    
    let MAX_ITEMS_PER_REQUEST = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up and add indicator to view controller's view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Search recipes with ingredients
        Task {
            await requestRecipes()
        }
    }
        
    // Make request to API & parse results
    func requestRecipes() async {
        print("here")
        // Create URL for API request
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.spoonacular.com"
        searchURLComponents.path = "/recipes/findByIngredients"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "ingredients", value: getIngredientsName()),
            URLQueryItem(name: "number", value: "\(MAX_ITEMS_PER_REQUEST)"),  // Specify up to 50 results per requests
            URLQueryItem(name: "apiKey", value: "\(apiKey)")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        // Create async data task
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            // Stop loading indicator
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            do {
                // Decode data
                let decoder = JSONDecoder()
                let recipeResults = try decoder.decode(Array<Recipe>.self, from: data)
                
                recipeList.append(contentsOf: recipeResults)
                DispatchQueue.main.async {
                    let selectedIndexPaths = self.tableView.indexPathsForSelectedRows
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    // Get ingredients name for API request
    func getIngredientsName() -> String {
        var ingredientsName = ""
        
        for ingredient in ingredients {
            ingredientsName += ingredient.name + ",+"
        }
        
        return ingredientsName
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case SECTION_RECIPE:
            return recipeList.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_RECIPE {
            // Configure and return a food cell
            let recipeCell = tableView.dequeueReusableCell(withIdentifier: CELL_RECIPE, for: indexPath)
            var content = recipeCell.defaultContentConfiguration()
            
            let recipe = recipeList[indexPath.row]
            content.text = recipe.title
            
            //  let expiryDate = food.expiryDate
            //  content.secondaryText = formatDate(date: expiryDate)
            
            recipeCell.contentConfiguration = content
            return recipeCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            if recipeList.isEmpty {
                content.text = "No recipes found."
            } else {
                content.text = "Total number of recipe(s): \(recipeList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
