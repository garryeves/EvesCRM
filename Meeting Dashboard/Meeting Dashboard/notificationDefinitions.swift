//
//  notificationDefinitions.swift
//  Meeting Dashboard
//
//  Created by Garry Eves on 24/4/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UserNotifications

let notificationCenter = NotificationCenter.default
let remoteCenter = UNUserNotificationCenter.current()

// Notification names

let kRefetchDatabaseNotification = Notification.Name("kRefetchMeetingDatabaseNotification")
let NotificationDBReplaceDone = Notification.Name("MeetingDBReplaceDone")
let NotificationDBSyncCompleted = Notification.Name("MeetingDBSyncCompleted")
let NotificationCloudSyncFinished = Notification.Name("nMeetingCloudSyncFinished")
let NotificationMaintainContextsDeleteContext = Notification.Name("MeetingMaintainContextsDeleteContext")
let NotificationAddTeamMember = Notification.Name("MeetingAddTeamMember")
let NotificationChangeRole = Notification.Name("MeetingChangeRole")
let NotificationPerformDelete = Notification.Name("MeetingPerformDelete")
let NotificationAttendeeRemoved = Notification.Name("MeetingAttendeeRemoved")
let NotificationChangeSettings = Notification.Name("MeetingChangeSettings")
let NotificationCloudSyncStart = Notification.Name("MeetingCloudSyncStart")
let NotificationCloudReLoadStart = Notification.Name("MeetingCloudReLoadStart")
let NotificationRemoveTaskContext = Notification.Name("MeetingRemoveTaskContext")
let NotificationTeamDecodeChangeSettings = Notification.Name("MeetingTeamDecodeChangeSettings")
let myNotificationCloudSyncDone = Notification.Name("myNotificationCloudSyncDone")
