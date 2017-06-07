//
//  reporting.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 3/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

let reportMonthlyRoster = "reportMonthlyRoster"
let reportWeeklyRoster = "reportWeeklyRoster"
let reportContractForMonth = "Contract for Month"
let reportWagesForMonth = "Wages for Month"
let reportContractForYear = "Contract Profit for Year"
let reportEventPlan = "Event Plan"
let reportContractDates = "Contract between Dates"

let shareExclutionArray = [ UIActivityType.addToReadingList,
                            //UIActivityType.airDrop,
                            UIActivityType.assignToContact,
                            //        UIActivityType.CopyToPasteboard,
                            //        UIActivityType.message,
                            //        UIActivityType.Mail,
                            UIActivityType.openInIBooks,
                            UIActivityType.postToFlickr,
                            UIActivityType.postToTwitter,
                            UIActivityType.postToFacebook,
                            UIActivityType.postToTencentWeibo,
                            UIActivityType.postToVimeo,
                            UIActivityType.postToWeibo,
                            //        Print,
                            UIActivityType.saveToCameraRoll
                            ]

class reports: NSObject
{
    fileprivate var myReports: [report] = Array()
    
    var reports: [report]
    {
        get
        {
            return myReports
        }
    }
    
    func append(_ reportItem: report)
    {
        myReports.append(reportItem)
    }
    
    func removeAll()
    {
        myReports.removeAll()
    }
}

class report: NSObject
{
    fileprivate var myColumnWidth1: Int = 0
    fileprivate var myColumnWidth2: Int = 0
    fileprivate var myColumnWidth3: Int = 0
    fileprivate var myColumnWidth4: Int = 0
    fileprivate var myColumnWidth5: Int = 0
    fileprivate var myColumnWidth6: Int = 0
    fileprivate var myColumnWidth7: Int = 0
    fileprivate var myColumnWidth8: Int = 0
    fileprivate var myColumnWidth9: Int = 0
    fileprivate var myColumnWidth10: Int = 0
    fileprivate var myColumnWidth11: Int = 0
    fileprivate var myColumnWidth12: Int = 0
    fileprivate var myColumnWidth13: Int = 0
    fileprivate var myColumnWidth14: Int = 0
    fileprivate var myRowHeight: Int = 12
    fileprivate var myReportName: String = ""
    fileprivate var myHeader: reportLine!
    fileprivate var myLines: [reportLine] = Array()
    fileprivate var myPdfData: NSMutableData!
    fileprivate var myDisplayString: String = ""
    fileprivate var mySubject: String = ""
    fileprivate let paperSizePortrait = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate let paperSizeLandscape = CGRect(x:0.0, y:0.0, width:841.89, height:595.276)
    fileprivate var paperSize = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate var myPaperOrientation: String = "Portrait"
    fileprivate var disvisor: Double = 2
    fileprivate var leftSide: Int = 50
    
    var columnWidth1: Int
    {
        get
        {
            return myColumnWidth1
        }
        set
        {
            myColumnWidth1 = newValue
        }
    }
    
    var columnWidth2: Int
    {
        get
        {
            return myColumnWidth2
        }
        set
        {
            myColumnWidth2 = newValue
        }
    }
    
    var columnWidth3: Int
    {
        get
        {
            return myColumnWidth3
        }
        set
        {
            myColumnWidth3 = newValue
        }
    }
    
    var columnWidth4: Int
    {
        get
        {
            return myColumnWidth4
        }
        set
        {
            myColumnWidth4 = newValue
        }
    }
    
    var columnWidth5: Int
    {
        get
        {
            return myColumnWidth5
        }
        set
        {
            myColumnWidth5 = newValue
        }
    }
    
    var columnWidth6: Int
    {
        get
        {
            return myColumnWidth6
        }
        set
        {
            myColumnWidth6 = newValue
        }
    }
    
    var columnWidth7: Int
    {
        get
        {
            return myColumnWidth7
        }
        set
        {
            myColumnWidth7 = newValue
        }
    }
    
    var columnWidth8: Int
    {
        get
        {
            return myColumnWidth8
        }
        set
        {
            myColumnWidth8 = newValue
        }
    }
    
    var columnWidth9: Int
    {
        get
        {
            return myColumnWidth9
        }
        set
        {
            myColumnWidth9 = newValue
        }
    }
    
    var columnWidth10: Int
    {
        get
        {
            return myColumnWidth10
        }
        set
        {
            myColumnWidth10 = newValue
        }
    }
    
    var columnWidth11: Int
    {
        get
        {
            return myColumnWidth11
        }
        set
        {
            myColumnWidth11 = newValue
        }
    }
    
    var columnWidth12: Int
    {
        get
        {
            return myColumnWidth12
        }
        set
        {
            myColumnWidth12 = newValue
        }
    }
    
    var columnWidth13: Int
    {
        get
        {
            return myColumnWidth13
        }
        set
        {
            myColumnWidth13 = newValue
        }
    }
    
    var columnWidth14: Int
    {
        get
        {
            return myColumnWidth14
        }
        set
        {
            myColumnWidth14 = newValue
        }
    }
    
    var rowHeight: Int
    {
        get
        {
            return myRowHeight
        }
        set
        {
            myRowHeight = newValue
        }
    }
    
    var reportName: String
    {
        get
        {
            return myReportName
        }
        set
        {
            myReportName = newValue
        }
    }
    
    var subject: String
    {
        get
        {
            return mySubject
        }
        set
        {
            mySubject = newValue
        }
    }
    
    var header: reportLine
    {
        get
        {
            return myHeader
        }
        set
        {
            myHeader = newValue
        }
    }
    
    var lines: [reportLine]
    {
        get
        {
            return myLines
        }
    }
    
    var count: Int
    {
        get
        {
            return myLines.count
        }
    }
    
    var activityController: UIActivityViewController
    {
        createPDF()
        createDisplayString()
        
        let printController = UIPrintInteractionController.shared
        // 2
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = .general
        printInfo.jobName = mySubject
        printController.printInfo = printInfo
//        printController.printingItem = myPdfData
        
        //let activityItems: [Any] = [printController, self, myPdfData]
        
        let sharingItem = reportShareSource(displayString: myDisplayString, PDFData: myPdfData)

        
        //let activityItems: [Any] = [printController, sharingItem]
        
    //    let activityItems: [Any] = [printController, myPdfData, sharingItem]
        
   let activityItems: [Any] = [sharingItem]
       
        
      //  let activityItems: [Any] = [myPdfData, myDisplayString]
        
        
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.setValue(mySubject, forKey: "Subject")
        activityViewController.excludedActivityTypes = shareExclutionArray
        
        return activityViewController
    }
    
    init(name: String)
    {
        myReportName = name
    }
    
    func removeAll()
    {
        myLines.removeAll()
    }
    
    func append(_ line: reportLine)
    {
        myLines.append(line)
    }
    
    func portrait()
    {
        paperSize = paperSizePortrait
        myPaperOrientation = "Portrait"
        disvisor = 2
    }
    
    func landscape()
    {
        paperSize = paperSizeLandscape
        myPaperOrientation = "Landscape"
        disvisor = 1.5
    }
    
    private func createPDF()
    {
        var topSide: Int = 50
        
        myPdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(myPdfData, .zero, nil)
        UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
        
        // report header
        
        if mySubject != ""
        {
            reportHeader(topSide, height: 40)
        }
        
        topSide += 5 + 40
        
        if myHeader != nil
        {
            pageHeader(topSide)
        }
        
        for myItem in myLines
        {
            topSide += 5 + myRowHeight
            
            if CGFloat(topSide) >= paperSize.height - 50  // We use the extra number to ensure that there is bottom margin
            {
                UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                if myHeader != nil
                {
                    topSide = 50
                    pageHeader(topSide)
                }
                
                topSide += 5 + myRowHeight
            }
            
            if myItem.drawLine
            {
                let trianglePath = UIBezierPath()
                trianglePath.move(to: CGPoint(x: 50, y: topSide))
                trianglePath.addLine(to: CGPoint(x: paperSize.width - 50, y: CGFloat(topSide)))
                
                myItem.lineColour.setStroke()
                trianglePath.stroke()                
                UIColor.black.setStroke()
            }
            else
            {
                lineEntry(myItem, top: topSide)
            }
        }
        
        UIGraphicsEndPDFContext()
    }
    
    private func createDisplayString()
    {
        myDisplayString = mySubject
        myDisplayString += "\n\n"
        
        if myHeader != nil
        {
            myDisplayString += displayLine(myHeader)
            myDisplayString += "\n\n"
        }
        
        for myEntry in myLines
        {
            myDisplayString += displayLine(myEntry)
            myDisplayString += "\n"
        }
    }
    
    private func displayLine(_ sourceLine: reportLine, delimiter: String = " ") -> String
    {
        var returnString: String = ""
                
        returnString += processStringCell(text: sourceLine.column1, width: myColumnWidth1, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column2, width: myColumnWidth2, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column3, width: myColumnWidth3, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column4, width: myColumnWidth4, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column5, width: myColumnWidth5, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column6, width: myColumnWidth6, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column7, width: myColumnWidth7, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column8, width: myColumnWidth8, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column9, width: myColumnWidth9, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column10, width: myColumnWidth10, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column11, width: myColumnWidth11, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column12, width: myColumnWidth12, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column13, width: myColumnWidth13, delimiter: delimiter)
        returnString += processStringCell(text: sourceLine.column14, width: myColumnWidth14, delimiter: "")
        returnString += "\n"
        
        return returnString
    }
    
    private func processStringCell(text: String, width: Int, delimiter: String) -> String
    {
        var returnString: String = ""
        
        if width > 0
        {
            returnString = "\(text)"
            returnString += "\(delimiter)"
        }
        
        return returnString
    }
    
    private func reportHeader(_ top: Int, height: Int)
    {
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let titleFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let headerRect = CGRect(
            x: 10,
            y: top,
            width: Int(paperSize.width),
            height: height)
        
        mySubject.draw(in: headerRect, withAttributes: titleFontAttributes)
    }
    
    private func pageHeader(_ top: Int)
    {
        leftSide = 50

        writePDFHeaderEntry(title: myHeader.column1, x: leftSide, y: top, width: myColumnWidth1, height: 20)
        writePDFHeaderEntry(title: myHeader.column2, x: leftSide, y: top, width: myColumnWidth2, height: 20)
        writePDFHeaderEntry(title: myHeader.column3, x: leftSide, y: top, width: myColumnWidth3, height: 20)
        writePDFHeaderEntry(title: myHeader.column4, x: leftSide, y: top, width: myColumnWidth4, height: 20)
        writePDFHeaderEntry(title: myHeader.column5, x: leftSide, y: top, width: myColumnWidth5, height: 20)
        writePDFHeaderEntry(title: myHeader.column6, x: leftSide, y: top, width: myColumnWidth6, height: 20)
        writePDFHeaderEntry(title: myHeader.column7, x: leftSide, y: top, width: myColumnWidth7, height: 20)
        writePDFHeaderEntry(title: myHeader.column8, x: leftSide, y: top, width: myColumnWidth8, height: 20)
        writePDFHeaderEntry(title: myHeader.column9, x: leftSide, y: top, width: myColumnWidth9, height: 20)
        writePDFHeaderEntry(title: myHeader.column10, x: leftSide, y: top, width: myColumnWidth10, height: 20)
        writePDFHeaderEntry(title: myHeader.column11, x: leftSide, y: top, width: myColumnWidth11, height: 20)
        writePDFHeaderEntry(title: myHeader.column12, x: leftSide, y: top, width: myColumnWidth12, height: 20)
        writePDFHeaderEntry(title: myHeader.column13, x: leftSide, y: top, width: myColumnWidth13, height: 20)
        writePDFHeaderEntry(title: myHeader.column14, x: leftSide, y: top, width: myColumnWidth14, height: 20)
    }
    
    private func lineEntry(_ line: reportLine, top: Int)
    {
        leftSide = 50
        
        writePDFEntry(title: line.column1, x: leftSide, y: top, width: myColumnWidth1, height: myRowHeight)
        writePDFEntry(title: line.column2, x: leftSide, y: top, width: myColumnWidth2, height: myRowHeight)
        writePDFEntry(title: line.column3, x: leftSide, y: top, width: myColumnWidth3, height: myRowHeight)
        writePDFEntry(title: line.column4, x: leftSide, y: top, width: myColumnWidth4, height: myRowHeight)
        writePDFEntry(title: line.column5, x: leftSide, y: top, width: myColumnWidth5, height: myRowHeight)
        writePDFEntry(title: line.column6, x: leftSide, y: top, width: myColumnWidth6, height: myRowHeight)
        writePDFEntry(title: line.column7, x: leftSide, y: top, width: myColumnWidth7, height: myRowHeight)
        writePDFEntry(title: line.column8, x: leftSide, y: top, width: myColumnWidth8, height: myRowHeight)
        writePDFEntry(title: line.column9, x: leftSide, y: top, width: myColumnWidth9, height: myRowHeight)
        writePDFEntry(title: line.column10, x: leftSide, y: top, width: myColumnWidth10, height: myRowHeight)
        writePDFEntry(title: line.column11, x: leftSide, y: top, width: myColumnWidth11, height: myRowHeight)
        writePDFHeaderEntry(title: line.column12, x: leftSide, y: top, width: myColumnWidth12, height: myRowHeight)
        writePDFHeaderEntry(title: line.column13, x: leftSide, y: top, width: myColumnWidth13, height: myRowHeight)
        writePDFHeaderEntry(title: line.column14, x: leftSide, y: top, width: myColumnWidth14, height: myRowHeight)
    }
    
    private func writePDFHeaderEntry(title: String, x: Int, y: Int, width: Int, height: Int)
    {
        let displayWidth = Double(width)/disvisor
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left
        
        let titleFontAttributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let headerRect = CGRect(
            x: x,
            y: y,
            width: Int(displayWidth),
            height: height)
        
        title.draw(in: headerRect, withAttributes: titleFontAttributes)
        
        leftSide += 5 + Int(displayWidth)
    }
    
    private func writePDFEntry(title: String, x: Int, y: Int, width: Int, height: Int)
    {
        let displayWidth = Double(width)/disvisor
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .left
        
        let dataFontAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 10),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: UIColor.black
        ]
        
        let headerRect = CGRect(
            x: x,
            y: y,
            width: Int(displayWidth),
            height: height)
        
        title.draw(in: headerRect, withAttributes: dataFontAttributes)
        
        leftSide += 5 + Int(displayWidth)
    }
}

class reportShareSource: UIActivityItemProvider
{
    fileprivate var myPDFData: NSMutableData!
    fileprivate var myDisplayString: String = ""
    
    init(displayString: String, PDFData: NSMutableData)
    {
        super.init(placeholderItem: PDFData)
        myPDFData = PDFData
        myDisplayString = displayString
    }
    
    override var item: Any
    {
        switch activityType!
        {
            case UIActivityType.addToReadingList,
                 UIActivityType.airDrop,
                 UIActivityType.assignToContact,
                 UIActivityType.mail,
                 UIActivityType.openInIBooks,
                 UIActivityType.postToFlickr,
                 UIActivityType.postToVimeo,
                 UIActivityType.print,
                 UIActivityType.saveToCameraRoll:
                return myPDFData

            case UIActivityType.copyToPasteboard,
                 UIActivityType.message,
                 UIActivityType.postToFacebook,
                 UIActivityType.postToTencentWeibo,
                 UIActivityType.postToTwitter:
                return myDisplayString
                
            default:
                return myPDFData
        }
    }
}


class reportLine: NSObject
{
    fileprivate var myColumn1: String = ""
    fileprivate var myColumn2: String = ""
    fileprivate var myColumn3: String = ""
    fileprivate var myColumn4: String = ""
    fileprivate var myColumn5: String = ""
    fileprivate var myColumn6: String = ""
    fileprivate var myColumn7: String = ""
    fileprivate var myColumn8: String = ""
    fileprivate var myColumn9: String = ""
    fileprivate var myColumn10: String = ""
    fileprivate var myColumn11: String = ""
    fileprivate var myColumn12: String = ""
    fileprivate var myColumn13: String = ""
    fileprivate var myColumn14: String = ""
    fileprivate var mySourceObject: Any!
    fileprivate var myDrawLine: Bool = false
    fileprivate var myLineColour: UIColor = UIColor.black

    var column1: String
    {
        get
        {
            return myColumn1
        }
        set
        {
            myColumn1 = newValue
        }
    }
    
    var column2: String
    {
        get
        {
            return myColumn2
        }
        set
        {
            myColumn2 = newValue
        }
    }
    
    var column3: String
    {
        get
        {
            return myColumn3
        }
        set
        {
            myColumn3 = newValue
        }
    }
    
    var column4: String
    {
        get
        {
            return myColumn4
        }
        set
        {
            myColumn4 = newValue
        }
    }
    
    var column5: String
    {
        get
        {
            return myColumn5
        }
        set
        {
            myColumn5 = newValue
        }
    }
    
    var column6: String
    {
        get
        {
            return myColumn6
        }
        set
        {
            myColumn6 = newValue
        }
    }
    
    var column7: String
    {
        get
        {
            return myColumn7
        }
        set
        {
            myColumn7 = newValue
        }
    }
    
    var column8: String
    {
        get
        {
            return myColumn8
        }
        set
        {
            myColumn8 = newValue
        }
    }
    
    var column9: String
    {
        get
        {
            return myColumn9
        }
        set
        {
            myColumn9 = newValue
        }
    }
    
    var column10: String
    {
        get
        {
            return myColumn10
        }
        set
        {
            myColumn10 = newValue
        }
    }
    
    var column11: String
    {
        get
        {
            return myColumn11
        }
        set
        {
            myColumn11 = newValue
        }
    }
    
    var column12: String
    {
        get
        {
            return myColumn12
        }
        set
        {
            myColumn12 = newValue
        }
    }
    
    var column13: String
    {
        get
        {
            return myColumn13
        }
        set
        {
            myColumn13 = newValue
        }
    }
    
    var column14: String
    {
        get
        {
            return myColumn14
        }
        set
        {
            myColumn14 = newValue
        }
    }
    
    var sourceObject: Any
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
    
    var drawLine: Bool
    {
        get
        {
            return myDrawLine
        }
        set
        {
            myDrawLine = newValue
        }
    }
    
    var lineColour: UIColor
    {
        get
        {
            return myLineColour
        }
        set
        {
            myLineColour = newValue
        }
    }
}
