//
//  pickerViewController.swift
//  GroupFitness
//
//  Created by Garry Eves on 12/03/2016.
//  Copyright © 2016 Garry Eves. All rights reserved.
//

import Foundation

import UIKit

@objc protocol MyPickerDelegate
{
    @objc optional func myPickerDidFinish(_ source: String, selectedItem:Int)
    @objc optional func myPickerDidFinish(_ source: String, selectedDouble:Double)
    @objc optional func myPickerDidFinish(_ source: String, selectedString:String)
    @objc optional func myPickerDidFinish(_ source: String, selectedDate:Date)
    @objc optional func myPickerDidFinish(_ source: String)
}

class PickerViewController: UIViewController
{
    @IBOutlet weak var btnSelect: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var myPicker: UIPickerView!
    
    var pickerValues: [String]?
    var source: String?
    var delegate: MyPickerDelegate?
    
    private var selectedRow: Int = -1
    private var maxLines: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if pickerValues!.count == 0
        {
            btnSelect.isEnabled = false
        }
        
        // work out the size of the rows
        
        for myItem in pickerValues!
        {
            let textArr = myItem.components(separatedBy: "\n")
            
            var numLinesInt = textArr.count
            
            if numLinesInt < 1
            {
                numLinesInt = 1
            }
            
            let numLines = CGFloat(numLinesInt)
            
            if numLines > maxLines
            {
                maxLines = numLines
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(_ TableTypeSelection1: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerValues!.count
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return pickerValues![row]
    }
    
    func pickerView(_ TableTypeSelection1: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedRow = row
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView
    {
        var label : UILabel
        
        // Work out how many lines are in the incoming string, and use this to calulcate the size of the row
        
        let textArr = pickerValues![row].components(separatedBy: "\n")
        
        var numLinesInt = textArr.count
        
        if numLinesInt < 1
        {
            numLinesInt = 1
        }
        
        let numLines = CGFloat(numLinesInt)
        
        if view == nil
        {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: UIFont.systemFont(ofSize: UIFont.systemFontSize).lineHeight * numLines * UIScreen.main.scale))
            label.textAlignment = NSTextAlignment.center
            if numLinesInt > 1
            {
                label.numberOfLines = numLinesInt
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                label.autoresizingMask = UIViewAutoresizing.flexibleWidth
            }
        }
        else
        {
            label = view as! UILabel
        }
        
        label.text = pickerValues![row]
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return UIFont.systemFont(ofSize: UIFont.systemFontSize).lineHeight * maxLines * UIScreen.main.scale
    }
    
    @IBAction func btnSelect(_ sender: UIBarButtonItem)
    {
        delegate!.myPickerDidFinish!(source!, selectedItem: selectedRow)
        dismiss(animated: true, completion: nil)
    }
}
