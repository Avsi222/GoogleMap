//
//  AlertsHelper.swift
//  MapProject
//
//  Created by Арсений Дорогин on 14/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import UIKit

class alerts{
    func showSuccesAlert(vc: UIViewController, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(vc: UIViewController, message: String){
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}

