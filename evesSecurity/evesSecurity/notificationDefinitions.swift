//
//  notificationDefinitions.swift
//  evesSecurity
//
//  Created by Garry Eves on 10/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UserNotifications

let notificationCenter = NotificationCenter.default
let remoteCenter = UNUserNotificationCenter.current()

let NotificationDBReplaceDone = Notification.Name("SecurityDBReplaceDone")
let NotificationAddInfoDone = Notification.Name("NotificationAddInfoDone")
