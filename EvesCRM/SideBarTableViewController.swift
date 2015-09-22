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
    var fullArray: [menuEntry] = Array()
    var displayArray: [menuObject] = Array()
    
    var displayData: String = "Header"
    var numRows: Int = 0

    func initialise()
    {
        for myItem in fullArray
        {
            if myItem.menuType == "Header"
            {
                displayArray = myItem.menuEntries
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return displayArray.count
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

        cell!.textLabel!.text = displayArray[indexPath.row].displayString
                
        if displayArray[indexPath.row].type == "disclosure"
        {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else
        {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
    
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if displayArray[indexPath.row].type != "disclosure"
        {
            delegate?.sideBarControlDidSelectRow(displayArray[indexPath.row])
        }
        else
        {
            for myItem in fullArray
            {
                if myItem.menuType == displayArray[indexPath.row].childSection
                {
                    displayData = displayArray[indexPath.row].childSection
                    displayArray = myItem.menuEntries
                    tableView.reloadData()

                    break
                }
            }
        }
    }
}
