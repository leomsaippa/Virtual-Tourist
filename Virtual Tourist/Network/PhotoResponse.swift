//
//  PhotoResponse.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 10/04/21.
//

import Foundation

struct PhotoResponse: Codable {
    let photos: ListPhoto
    let stat: String
}

struct ListPhoto: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}
