//
//  ReminderViewController.swift
//  Reminder
//
//  Created by Roman Korobskoy on 11.01.2023.
//

import UIKit

final class ReminderViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Row>

    var reminder: Reminder?

    private var dataSource: DataSource?

    private lazy var collectionView = UICollectionView(frame: view.bounds,
                                                       collectionViewLayout: createLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        setupCollectionView()
        applySnapshot()
    }

    init(reminder: Reminder?) {
        self.reminder = reminder
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setTitle() {
        guard let title = reminder?.title else { return }
        navigationItem.title = title
    }

    private func setupCollectionView() {
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        setupDataSource()
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        return listLayout
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(
            [.viewTitle, .viewDate, .viewTime, .viewNotes],
            toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: true)
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
    }

    func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        row: Row
    ) {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        cell.contentConfiguration = contentConfiguration
        cell.tintColor = .todayPrimaryTint
    }

    func text(for row: Row) -> String? {
        switch row {
        case .viewDate:
            return reminder?.dueDate.dayText
        case .viewNotes:
            return reminder?.notes
        case .viewTime:
            return reminder?.dueDate.formatted(date: .omitted, time: .shortened)
        case .viewTitle:
            return reminder?.title
        }
    }

}
