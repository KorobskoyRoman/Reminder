//
//  ReminderViewController.swift
//  Reminder
//
//  Created by Roman Korobskoy on 11.01.2023.
//

import UIKit

final class ReminderViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    var reminder: Reminder? {
        didSet {
            guard let reminder,
            let onChange else { return }
            (onChange)(reminder)
        }
    }
    var workingReminder: Reminder?
    var onChange: ((Reminder) -> Void)?
    var isAddingNewReminder = false

    private var dataSource: DataSource?

    private lazy var collectionView = UICollectionView(frame: view.bounds,
                                                       collectionViewLayout: createLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setNavBar()
        setupCollectionView()
    }

    init(reminder: Reminder?,
         onChange: @escaping (Reminder?) -> Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setNavBar() {
        navigationItem.rightBarButtonItem = editButtonItem
        guard let title = reminder?.title else { return }
        navigationItem.title = title
    }

    private func setupCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        if isEditing {
            applySnapshotForEditing()
        } else {
            applySnapshot()
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return listLayout
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([.header(""), .viewTitle, .viewDate, .viewTime, .viewNotes],
                             toSection: .view)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func applySnapshotForEditing() {
        var snapshot = Snapshot()
        guard let reminder else { return }
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems([.header(Section.title.name), .editText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name), .editDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name), .editText(reminder.notes)], toSection: .notes)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
        }
        return section
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier)
        }
        collectionView.dataSource = dataSource
    }

    private func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        row: Row
    ) {
        let section = section(for: indexPath)

        switch (section, row) {
        case (_, .header(let title)):
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case (.view, _):
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
        case (.title, .editText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case (.date, .editDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case (.notes, .editText(let notes)):
            cell.contentConfiguration = notesConfiguration(for: cell, with: notes)
        default:
            print("Error register cell \nUnexpected combination of section and row.")
            return
        }
        cell.tintColor = .todayPrimaryTint
    }

    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil
        if workingReminder != reminder {
            reminder = workingReminder
        }
        
        applySnapshot()
    }

    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didCancelEdit))
        applySnapshotForEditing()
    }

    @objc func didCancelEdit() {
        workingReminder = reminder
        setEditing(false, animated: true)
    }
}

extension ReminderViewController: UICollectionViewDelegate {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            prepareForEditing()
        } else {
            if !isAddingNewReminder {
                prepareForViewing()
            } else {
                guard let workingReminder,
                let onChange else { return }
                onChange(workingReminder)
            }
        }
    }
}
