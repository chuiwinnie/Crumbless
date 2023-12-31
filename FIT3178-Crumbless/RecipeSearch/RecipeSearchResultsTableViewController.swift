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
    
    // API keys for searching recipes using Spoonacular
    let apiKey = "25231069356d414fa201177ef0c1dfbd"
    // let apiKey = "9967866fa4b14ddf91122861be29bf3f"
    
    // Limit the maximum number of recipe search results
    let MAX_ITEMS_PER_REQUEST = 50
    
    var ingredients: [Food] = []
    var recipeList: [Recipe] = []
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable large navigation bar title
        navigationItem.largeTitleDisplayMode = .never
        
        // Set up and start indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        indicator.startAnimating()
        
        // Search recipes with added ingredients
        Task {
            await requestRecipes()
        }
    }
    
    // Make search recipes by ingredients request to API
    func requestRecipes() async {
        // Create URL for API request
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.spoonacular.com"
        searchURLComponents.path = "/recipes/findByIngredients"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "ingredients", value: getIngredientsName()),
            URLQueryItem(name: "number", value: "\(MAX_ITEMS_PER_REQUEST)"),
            URLQueryItem(name: "apiKey", value: "\(apiKey)")
        ]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        // Create async data task
        do {
            // Request recipes by ingredients
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            // Stop loading indicator
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            do {
                // Decode data
                let decoder = JSONDecoder()
                let recipeResults = try decoder.decode(Array<Recipe>.self, from: data)
                
                // Add all returned recipes to recipe list
                recipeList.append(contentsOf: recipeResults)
                
                // Show recipes in table view
                DispatchQueue.main.async {
                    _ = self.tableView.indexPathsForSelectedRows
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
        } catch let error {
            print(error)
        }
    }
    
    // Get ingredient names for API request
    func getIngredientsName() -> String {
        var ingredientsName = ""
        
        // Append all ingredient names in a single string in the required format
        for ingredient in ingredients {
            ingredientsName += ingredient.name! + ",+"
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
            // Configure a food cell
            let recipeCell = tableView.dequeueReusableCell(withIdentifier: CELL_RECIPE, for: indexPath)
            var content = recipeCell.defaultContentConfiguration()
            
            // Set the text of each cell as the recipe name
            let recipe = recipeList[indexPath.row]
            content.text = recipe.title
            
            recipeCell.contentConfiguration = content
            recipeCell.accessoryType = .disclosureIndicator
            return recipeCell
        } else {
            // Configure an info cell
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            var content = infoCell.defaultContentConfiguration()
            
            // Display the number of recipes found, if any
            if recipeList.isEmpty {
                content.text = "No recipes found."
            } else {
                content.text = "Total number of recipe(s): \(recipeList.count)"
            }
            
            infoCell.contentConfiguration = content
            return infoCell
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set the recipe to display details for before navigating to the recipe details page
        if segue.identifier == "showRecipeDetailsSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let controller = segue.destination as! RecipeDetailsViewController
                
                // Set recipe ID and title in the recipe details page
                let recipe = recipeList[indexPath.row]
                controller.recipeId = recipe.id
                controller.recipeTitle = recipe.title
            }
        }
    }
    
}


/**
 References
 - Getting recipes by ingredients: https://spoonacular.com/food-api/docs#Search-Recipes-by-Ingredients
 */
