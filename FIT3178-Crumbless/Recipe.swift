//
//  Recipe.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class Recipe: NSObject, Decodable {
    var id: Int
    var title: String
    var totalTime: Int?
    var ingredients: [ExtendedIngredients]?
    var instructions: [AnalysedInstructions]?
    
    private enum RecipeKeys: String, CodingKey {
        case id
        case title
        case readyInMinutes
        case extendedIngredients
        case analyzedInstructions
    }
    
    struct ExtendedIngredients: Decodable {
        var original: String
    }
    
    struct AnalysedInstructions: Decodable {
        var steps: [Steps]
    }
    
    struct Steps: Decodable {
        var step: String
    }
    
    required init(from decoder: Decoder) throws {
        // Root recipe container
        let recipeContainer = try decoder.container(keyedBy: RecipeKeys.self)
        
        // Get recipe ID & title
        id = try recipeContainer.decode(Int.self, forKey: .id)
        title = try recipeContainer.decode(String.self, forKey: .title)
        
        // Get recipe details
        totalTime = try? recipeContainer.decode(Int.self, forKey: .readyInMinutes)
        instructions = try? recipeContainer.decode([AnalysedInstructions].self, forKey: .analyzedInstructions)
        ingredients = try? recipeContainer.decode([ExtendedIngredients].self, forKey: .extendedIngredients)
    }
}
