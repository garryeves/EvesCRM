//
//  DBSync.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 18/08/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit

class DBSync: NSObject
{
    func sync()
    {
        myDatabaseConnection.clearDeletedItems()
        myDatabaseConnection.clearSyncedItems()
    }
}
