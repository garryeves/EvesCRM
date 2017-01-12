//
//  notificationDefinitions.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 12/1/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UserNotifications

let notificationCenter = NotificationCenter.default
let remoteCenter = UNUserNotificationCenter.current()

// Notification names

let NotificationGmailSignedIn = Notification.Name("NotificationGmailSignedIn")
let kRefetchDatabaseNotification = Notification.Name("kRefetchDatabaseNotification")
let NotificationDBReplaceDone = Notification.Name("NotificationDBReplaceDone")
let NotificationDBSyncCompleted = Notification.Name("NotificationDBSyncCompleted")
let NotificationCloudSyncFinished = Notification.Name("NotificationCloudSyncFinished")
let NotificationGmailInboxConnected = Notification.Name("NotificationGmailInboxConnected")
let NotificationGmailInboxLoadDidFinish = Notification.Name("NotificationGmailInboxLoadDidFinish")
let NotificationGTDInboxDisplayTask = Notification.Name("NotificationGTDInboxDisplayTask")
let NotificationDisplayGTDSubmenu = Notification.Name("NotificationDisplayGTDSubmenu")
let NotificationMaintainContextsDeleteContext = Notification.Name("NotificationMaintainContextsDeleteContext")
let NotificationRemovePane = Notification.Name("NotificationRemovePane")
let NotificationAddTeamMember = Notification.Name("NotificationAddTeamMember")
let NotificationChangeRole = Notification.Name("NotificationChangeRole")
let NotificationPerformDelete = Notification.Name("NotificationPerformDelete")
let NotificationAttendeeRemoved = Notification.Name("NotificationAttendeeRemoved")
let NotificationOneNoteConnected = Notification.Name("NotificationOneNoteConnected")
let NotificationEvernoteAuthenticationDidFinish = Notification.Name("NotificationEvernoteAuthenticationDidFinish")
let NotificationChangeSettings = Notification.Name("NotificationChangeSettings")
let NotificationCloudSyncStart = Notification.Name("NotificationCloudSyncStart")
let NotificationCloudReLoadStart = Notification.Name("NotificationCloudReLoadStart")
let NotificationRemoveTaskContext = Notification.Name("NotificationRemoveTaskContext")
let NotificationTeamDecodeChangeSettings = Notification.Name("NotificationTeamDecodeChangeSettings")
let NotificationOneNoteNotebooksLoaded = Notification.Name("NotificationOneNoteNotebooksLoaded")
let NotificationOneNotePagesReady = Notification.Name("NotificationOneNotePagesReady")
let NotificationOneNoteNoNotebookFound = Notification.Name("NotificationOneNoteNoNotebookFound")
let NotificationEvernoteComplete = Notification.Name("NotificationEvernoteComplete")
let NotificationEvernoteUserDidFinish = Notification.Name("NotificationEvernoteUserDidFinish")
let NotificationGmailDidFinish = Notification.Name("NotificationGmailDidFinish")
let NotificationHangoutsDidFinish = Notification.Name("NotificationHangoutsDidFinish")
let NotificationGmailConnected = Notification.Name("NotificationGmailConnected")



