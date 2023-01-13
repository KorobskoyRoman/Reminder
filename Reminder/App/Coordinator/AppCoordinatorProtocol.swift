//
//  AppCoordinatorProtocol.swift
//  Reminder
//
//  Created by Roman Korobskoy on 09.01.2023.
//

import UIKit

protocol AppCoordinatorProtocol {
    func start()
    func performTransition(with type: Transition,
                           reminder: Reminder?,
                           onChange: ((Reminder?) -> Void)?)
}

enum Transition {
    case perform(ViewControllers)
    case pop
    case dismiss(UIViewController)
}

enum ViewControllers {
    case main
    case reminder

    var viewController: UIViewController {
        switch self {
        case .main:
            return MainViewController(coordinator: nil)
        case .reminder:
            return ReminderViewController(reminder: nil, onChange: {_ in })
        }
    }
}
