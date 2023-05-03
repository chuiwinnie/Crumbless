//
//  Recipe.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 3/5/2023.
//

import UIKit

class Recipe: NSObject, Decodable {
    var id: Int?
    var title: String?
    
    private enum RecipeKeys: String, CodingKey {
        case id
        case title
    }
    
    required init(from decoder: Decoder) throws {
        // Root recipe container
        let recipeContainer = try decoder.container(keyedBy: RecipeKeys.self)
        
        // Get recipe info
        id = try? recipeContainer.decode(Int.self, forKey: .id)
        title = try? recipeContainer.decode(String.self, forKey: .title)
        
    }
}
