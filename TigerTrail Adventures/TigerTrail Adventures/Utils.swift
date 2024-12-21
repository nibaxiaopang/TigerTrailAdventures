//
//  Utils.swift
//  TigerTrail Adventures
//
//  Created by jin fu on 2024/12/21.
//


import UIKit

//MARK: - Alert

class Utils {
    static func showAlert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
