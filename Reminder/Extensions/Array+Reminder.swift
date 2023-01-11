//
//  Array+Reminder.swift
//  Reminder
//
//  Created by Roman Korobskoy on 10.01.2023.
//

import Foundation

extension Array where Element == Reminder {
    func indexOfReminder(with id: Reminder.ID) -> Self.Index {
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError("No index yet!")
        }
        return index
    }
}
