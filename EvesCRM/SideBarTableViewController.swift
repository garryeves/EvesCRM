//
//  SideBarTableViewController.swift
//  BlurrySideBar
//
//  Created by Training on 01/09/14.
//  Copyright (c) 2014 Training. All rights reserved.
//

import UIKit


protocol SideBarTableViewControllerDelegate
{
    func sideBarControlDidSelectRow(passedItem: menuObject)
}

class SideBarTableViewController: UITableViewController
{
    var delegate:SideBarTableViewControllerDelegate?
    var tableData: [menuObject] = Array()
    var numberOfSections: Int = 0
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // return 1
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            // Configure the cell...
            
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor.darkTextColor()
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            
            cell!.selectedBackgroundView = selectedView
        }

        if tableData[indexPath.row].displayType == "Header"
        {
            cell!.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
        }
        else if tableData[indexPath.row].displayType == "Header-Disclosure"
        {
            cell!.textLabel?.font = UIFont.boldSystemFontOfSize(20.0)
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else if tableData[indexPath.row].displayType == "Disclosure"
        {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }

        else
        {
            cell!.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        }
        cell!.indentationLevel = tableData[indexPath.row].indentation
        cell!.textLabel!.text = tableData[indexPath.row].displayString

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
NSLog("GRE- selected row = \(indexPath.row)")
        delegate?.sideBarControlDidSelectRow(tableData[indexPath.row])
    }
}
