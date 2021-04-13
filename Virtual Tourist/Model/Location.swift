//
//  Location.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 10/04/21.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let location: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case location, country, latitude, longitude
    }
}
