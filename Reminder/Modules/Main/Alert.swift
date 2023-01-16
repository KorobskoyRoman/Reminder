//
//  Alert.swift
//  Reminder
//
//  Created by Roman Korobskoy on 16.01.2023.
//

import UIKit

final class Alert {
    static let shared = Alert()

    func showError(vc: UIViewController, _ error: Error) {
        let alertTitle = NSLocalizedString("Error",
                                           comment: "Error alert title")
        let alert = UIAlertController(title: alertTitle,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK",
                                            comment: "Alert OK button title")
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            vc.dismiss(animated: true)
        })

        vc.present(alert, animated: true)
    }
}
