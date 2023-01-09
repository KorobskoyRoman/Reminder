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

    func performTransition(with type: Transition) {

    }

    private func getViewControllerByType(type: ViewControllers) -> UIViewController {
        var viewController: UIViewController

        switch type {
        case .main:
            viewController = MainViewController()
            return viewController
        }
    }
}

extension AppCoordinator {
    private func configureNavBarAppearence() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .purple
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.navBarTitle]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.navBarLargeTitle]

        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)

        appearance.backButtonAppearance = backButtonAppearance
        UINavigationBar.appearance().tintColor = .white

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        return appearance
    }
}
