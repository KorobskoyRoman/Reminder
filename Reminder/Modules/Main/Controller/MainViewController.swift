//
//  MainViewController.swift
//  Reminder
//
//  Created by Roman Korobskoy on 09.01.2023.
//

import UIKit

final class MainViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>

    private var dataSource: DataSource?
    private var reminders = Reminder.sampleData

    private lazy var collectionView = UICollectionView(
        frame: view.bounds,
        collectionViewLayout: listLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
//        collectionView.backgroundColor = .black
        setupDataSource()
    }
}

extension MainViewController {
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .black
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }

    private func setupDataSource() {
        let cellReg = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellReg,
                for: indexPath,
                item: itemIdentifier)
        }

        applySnapshot()

        collectionView.dataSource = dataSource
    }

    private func applySnapshot(reloading ids: [Reminder.ID] = [],
                               animatingDifferences: Bool = true) {
        var snapshot = Snapshot()

        snapshot.appendSections([0])
        snapshot.appendItems(reminders.map { $0.id }) // fixed 'title' to 'id'

        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }

        dataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - Cell + Reminder methods
extension MainViewController {
    private func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        id: Reminder.ID
    ) {
        let reminder = reminder(for: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration

        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .lightGray.withAlphaComponent(0.8)

        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed: .always)
        ]

        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .darkGray
        cell.backgroundConfiguration = backgroundConfiguration
    }

    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
    }

    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString(
            "Toggle completion",
            comment: "Reminder done button accessibility label"
        )
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(with: reminder.id)
            return true
        }
        return action
    }

    private func reminder(for id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(with: id)
        return reminders[index]
    }

    private func update(_ reminder: Reminder, with id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders[index] = reminder
    }

    func completeReminder(with id: Reminder.ID) {
        var reminder = reminder(for: id)
        reminder.isComplete.toggle()
        update(reminder, with: id)
        applySnapshot(reloading: [id])
    }
}

extension MainViewController {
    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }
}
