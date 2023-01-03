//
//  File.swift
//  
//
//  Created by Adolfo Vera Blasco on 22/9/22.
//

import Foundation

struct User: Codable {
    var name: String
    var jobTitle: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case jobTitle = "job"
    }
}
