//
//  PhotoExtension.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 10/04/21.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
