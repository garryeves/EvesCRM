//
//  reporting.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 3/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit

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
    fileprivate var mySubject: String = ""
    fileprivate let paperSizePortrait = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate let paperSizeLandscape = CGRect(x:0.0, y:0.0, width:841.89, height:595.276)
    fileprivate var paperSize: CGRect!
    fileprivate var myPaperOrientation: String = ""
    
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
    
    var name: String
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
    
    var PDF: NSMutableData?
    {
        get
        {
            return myPdfData
        }
    }
    
    override init()
    {
        super.init()
        
        paperSize = paperSizePortrait
        myPaperOrientation = "Portrait"
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
    }
    
    func landscape()
    {
        paperSize = paperSizeLandscape
        myPaperOrientation = "Landscape"
    }
    
    func createPDF()
    {
        var topSide: Int = 10
        
        myPdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(myPdfData, .zero, nil)
        UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
        
        // report header
        
        if myReportName != ""
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
            
            if CGFloat(topSide) >= paperSize.height
            {
                UIGraphicsBeginPDFPageWithInfo(paperSize, nil)
                if myHeader != nil
                {
                    pageHeader(10)
                    
                    topSide = 10
                }
                
                topSide += 5 + myRowHeight
            }
            
            if myItem.drawLine
            {
                let trianglePath = UIBezierPath()
                trianglePath.move(to: CGPoint(x: 10, y: topSide))
                trianglePath.addLine(to: CGPoint(x: paperSize.width - 10, y: CGFloat(topSide)))
                
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
        
        myReportName.draw(in: headerRect, withAttributes: titleFontAttributes)
    }
    
    private func pageHeader(_ top: Int)
    {
        var leftSide: Int = 10
        
        writePDFHeaderEntry(title: myHeader.column1, x: leftSide, y: top, width: myColumnWidth1, height: 20)
        leftSide += 5 + myColumnWidth1
        
        writePDFHeaderEntry(title: myHeader.column2, x: leftSide, y: top, width: myColumnWidth2, height: 20)
        leftSide += 5 + myColumnWidth2
        
        writePDFHeaderEntry(title: myHeader.column3, x: leftSide, y: top, width: myColumnWidth3, height: 20)
        leftSide += 5 + myColumnWidth3
        
        writePDFHeaderEntry(title: myHeader.column4, x: leftSide, y: top, width: myColumnWidth4, height: 20)
        leftSide += 5 + myColumnWidth4
        
        writePDFHeaderEntry(title: myHeader.column5, x: leftSide, y: top, width: myColumnWidth5, height: 20)
        leftSide += 5 + myColumnWidth5
        
        writePDFHeaderEntry(title: myHeader.column6, x: leftSide, y: top, width: myColumnWidth6, height: 20)
        leftSide += 5 + myColumnWidth6
        
        writePDFHeaderEntry(title: myHeader.column7, x: leftSide, y: top, width: myColumnWidth7, height: 20)
        leftSide += 5 + myColumnWidth7
        
        writePDFHeaderEntry(title: myHeader.column8, x: leftSide, y: top, width: myColumnWidth8, height: 20)
        leftSide += 5 + myColumnWidth8
        
        writePDFHeaderEntry(title: myHeader.column9, x: leftSide, y: top, width: myColumnWidth9, height: 20)
        leftSide += 5 + myColumnWidth9
        
        writePDFHeaderEntry(title: myHeader.column10, x: leftSide, y: top, width: myColumnWidth10, height: 20)
        leftSide += 5 + myColumnWidth10
        
        writePDFHeaderEntry(title: myHeader.column11, x: leftSide, y: top, width: myColumnWidth11, height: 20)
        leftSide += 5 + myColumnWidth11
        
        writePDFHeaderEntry(title: myHeader.column12, x: leftSide, y: top, width: myColumnWidth12, height: 20)
        leftSide += 5 + myColumnWidth12
        
        writePDFHeaderEntry(title: myHeader.column13, x: leftSide, y: top, width: myColumnWidth13, height: 20)
        leftSide += 5 + myColumnWidth13
        
        writePDFHeaderEntry(title: myHeader.column14, x: leftSide, y: top, width: myColumnWidth14, height: 20)
        leftSide += 5 + myColumnWidth14
    }
    
    private func lineEntry(_ line: reportLine, top: Int)
    {
        var leftSide: Int = 10
        
        writePDFEntry(title: line.column1, x: leftSide, y: top, width: myColumnWidth1, height: myRowHeight)
        leftSide += 5 + myColumnWidth1
        
        writePDFEntry(title: line.column2, x: leftSide, y: top, width: myColumnWidth2, height: myRowHeight)
        leftSide += 5 + myColumnWidth2
        
        writePDFEntry(title: line.column3, x: leftSide, y: top, width: myColumnWidth3, height: myRowHeight)
        leftSide += 5 + myColumnWidth3
        
        writePDFEntry(title: line.column4, x: leftSide, y: top, width: myColumnWidth4, height: myRowHeight)
        leftSide += 5 + myColumnWidth4
        
        writePDFEntry(title: line.column5, x: leftSide, y: top, width: myColumnWidth5, height: myRowHeight)
        leftSide += 5 + myColumnWidth5
        
        writePDFEntry(title: line.column6, x: leftSide, y: top, width: myColumnWidth6, height: myRowHeight)
        leftSide += 5 + myColumnWidth6
        
        writePDFEntry(title: line.column7, x: leftSide, y: top, width: myColumnWidth7, height: myRowHeight)
        leftSide += 5 + myColumnWidth7
        
        writePDFEntry(title: line.column8, x: leftSide, y: top, width: myColumnWidth8, height: myRowHeight)
        leftSide += 5 + myColumnWidth8
        
        writePDFEntry(title: line.column9, x: leftSide, y: top, width: myColumnWidth9, height: myRowHeight)
        leftSide += 5 + myColumnWidth9
        
        writePDFEntry(title: line.column10, x: leftSide, y: top, width: myColumnWidth10, height: myRowHeight)
        leftSide += 5 + myColumnWidth10
        
        writePDFEntry(title: line.column11, x: leftSide, y: top, width: myColumnWidth11, height: myRowHeight)
        leftSide += 5 + myColumnWidth11
        
        writePDFHeaderEntry(title: line.column12, x: leftSide, y: top, width: myColumnWidth12, height: myRowHeight)
        leftSide += 5 + myColumnWidth12
        
        writePDFHeaderEntry(title: line.column13, x: leftSide, y: top, width: myColumnWidth13, height: myRowHeight)
        leftSide += 5 + myColumnWidth13
        
        writePDFHeaderEntry(title: line.column14, x: leftSide, y: top, width: myColumnWidth14, height: myRowHeight)
        leftSide += 5 + myColumnWidth14
    }
    
    private func writePDFHeaderEntry(title: String, x: Int, y: Int, width: Int, height: Int)
    {
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
            width: width,
            height: height)
        
        title.draw(in: headerRect, withAttributes: titleFontAttributes)
    }
    
    private func writePDFEntry(title: String, x: Int, y: Int, width: Int, height: Int)
    {
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
            width: width,
            height: height)
        
        title.draw(in: headerRect, withAttributes: dataFontAttributes)
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
