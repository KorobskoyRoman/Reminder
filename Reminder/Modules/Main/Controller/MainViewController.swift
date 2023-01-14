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

    weak var coordinator: AppCoordinator?

    private var dataSource: DataSource?
    private var reminders = Reminder.sampleData
    private var listStyle: ReminderListStyle = .today

    private var filteredReminders: [Reminder] {
        return reminders.filter {
            listStyle.shouldInclude(date: $0.dueDate)
        }.sorted(by: { $0.dueDate < $1.dueDate })
    }

    private let listStyleSegmentedControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])


    private lazy var collectionView = UICollectionView(
        frame: view.bounds,
        collectionViewLayout: listLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Reminder",
                                                 comment: "Reminder view controller title")
        setupCollectionView()
    }

    init(coordinator: AppCoordinator?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder",
                                                         comment: "Add button accessibility label")
        navigationItem.rightBarButtonItem = addButton
        setupDataSource()
    }

    func add(_ reminder: Reminder) {
        reminders.append(reminder)
    }

    private func deleteReminder(for id: Reminder.ID) {
        let index = reminders.indexOfReminder(with: id)
        reminders.remove(at: index)
    }

    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath,
              let id = dataSource?.itemIdentifier(for: indexPath)
        else { return nil }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(
            style: .destructive, title: deleteActionTitle
        ) { [weak self] _, _, completion in
            self?.deleteReminder(for: id)
            self?.applySnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    @objc private func didChangeListStyle(_ sender: UISegmentedControl) {
        listStyle = ReminderListStyle(rawValue: sender.selectedSegmentIndex) ?? .today
        applySnapshot()
    }
}

extension MainViewController {
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.showsSeparators = false
        listConfiguration.leadingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .white
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

    func applySnapshot(reloading ids: [Reminder.ID] = [],
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
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint

        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed: .always)
        ]

        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
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

    private func showDetails(for id: Reminder.ID) {
        let reminder = reminder(for: id)
        coordinator?.performTransition(with: .perform(.reminder),
                                       reminder: reminder,
                                       onChange: { [weak self] reminder in
            guard let reminder else { return }
            self?.update(reminder, with: reminder.id)
            self?.applySnapshot(reloading: [reminder.id])
        })
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

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        showDetails(for: id)
        return false
    }
}
