//
//  ViewExtension.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 07/04/21.
//

import Foundation
import UIKit

extension UIViewController {

    func showAlert(message: String, title: String, handler:((UIAlertAction) -> Void)?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alertVC, animated: true)
    }


}
