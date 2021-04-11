//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 10/04/21.
//


import Foundation
import UIKit

struct PhotoModel: Codable {
    var photoImage: UIImage?
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let url_m: String
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case url_m = "url_m"
    }
}
