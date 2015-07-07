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
    
    
    private let reuseIdentifier = "AttendeeCell"
    private var searches = Array<Array<String>>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
   //     var NumColumns = 2
   //     var NumRows = 3
   //     var array =
   //     var value = 1
         searches = [["person 1", "Invite"],["person 2", "Decline"],["person 3", "Apology"]]
        
        for var i = 0; i < searches.count; i++
        {
            for var j = 0; j < searches[i].count; j++
            {
                println("m[\(i), \(j)] = \(searches[i][j])")
            }
        }
        
   //     for column in 0..NumColumns {
   //         var columnArray = Array<String>()
   //         for row in 0..NumRows {
   //             columnArray.append(value++)
   //         }
   //         array.append(columnArray)
   //     }


    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    //1
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
println("Number of sections = \(searches.count)")
        return searches.count
    }
    
    //2
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return searches[section].searchResults.count
        
        println("Number of items = \(searches[section].count)")
        return searches[section].count
        
    }
    
    //3
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        return cell
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