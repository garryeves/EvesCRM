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

let NotificationGmailSignedIn = Notification.Name("GmailSignedIn")
let kRefetchDatabaseNotification = Notification.Name("kRefetchDatabaseNotification")
let NotificationDBReplaceDone = Notification.Name("DBReplaceDone")
let NotificationDBSyncCompleted = Notification.Name("DBSyncCompleted")
let NotificationCloudSyncFinished = Notification.Name("CloudSyncFinished")
let NotificationGmailInboxConnected = Notification.Name("GmailInboxConnected")
let NotificationGmailInboxLoadDidFinish = Notification.Name("GmailInboxLoadDidFinish")
let NotificationGTDInboxDisplayTask = Notification.Name("GTDInboxDisplayTask")
let NotificationDisplayGTDSubmenu = Notification.Name("DisplayGTDSubmenu")
let NotificationMaintainContextsDeleteContext = Notification.Name("MaintainContextsDeleteContext")
let NotificationRemovePane = Notification.Name("RemovePane")
let NotificationAddTeamMember = Notification.Name("AddTeamMember")
let NotificationChangeRole = Notification.Name("ChangeRole")
let NotificationPerformDelete = Notification.Name("PerformDelete")
let NotificationAttendeeRemoved = Notification.Name("AttendeeRemoved")
let NotificationEvernoteAuthenticationDidFinish = Notification.Name("EvernoteAuthenticationDidFinish")
let NotificationChangeSettings = Notification.Name("ChangeSettings")
let NotificationCloudSyncStart = Notification.Name("CloudSyncStart")
let NotificationCloudReLoadStart = Notification.Name("CloudReLoadStart")
let NotificationRemoveTaskContext = Notification.Name("RemoveTaskContext")
let NotificationTeamDecodeChangeSettings = Notification.Name("TeamDecodeChangeSettings")
let NotificationGmailDidFinish = Notification.Name("GmailDidFinish")
let NotificationHangoutsDidFinish = Notification.Name("HangoutsDidFinish")
let NotificationGmailConnected = Notification.Name("GmailConnected")
let NotificationOneNoteConnected = Notification.Name("OneNoteConnected")

let NotificationDropBoxConnected = Notification.Name("DropBoxConnected")
let NotificationDropBoxReady = Notification.Name("DropBoxReady")



