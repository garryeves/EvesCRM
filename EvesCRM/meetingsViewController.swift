//
//  meetingsViewController.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 7/07/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation

protocol MyMeetingsDelegate{
    func myMeetingsDidFinish(controller:meetingsViewController)
}

class meetingsViewController: UIViewController {

    var delegate: MyMeetingsDelegate?
    
    @IBOutlet weak var lblMeetingHead: UILabel!
    @IBOutlet weak var lblLocationHead: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblAT: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblMeetingName: UILabel!
    @IBOutlet weak var lblChairHead: UILabel!
    @IBOutlet weak var lblMinutesHead: UILabel!
    @IBOutlet weak var lblAttendeesHead: UILabel!
    @IBOutlet weak var colAttendees: UICollectionView!
    @IBOutlet weak var btnChair: UIButton!
    @IBOutlet weak var btnMinutes: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    
    private let reuseAttendeeIdentifier = "AttendeeCell"
    private let reuseAttendeeStatusIdentifier = "AttendeeStatusCell"
    
    private var searches = Array<Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        

         searches = [["Reg", "Invite"],["Mabel", "Decline"],["Rudolf the Red Nosed Reindeer had a very shiny nose", "Apology"]]
        
        for var i = 0; i < searches.count; i++
        {
            for var j = 0; j < searches[i].count; j++
            {
                println("m[\(i), \(j)] = \(searches[i][j])")
            }
        }
        

//        if let cvl = colAttendees.collectionViewLayout as? UICollectionViewFlowLayout {
//            cvl.estimatedItemSize = CGSize(width: 300, height: 75)
//        }

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return searches.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return searches[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell : MyDisplayCollectionViewCell!
        
        if indexPath.indexAtPosition(1) == 0
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
            cell.Label.text = searches[indexPath.indexAtPosition(0)][0]
        }
        if indexPath.indexAtPosition(1) == 1
        {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseAttendeeStatusIdentifier, forIndexPath: indexPath) as! MyDisplayCollectionViewCell
            cell.Label.text = searches[indexPath.indexAtPosition(0)][1]
        }
        
        cell.Label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
 
        
println("row = \(indexPath.row)")
println("position = \(indexPath.indexAtPosition(0))")
    
        let swiftColor = UIColor(red: 190/255, green: 254/255, blue: 235/255, alpha: 0.25)
        if (indexPath.indexAtPosition(0) % 2 == 0)  // was .row
        {
            cell.backgroundColor = swiftColor
        }
        else
        {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MyDisplayCollectionViewCell
        if indexPath.indexAtPosition(1) == 0
        {
            println("Clicked Attendee \(cell.Label.text)")
        }
        if indexPath.indexAtPosition(1) == 1
        {
            println("Clicked Status \(cell.Label.text)")
        }
    }

    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var retVal: CGSize!
        
        if indexPath.indexAtPosition(1) == 0
        {
            retVal = CGSize(width: 300, height: 40)
        }
        if indexPath.indexAtPosition(1) == 1
        {
            retVal = CGSize(width: 150, height: 40)
        }
        
        return retVal
    }
    
    
    @IBAction func btnChairClick(sender: UIButton)
    {
    }
    
    
    @IBAction func btnMinutes(sender: UIButton)
    {
    }
    
    @IBAction func btnBackClick(sender: UIButton)
    {
        delegate?.myMeetingsDidFinish(self)
    }
}

class MyDisplayCollectionViewCell: UICollectionViewCell
{
    @IBOutlet var Label: UILabel! = UILabel()
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        Label.text = ""
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Label.text = ""
    }
}
