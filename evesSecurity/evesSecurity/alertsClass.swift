//
//  alertsClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 11/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

class alertListItem: UITableViewCell
{
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    override func layoutSubviews()
    {
        contentView.frame = bounds
        super.layoutSubviews()
    }
}

class alerts: NSObject
{
    var alertList: [alertItem] = Array()
    
    func clearAlerts()
    {
        alertList.removeAll()
    }
}

class alertItem: NSObject
{
    fileprivate var myDisplayText: String = ""
    fileprivate var myName: String = ""
    fileprivate var mySource: String = ""
    fileprivate var mySourceObject: Any!
    
    var displayText: String
    {
        get
        {
            return myDisplayText
        }
        set
        {
            myDisplayText = newValue
        }
    }
    
    var name: String
    {
        get
        {
            return myName
        }
        set
        {
            myName = newValue
        }
    }
    
    var source: String
    {
        get
        {
            return mySource
        }
        set
        {
            mySource = newValue
        }
    }
    
    var object: Any?
    {
        get
        {
            return mySourceObject
        }
        set
        {
            mySourceObject = newValue
        }
    }
}
