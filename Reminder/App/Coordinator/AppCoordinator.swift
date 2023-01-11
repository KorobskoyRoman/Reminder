//
//  AppCoordinator.swift
//  Reminder
//
//  Created by Roman Korobskoy on 09.01.2023.
//

import UIKit

final class AppCoordinator: AppCoordinatorProtocol {
    private let window: UIWindow
    private var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = getViewControllerByType(type: .main)
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController?.navigationBar.standardAppearance = configureNavBarAppearence()
        navigationController?.navigationBar.compactAppearance = configureNavBarAppearence()
        navigationController?.navigationBar.scrollEdgeAppearance = configureNavBarAppearence()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func performTransition(with type: Transition,
                           reminder: Reminder? = nil) {
        switch type {
        case .perform(let viewControllers):
            let controller = getViewControllerByType(type: viewControllers,
                                                     reminder: reminder)
            navigationController?.pushViewController(controller, animated: true)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }

    private func getViewControllerByType(type: ViewControllers,
                                         reminder: Reminder? = nil) -> UIViewController {
        var viewController: UIViewController

        switch type {
        case .main:
            viewController = MainViewController(coordinator: self)
            return viewController
        case .reminder:
            viewController = ReminderViewController(reminder: reminder)
            return viewController
        }
    }
}

extension AppCoordinator {
    private func configureNavBarAppearence() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .todayNavigationBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.navBarTitle]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.navBarLargeTitle]

        appearance.configureWithOpaqueBackground()

        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)

        appearance.backButtonAppearance = backButtonAppearance
        UINavigationBar.appearance().tintColor = .todayPrimaryTint

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        return appearance
    }
}
