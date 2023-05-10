//
//  RecipeDetailsViewController.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    var recipeId: Int = 0
    var recipeTitle: String = ""
    var totalTime: Int = 0
    var ingredients: [String] = []
    var instructions: [String] = []
    
    var indicator = UIActivityIndicatorView()
    
    //    let apiKey = "25231069356d414fa201177ef0c1dfbd"
    let apiKey = "9967866fa4b14ddf91122861be29bf3f"
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var instructionsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up and start indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        indicator.startAnimating()
        
        // Set recipe title
        navigationItem.title = recipeTitle
        
        // Search recipe with id
        Task {
            await requestRecipe()
            
            // Set recipe total time
            totalTimeLabel.text = "\(totalTime) minutes"
            
            // Format instructions
            var formattedInstructions = ""
            for index in 0...instructions.count-1 {
                formattedInstructions.append("\(index+1). " + instructions[index] + "\n\n")
            }
            instructionsTextView.text = formattedInstructions
            
            // Format ingredients
            var formattedIngredients = ""
            for ingredient in ingredients {
                formattedIngredients.append("\u{2022} " + ingredient + "\n\n")
            }
            ingredientsTextView.text = formattedIngredients
        }
    }
    
    
    // Make specific recipe details request to API & parse result
    func requestRecipe() async {
        // Create URL for API request
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "api.spoonacular.com"
        searchURLComponents.path = "/recipes/" + "\(recipeId)" + "/information"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "includeNutrition", value: "false"),
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
                let recipe = try decoder.decode(Recipe.self, from: data)
                
                // Get total time
                totalTime = recipe.totalTime ?? 0
                
                // Get each ingredient
                if let ingredientsResult = recipe.ingredients {
                    for ingredient in ingredientsResult {
                        ingredients.append(ingredient.original)
                    }
                } else {
                    ingredients.append("No ingredients available.")
                }
                
                // Get each instruction step
                if let instructionsResult = recipe.instructions, !(instructionsResult.isEmpty) {
                    for step in instructionsResult[0].steps {
                        instructions.append(step.step)
                    }
                } else {
                    instructions.append("No instructions availalbe.")
                }
            } catch let error {
                print(error)
            }
            
        } catch let error {
            print(error)
        }
    }
    
}
