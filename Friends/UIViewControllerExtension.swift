//
//  UIViewControllerExtension.swift
//  Friends
//
//  Created by Jussi Suojanen on 22/06/2017.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSingleButtonDialog(alert: SingleButtonAlert) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.action.buttonTitle,
                                                style: .default,
                                                handler: { _ in alert.action.handler?() }))
        self.present(alertController, animated: true, completion: nil)
    }
}
