//
//  AppCoordinatorProtocol.swift
//  Reminder
//
//  Created by Roman Korobskoy on 09.01.2023.
//

import UIKit

protocol AppCoordinatorProtocol {
    func start()
    func performTransition(with type: Transition)
}

enum Transition {
    case perform(ViewControllers)
    case pop
}

enum ViewControllers {
    case main

    var viewController: UIViewController {
        switch self {
        case .main:
            return MainViewController()
        }
    }
}
