//
//  MainViewController+Action.swift
//  Reminder
//
//  Created by Roman Korobskoy on 10.01.2023.
//

import UIKit

extension MainViewController {
    @objc func didPressDoneButton(_ sender: ReminderDoneButton){
        guard let id = sender.id else { return }
        completeReminder(with: id)
    }
}
