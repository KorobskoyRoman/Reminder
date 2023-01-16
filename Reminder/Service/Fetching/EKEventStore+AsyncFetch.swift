//
//  EKEventStore+AsyncFetch.swift
//  Reminder
//
//  Created by Roman Korobskoy on 16.01.2023.
//

import Foundation
import EventKit

extension EKEventStore {
    func fetchReminders(
        matching predicate: NSPredicate
    ) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { continuation in
            fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: ReminderError.failedReadingReminders)
                }
            }
        }
    }
}
