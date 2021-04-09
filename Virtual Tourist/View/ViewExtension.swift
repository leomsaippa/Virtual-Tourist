//
//  ViewExtension.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 07/04/21.
//

import Foundation
import UIKit

extension UIViewController {

    func showAlert(message: String, title: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }


}
