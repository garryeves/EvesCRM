//
//  taskManagementClasses.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 23/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

#if os(iOS)
    class GTDModel: NSObject
    {
        fileprivate var myDelegate: MyMaintainProjectDelegate!
        fileprivate var myActionSource: String = ""
        
        var delegate: MyMaintainProjectDelegate
            {
            get
            {
                return myDelegate
            }
            set
            {
                myDelegate = newValue
            }
        }
        
        var actionSource: String
            {
            get
            {
                return myActionSource
            }
            set
            {
                myActionSource = newValue
            }
        }
    }
#endif

