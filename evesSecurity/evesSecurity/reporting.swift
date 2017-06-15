//
//  reporting.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 3/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

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
    
    init(reportType: String)
    {
        super.init()
        
        for myReport in myDatabaseConnection.getReports(teamID: currentUser.currentTeam!.teamID, reportType: reportType)
        {
            let reportInstance = report(reportID: Int(myReport.reportID),
                                        reportTitle: myReport.reportTitle!,
                                        reportDescription: myReport.reportDescription!,
                                        reportType: myReport.reportType!,
                                        systemReport: myReport.systemReport,
                                        teamID: Int(myReport.teamID),
                                        orientation: myReport.orientation!,
                                        columnTitle1: myReport.columnTitle1!,
                                        columnSource1: myReport.columnSource1!,
                                        columnWidth1: myReport.columnWidth1,
                                        columnTitle2: myReport.columnTitle2!,
                                        columnSource2: myReport.columnSource2!,
                                        columnWidth2: myReport.columnWidth2,
                                        columnTitle3: myReport.columnTitle3!,
                                        columnSource3: myReport.columnSource3!,
                                        columnWidth3: myReport.columnWidth3,
                                        columnTitle4: myReport.columnTitle4!,
                                        columnSource4: myReport.columnSource4!,
                                        columnWidth4: myReport.columnWidth4,
                                        columnTitle5: myReport.columnTitle5!,
                                        columnSource5: myReport.columnSource5!,
                                        columnWidth5: myReport.columnWidth5,
                                        columnTitle6: myReport.columnTitle6!,
                                        columnSource6: myReport.columnSource6!,
                                        columnWidth6: myReport.columnWidth6,
                                        columnTitle7: myReport.columnTitle7!,
                                        columnSource7: myReport.columnSource7!,
                                        columnWidth7: myReport.columnWidth7,
                                        columnTitle8: myReport.columnTitle8!,
                                        columnSource8: myReport.columnSource8!,
                                        columnWidth8: myReport.columnWidth8,
                                        columnTitle9: myReport.columnTitle9!,
                                        columnSource9: myReport.columnSource9!,
                                        columnWidth9: myReport.columnWidth9,
                                        columnTitle10: myReport.columnTitle10!,
                                        columnSource10: myReport.columnSource10!,
                                        columnWidth10: myReport.columnWidth10,
                                        columnTitle11: myReport.columnTitle11!,
                                        columnSource11: myReport.columnSource11!,
                                        columnWidth11: myReport.columnWidth11,
                                        columnTitle12: myReport.columnTitle12!,
                                        columnSource12: myReport.columnSource12!,
                                        columnWidth12: myReport.columnWidth12,
                                        columnTitle13: myReport.columnTitle13!,
                                        columnSource13: myReport.columnSource13!,
                                        columnWidth13: myReport.columnWidth13,
                                        columnWidth14: myReport.columnWidth14,
                                        columnTitle14: myReport.columnTitle14!,
                                        columnSource14: myReport.columnSource14!,
                                        selectionCriteria1: myReport.selectionCriteria1!,
                                        selectionCriteria2: myReport.selectionCriteria2!,
                                        selectionCriteria3: myReport.selectionCriteria3!,
                                        selectionCriteria4: myReport.selectionCriteria4!,
                                        sortOrder1: myReport.sortOrder1!,
                                        sortOrder2: myReport.sortOrder2!,
                                        sortOrder3: myReport.sortOrder3!,
                                        sortOrder4: myReport.sortOrder4!)
            
                myReports.append(reportInstance)
        }
    }
    
    init(teamID: Int)
    {
        super.init()
        
        for myReport in myDatabaseConnection.getReports(teamID: currentUser.currentTeam!.teamID)
        {
            let reportInstance = report(reportID: Int(myReport.reportID),
                                        reportTitle: myReport.reportTitle!,
                                        reportDescription: myReport.reportDescription!,
                                        reportType: myReport.reportType!,
                                        systemReport: myReport.systemReport,
                                        teamID: Int(myReport.teamID),
                                        orientation: myReport.orientation!,
                                        columnTitle1: myReport.columnTitle1!,
                                        columnSource1: myReport.columnSource1!,
                                        columnWidth1: myReport.columnWidth1,
                                        columnTitle2: myReport.columnTitle2!,
                                        columnSource2: myReport.columnSource2!,
                                        columnWidth2: myReport.columnWidth2,
                                        columnTitle3: myReport.columnTitle3!,
                                        columnSource3: myReport.columnSource3!,
                                        columnWidth3: myReport.columnWidth3,
                                        columnTitle4: myReport.columnTitle4!,
                                        columnSource4: myReport.columnSource4!,
                                        columnWidth4: myReport.columnWidth4,
                                        columnTitle5: myReport.columnTitle5!,
                                        columnSource5: myReport.columnSource5!,
                                        columnWidth5: myReport.columnWidth5,
                                        columnTitle6: myReport.columnTitle6!,
                                        columnSource6: myReport.columnSource6!,
                                        columnWidth6: myReport.columnWidth6,
                                        columnTitle7: myReport.columnTitle7!,
                                        columnSource7: myReport.columnSource7!,
                                        columnWidth7: myReport.columnWidth7,
                                        columnTitle8: myReport.columnTitle8!,
                                        columnSource8: myReport.columnSource8!,
                                        columnWidth8: myReport.columnWidth8,
                                        columnTitle9: myReport.columnTitle9!,
                                        columnSource9: myReport.columnSource9!,
                                        columnWidth9: myReport.columnWidth9,
                                        columnTitle10: myReport.columnTitle10!,
                                        columnSource10: myReport.columnSource10!,
                                        columnWidth10: myReport.columnWidth10,
                                        columnTitle11: myReport.columnTitle11!,
                                        columnSource11: myReport.columnSource11!,
                                        columnWidth11: myReport.columnWidth11,
                                        columnTitle12: myReport.columnTitle12!,
                                        columnSource12: myReport.columnSource12!,
                                        columnWidth12: myReport.columnWidth12,
                                        columnTitle13: myReport.columnTitle13!,
                                        columnSource13: myReport.columnSource13!,
                                        columnWidth13: myReport.columnWidth13,
                                        columnWidth14: myReport.columnWidth14,
                                        columnTitle14: myReport.columnTitle14!,
                                        columnSource14: myReport.columnSource14!,
                                        selectionCriteria1: myReport.selectionCriteria1!,
                                        selectionCriteria2: myReport.selectionCriteria2!,
                                        selectionCriteria3: myReport.selectionCriteria3!,
                                        selectionCriteria4: myReport.selectionCriteria4!,
                                        sortOrder1: myReport.sortOrder1!,
                                        sortOrder2: myReport.sortOrder2!,
                                        sortOrder3: myReport.sortOrder3!,
                                        sortOrder4: myReport.sortOrder4!)
            
            myReports.append(reportInstance)
        }
        
        if myReports.count > 1
        {
            myReports.sort
            {
                if $0.reportType == $1.reportType
                {
                    return $0.reportName < $1.reportName
                }
                else
                {
                    return $0.reportType < $1.reportType
                }
            }
        }
    }
    
    var reports: [report]
    {
        get
        {
            return myReports
        }
    }
//    
//    func append(_ reportItem: report)
//    {
//        myReports.append(reportItem)
//    }
//    
//    func removeAll()
//    {
//        myReports.removeAll()
//    }
}

class report: NSObject
{
    fileprivate var myColumnWidth1: CGFloat = 0.0
    fileprivate var myColumnWidth2: CGFloat = 0.0
    fileprivate var myColumnWidth3: CGFloat = 0.0
    fileprivate var myColumnWidth4: CGFloat = 0.0
    fileprivate var myColumnWidth5: CGFloat = 0.0
    fileprivate var myColumnWidth6: CGFloat = 0.0
    fileprivate var myColumnWidth7: CGFloat = 0.0
    fileprivate var myColumnWidth8: CGFloat = 0.0
    fileprivate var myColumnWidth9: CGFloat = 0.0
    fileprivate var myColumnWidth10: CGFloat = 0.0
    fileprivate var myColumnWidth11: CGFloat = 0.0
    fileprivate var myColumnWidth12: CGFloat = 0.0
    fileprivate var myColumnWidth13: CGFloat = 0.0
    fileprivate var myColumnWidth14: CGFloat = 0.0
    fileprivate var myColumnTitle1: String = ""
    fileprivate var myColumnTitle2: String = ""
    fileprivate var myColumnTitle3: String = ""
    fileprivate var myColumnTitle4: String = ""
    fileprivate var myColumnTitle5: String = ""
    fileprivate var myColumnTitle6: String = ""
    fileprivate var myColumnTitle7: String = ""
    fileprivate var myColumnTitle8: String = ""
    fileprivate var myColumnTitle9: String = ""
    fileprivate var myColumnTitle10: String = ""
    fileprivate var myColumnTitle11: String = ""
    fileprivate var myColumnTitle12: String = ""
    fileprivate var myColumnTitle13: String = ""
    fileprivate var myColumnTitle14: String = ""
    fileprivate var myColumnSource1: String = ""
    fileprivate var myColumnSource2: String = ""
    fileprivate var myColumnSource3: String = ""
    fileprivate var myColumnSource4: String = ""
    fileprivate var myColumnSource5: String = ""
    fileprivate var myColumnSource6: String = ""
    fileprivate var myColumnSource7: String = ""
    fileprivate var myColumnSource8: String = ""
    fileprivate var myColumnSource9: String = ""
    fileprivate var myColumnSource10: String = ""
    fileprivate var myColumnSource11: String = ""
    fileprivate var myColumnSource12: String = ""
    fileprivate var myColumnSource13: String = ""
    fileprivate var myColumnSource14: String = ""
    fileprivate var mySelectionCriteria1: String = ""
    fileprivate var mySelectionCriteria2: String = ""
    fileprivate var mySelectionCriteria3: String = ""
    fileprivate var mySelectionCriteria4: String = ""
    fileprivate var mySortOrder1: String = ""
    fileprivate var mySortOrder2: String = ""
    fileprivate var mySortOrder3: String = ""
    fileprivate var mySortOrder4: String = ""
    fileprivate var myReportType: String = ""
    fileprivate var myReportID: Int = 0
    fileprivate var mySystemReport: Bool = false
    fileprivate var myRowHeight: Int = 12
    fileprivate var myReportName: String = ""
    fileprivate var myHeader: reportLine!
    var myLines: [reportLine] = Array()
    fileprivate var myPdfData: NSMutableData!
    fileprivate var myDisplayString: String = ""
    fileprivate var mySubject: String = ""
    fileprivate let paperSizePortrait = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate let paperSizeLandscape = CGRect(x:0.0, y:0.0, width:841.89, height:595.276)
    fileprivate var paperSize = CGRect(x:0.0, y:0.0, width:595.276, height:841.89)
    fileprivate var myPaperOrientation: String = "Portrait"
    fileprivate var disvisor: Double = 2
    fileprivate var leftSide: CGFloat = 50
    fileprivate var myDisplayWidth: CGFloat = 0.0
    fileprivate var myTeamID: Int = 0
    
    var columnWidth1: CGFloat
    {
        get
        {
            if myColumnWidth1 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth1 / 100)
            }
        }
        set
        {
            myColumnWidth1 = newValue
        }
    }
    
    var columnWidth2: CGFloat
    {
        get
        {
            if myColumnWidth2 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth2 / 100)
            }
        }
        set
        {
            myColumnWidth2 = newValue
        }
    }
    
    var columnWidth3: CGFloat
    {
        get
        {
            if myColumnWidth3 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth3 / 100)
            }
        }
        set
        {
            myColumnWidth3 = newValue
        }
    }
    
    var columnWidth4: CGFloat
    {
        get
        {
            if myColumnWidth4 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth4 / 100)
            }
        }
        set
        {
            myColumnWidth4 = newValue
        }
    }
    
    var columnWidth5: CGFloat
    {
        get
        {
            if myColumnWidth5 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth5 / 100)
            }
        }
        set
        {
            myColumnWidth5 = newValue
        }
    }
    
    var columnWidth6: CGFloat
    {
        get
        {
            if myColumnWidth6 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth6 / 100)
            }
        }
        set
        {
            myColumnWidth6 = newValue
        }
    }
    
    var columnWidth7: CGFloat
    {
        get
        {
            if myColumnWidth7 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth7 / 100)
            }
        }
        set
        {
            myColumnWidth7 = newValue
        }
    }
    
    var columnWidth8: CGFloat
    {
        get
        {
            if myColumnWidth8 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth8 / 100)
            }
        }
        set
        {
            myColumnWidth8 = newValue
        }
    }
    
    var columnWidth9: CGFloat
    {
        get
        {
            if myColumnWidth9 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth9 / 100)
            }
        }
        set
        {
            myColumnWidth9 = newValue
        }
    }
    
    var columnWidth10: CGFloat
    {
        get
        {
            if myColumnWidth10 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth10 / 100)
            }
        }
        set
        {
            myColumnWidth10 = newValue
        }
    }
    
    var columnWidth11: CGFloat
    {
        get
        {
            if myColumnWidth11 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth11 / 100)
            }
        }
        set
        {
            myColumnWidth11 = newValue
        }
    }
    
    var columnWidth12: CGFloat
    {
        get
        {
            if myColumnWidth12 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth12 / 100)
            }
        }
        set
        {
            myColumnWidth12 = newValue
        }
    }
    
    var columnWidth13: CGFloat
    {
        get
        {
            if myColumnWidth13 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth13 / 100)
            }
        }
        set
        {
            myColumnWidth13 = newValue
        }
    }
    
    var columnWidth14: CGFloat
    {
        get
        {
            if myColumnWidth14 == 0.0
            {
                return 0.0
            }
            else
            {
                return myDisplayWidth * (myColumnWidth14 / 100)
            }
        }
        set
        {
            myColumnWidth14 = newValue
        }
    }

    var columnTitle1: String
    {
        get
        {
            return myColumnTitle1
        }
        set
        {
            myColumnTitle1 = newValue
        }
    }
    
    var columnTitle2: String
    {
        get
        {
            return myColumnTitle2
        }
        set
        {
            myColumnTitle2 = newValue
        }
    }
    
    var columnTitle3: String
    {
        get
        {
            return myColumnTitle3
        }
        set
        {
            myColumnTitle3 = newValue
        }
    }
    
    var columnTitle4: String
    {
        get
        {
            return myColumnTitle4
        }
        set
        {
            myColumnTitle4 = newValue
        }
    }
    
    var columnTitle5: String
    {
        get
        {
            return myColumnTitle5
        }
        set
        {
            myColumnTitle5 = newValue
        }
    }
    
    var columnTitle6: String
    {
        get
        {
            return myColumnTitle6
        }
        set
        {
            myColumnTitle6 = newValue
        }
    }
    
    var columnTitle7: String
    {
        get
        {
            return myColumnTitle7
        }
        set
        {
            myColumnTitle7 = newValue
        }
    }
    
    var columnTitle8: String
    {
        get
        {
            return myColumnTitle8
        }
        set
        {
            myColumnTitle8 = newValue
        }
    }
    
    var columnTitle9: String
    {
        get
        {
            return myColumnTitle9
        }
        set
        {
            myColumnTitle9 = newValue
        }
    }
    
    var columnTitle10: String
    {
        get
        {
            return myColumnTitle10
        }
        set
        {
            myColumnTitle10 = newValue
        }
    }
    
    var columnTitle11: String
    {
        get
        {
            return myColumnTitle11
        }
        set
        {
            myColumnTitle11 = newValue
        }
    }
    
    var columnTitle12: String
    {
        get
        {
            return myColumnTitle12
        }
        set
        {
            myColumnTitle12 = newValue
        }
    }
    
    var columnTitle13: String
    {
        get
        {
            return myColumnTitle13
        }
        set
        {
            myColumnTitle13 = newValue
        }
    }
    
    var columnTitle14: String
    {
        get
        {
            return myColumnTitle14
        }
        set
        {
            myColumnTitle14 = newValue
        }
    }

    var columnSource1: String
    {
        get
        {
            return myColumnSource1
        }
        set
        {
            myColumnSource1 = newValue
        }
    }
    
    var columnSource2: String
    {
        get
        {
            return myColumnSource2
        }
        set
        {
            myColumnSource2 = newValue
        }
    }
    
    var columnSource3: String
    {
        get
        {
            return myColumnSource3
        }
        set
        {
            myColumnSource3 = newValue
        }
    }
    
    var columnSource4: String
    {
        get
        {
            return myColumnSource4
        }
        set
        {
            myColumnSource4 = newValue
        }
    }
    
    var columnSource5: String
    {
        get
        {
            return myColumnSource5
        }
        set
        {
            myColumnSource5 = newValue
        }
    }
    
    var columnSource6: String
    {
        get
        {
            return myColumnSource6
        }
        set
        {
            myColumnSource6 = newValue
        }
    }
    
    var columnSource7: String
    {
        get
        {
            return myColumnSource7
        }
        set
        {
            myColumnSource7 = newValue
        }
    }
    
    var columnSource8: String
    {
        get
        {
            return myColumnSource8
        }
        set
        {
            myColumnSource8 = newValue
        }
    }
    
    var columnSource9: String
    {
        get
        {
            return myColumnSource9
        }
        set
        {
            myColumnSource9 = newValue
        }
    }
    
    var columnSource10: String
    {
        get
        {
            return myColumnSource10
        }
        set
        {
            myColumnSource10 = newValue
        }
    }
    
    var columnSource11: String
    {
        get
        {
            return myColumnSource11
        }
        set
        {
            myColumnSource11 = newValue
        }
    }
    
    var columnSource12: String
    {
        get
        {
            return myColumnSource12
        }
        set
        {
            myColumnSource12 = newValue
        }
    }
    
    var columnSource13: String
    {
        get
        {
            return myColumnSource13
        }
        set
        {
            myColumnSource13 = newValue
        }
    }
    
    var columnSource14: String
    {
        get
        {
            return myColumnSource14
        }
        set
        {
            myColumnSource14 = newValue
        }
    }
    
    var selectionCriteria1: String
    {
        get
        {
            return mySelectionCriteria1
        }
        set
        {
            mySelectionCriteria1 = newValue
        }
    }
    
    var selectionCriteria2: String
    {
        get
        {
            return mySelectionCriteria2
        }
        set
        {
            mySelectionCriteria2 = newValue
        }
    }
    
    var selectionCriteria3: String
    {
        get
        {
            return mySelectionCriteria3
        }
        set
        {
            mySelectionCriteria3 = newValue
        }
    }
    
    var selectionCriteria4: String
    {
        get
        {
            return mySelectionCriteria4
        }
        set
        {
            mySelectionCriteria4 = newValue
        }
    }

    var sortOrder1: String
    {
        get
        {
            return mySortOrder1
        }
        set
        {
            mySortOrder1 = newValue
        }
    }

    var sortOrder2: String
    {
        get
        {
            return mySortOrder2
        }
        set
        {
            mySortOrder2 = newValue
        }
    }

    var sortOrder3: String
    {
        get
        {
            return mySortOrder3
        }
        set
        {
            mySortOrder3 = newValue
        }
    }

    var sortOrder4: String
    {
        get
        {
            return mySortOrder4
        }
        set
        {
            mySortOrder4 = newValue
        }
    }

    var reportType: String
    {
        get
        {
            return myReportType
        }
        set
        {
            myReportType = newValue
        }
    }

    var reportID: Int
    {
        get
        {
            return myReportID
        }
    }
    
    var systemReport: Bool
    {
        get
        {
            return mySystemReport
        }
        set
        {
            mySystemReport = newValue
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
        
        let sharingItem = reportShareSource(displayString: myDisplayString, PDFData: myPdfData)
        
        let activityItems: [Any] = [sharingItem]
        
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.setValue(mySubject, forKey: "Subject")
        activityViewController.excludedActivityTypes = shareExclutionArray
        
        return activityViewController
    }
    
    var displayWidth: CGFloat
    {
        get
        {
            return myDisplayWidth
        }
        set
        {
            myDisplayWidth = newValue
        }
    }
    
    init(teamID: Int)
    {
        myTeamID = teamID
        myReportID = myDatabaseConnection.getNextID("Reports")
        
    }
    
    init(reportID: Int)
    {
        super.init()
        
        for myRecord in myDatabaseConnection.getReportDetails(reportID)
        {
            myReportID = Int(myRecord.reportID)
            myReportName = myRecord.reportTitle!
            myReportName = myRecord.reportDescription!
            myReportType = myRecord.reportType!
            mySystemReport = myRecord.systemReport
            myTeamID = Int(myRecord.teamID)
            myPaperOrientation = myRecord.orientation!
            myColumnTitle1 = myRecord.columnTitle1!
            myColumnSource1 = myRecord.columnSource1!
            myColumnWidth1 = CGFloat(myRecord.columnWidth1)
            myColumnTitle2 = myRecord.columnTitle2!
            myColumnSource2 = myRecord.columnSource2!
            myColumnWidth2 = CGFloat(myRecord.columnWidth2)
            myColumnTitle3 = myRecord.columnTitle3!
            myColumnSource3 = myRecord.columnSource3!
            myColumnWidth3 = CGFloat(myRecord.columnWidth3)
            myColumnTitle4 = myRecord.columnTitle4!
            myColumnSource4 = myRecord.columnSource4!
            myColumnWidth4 = CGFloat(myRecord.columnWidth4)
            myColumnTitle5 = myRecord.columnTitle5!
            myColumnSource5 = myRecord.columnSource5!
            myColumnWidth5 = CGFloat(myRecord.columnWidth5)
            myColumnTitle6 = myRecord.columnTitle6!
            myColumnSource6 = myRecord.columnSource6!
            myColumnWidth6 = CGFloat(myRecord.columnWidth6)
            myColumnTitle7 = myRecord.columnTitle7!
            myColumnSource7 = myRecord.columnSource7!
            myColumnWidth7 = CGFloat(myRecord.columnWidth7)
            myColumnTitle8 = myRecord.columnTitle8!
            myColumnSource8 = myRecord.columnSource8!
            myColumnWidth8 = CGFloat(myRecord.columnWidth8)
            myColumnTitle9 = myRecord.columnTitle9!
            myColumnSource9 = myRecord.columnSource9!
            myColumnWidth9 = CGFloat(myRecord.columnWidth9)
            myColumnTitle10 = myRecord.columnTitle10!
            myColumnSource10 = myRecord.columnSource10!
            myColumnWidth10 = CGFloat(myRecord.columnWidth10)
            myColumnTitle11 = myRecord.columnTitle11!
            myColumnSource11 = myRecord.columnSource11!
            myColumnWidth11 = CGFloat(myRecord.columnWidth11)
            myColumnTitle12 = myRecord.columnTitle12!
            myColumnSource12 = myRecord.columnSource12!
            myColumnWidth12 = CGFloat(myRecord.columnWidth12)
            myColumnTitle13 = myRecord.columnTitle13!
            myColumnSource13 = myRecord.columnSource13!
            myColumnWidth13 = CGFloat(myRecord.columnWidth13)
            myColumnWidth14 = CGFloat(myRecord.columnWidth14)
            myColumnTitle14 = myRecord.columnTitle14!
            myColumnSource14 = myRecord.columnSource14!
            mySelectionCriteria1 = myRecord.selectionCriteria1!
            mySelectionCriteria2 = myRecord.selectionCriteria2!
            mySelectionCriteria3 = myRecord.selectionCriteria3!
            mySelectionCriteria4 = myRecord.selectionCriteria4!
            mySortOrder1 = myRecord.sortOrder1!
            mySortOrder2 = myRecord.sortOrder2!
            mySortOrder3 = myRecord.sortOrder3!
            mySortOrder4 = myRecord.sortOrder4!
            
            if myPaperOrientation == "Landscape"
            {
                paperSize = paperSizeLandscape
            }
            else
            {
                paperSize = paperSizePortrait
            }
            
            createHeader()

        }
    }
    
    init(name: String)
    {
        myReportName = name
    }

    init( reportID: Int,
            reportTitle: String,
            reportDescription: String,
            reportType: String,
            systemReport: Bool,
            teamID: Int,
            orientation: String,
            columnTitle1: String,
            columnSource1: String,
            columnWidth1: Double,
            columnTitle2: String,
            columnSource2: String,
            columnWidth2: Double,
            columnTitle3: String,
            columnSource3: String,
            columnWidth3: Double,
            columnTitle4: String,
            columnSource4: String,
            columnWidth4: Double,
            columnTitle5: String,
            columnSource5: String,
            columnWidth5: Double,
            columnTitle6: String,
            columnSource6: String,
            columnWidth6: Double,
            columnTitle7: String,
            columnSource7: String,
            columnWidth7: Double,
            columnTitle8: String,
            columnSource8: String,
            columnWidth8: Double,
            columnTitle9: String,
            columnSource9: String,
            columnWidth9: Double,
            columnTitle10: String,
            columnSource10: String,
            columnWidth10: Double,
            columnTitle11: String,
            columnSource11: String,
            columnWidth11: Double,
            columnTitle12: String,
            columnSource12: String,
            columnWidth12: Double,
            columnTitle13: String,
            columnSource13: String,
            columnWidth13: Double,
            columnWidth14: Double,
            columnTitle14: String,
            columnSource14: String,
            selectionCriteria1: String,
            selectionCriteria2: String,
            selectionCriteria3: String,
            selectionCriteria4: String,
            sortOrder1: String,
            sortOrder2: String,
            sortOrder3: String,
            sortOrder4: String)
    {
        super.init()
        
        myReportID = reportID
        myReportName = reportTitle
        myReportName = reportDescription
        myReportType = reportType
        mySystemReport = systemReport
        myTeamID = teamID
        myPaperOrientation = orientation
        myColumnTitle1 = columnTitle1
        myColumnSource1 = columnSource1
        myColumnWidth1 = CGFloat(columnWidth1)
        myColumnTitle2 = columnTitle2
        myColumnSource2 = columnSource2
        myColumnWidth2 = CGFloat(columnWidth2)
        myColumnTitle3 = columnTitle3
        myColumnSource3 = columnSource3
        myColumnWidth3 = CGFloat(columnWidth3)
        myColumnTitle4 = columnTitle4
        myColumnSource4 = columnSource4
        myColumnWidth4 = CGFloat(columnWidth4)
        myColumnTitle5 = columnTitle5
        myColumnSource5 = columnSource5
        myColumnWidth5 = CGFloat(columnWidth5)
        myColumnTitle6 = columnTitle6
        myColumnSource6 = columnSource6
        myColumnWidth6 = CGFloat(columnWidth6)
        myColumnTitle7 = columnTitle7
        myColumnSource7 = columnSource7
        myColumnWidth7 = CGFloat(columnWidth7)
        myColumnTitle8 = columnTitle8
        myColumnSource8 = columnSource8
        myColumnWidth8 = CGFloat(columnWidth8)
        myColumnTitle9 = columnTitle9
        myColumnSource9 = columnSource9
        myColumnWidth9 = CGFloat(columnWidth9)
        myColumnTitle10 = columnTitle10
        myColumnSource10 = columnSource10
        myColumnWidth10 = CGFloat(columnWidth10)
        myColumnTitle11 = columnTitle11
        myColumnSource11 = columnSource11
        myColumnWidth11 = CGFloat(columnWidth11)
        myColumnTitle12 = columnTitle12
        myColumnSource12 = columnSource12
        myColumnWidth12 = CGFloat(columnWidth12)
        myColumnTitle13 = columnTitle13
        myColumnSource13 = columnSource13
        myColumnWidth13 = CGFloat(columnWidth13)
        myColumnWidth14 = CGFloat(columnWidth14)
        myColumnTitle14 = columnTitle14
        myColumnSource14 = columnSource14
        mySelectionCriteria1 = selectionCriteria1
        mySelectionCriteria2 = selectionCriteria2
        mySelectionCriteria3 = selectionCriteria3
        mySelectionCriteria4 = selectionCriteria4
        mySortOrder1 = sortOrder1
        mySortOrder2 = sortOrder2
        mySortOrder3 = sortOrder3
        mySortOrder4 = sortOrder4

        if myPaperOrientation == "Landscape"
        {
            paperSize = paperSizeLandscape
        }
        else
        {
            paperSize = paperSizePortrait
        }
        
        createHeader()
    }
    
    private func createHeader()
    {
        if myHeader == nil
        {
            myHeader = reportLine()
        }
        
        myHeader.column1 = myColumnTitle1
        myHeader.column2 = myColumnTitle2
        myHeader.column3 = myColumnTitle3
        myHeader.column4 = myColumnTitle4
        myHeader.column5 = myColumnTitle5
        myHeader.column6 = myColumnTitle6
        myHeader.column7 = myColumnTitle7
        myHeader.column8 = myColumnTitle8
        myHeader.column9 = myColumnTitle9
        myHeader.column10 = myColumnTitle10
        myHeader.column11 = myColumnTitle11
        myHeader.column12 = myColumnTitle12
        myHeader.column13 = myColumnTitle13
        myHeader.column14 = myColumnTitle14
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
    
    private func processStringCell(text: String, width: CGFloat, delimiter: String) -> String
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

        writePDFHeaderEntry(title: myHeader.column1, x: Int(leftSide), y: top, width: myColumnWidth1, height: 20)
        writePDFHeaderEntry(title: myHeader.column2, x: Int(leftSide), y: top, width: myColumnWidth2, height: 20)
        writePDFHeaderEntry(title: myHeader.column3, x: Int(leftSide), y: top, width: myColumnWidth3, height: 20)
        writePDFHeaderEntry(title: myHeader.column4, x: Int(leftSide), y: top, width: myColumnWidth4, height: 20)
        writePDFHeaderEntry(title: myHeader.column5, x: Int(leftSide), y: top, width: myColumnWidth5, height: 20)
        writePDFHeaderEntry(title: myHeader.column6, x: Int(leftSide), y: top, width: myColumnWidth6, height: 20)
        writePDFHeaderEntry(title: myHeader.column7, x: Int(leftSide), y: top, width: myColumnWidth7, height: 20)
        writePDFHeaderEntry(title: myHeader.column8, x: Int(leftSide), y: top, width: myColumnWidth8, height: 20)
        writePDFHeaderEntry(title: myHeader.column9, x: Int(leftSide), y: top, width: myColumnWidth9, height: 20)
        writePDFHeaderEntry(title: myHeader.column10, x: Int(leftSide), y: top, width: myColumnWidth10, height: 20)
        writePDFHeaderEntry(title: myHeader.column11, x: Int(leftSide), y: top, width: myColumnWidth11, height: 20)
        writePDFHeaderEntry(title: myHeader.column12, x: Int(leftSide), y: top, width: myColumnWidth12, height: 20)
        writePDFHeaderEntry(title: myHeader.column13, x: Int(leftSide), y: top, width: myColumnWidth13, height: 20)
        writePDFHeaderEntry(title: myHeader.column14, x: Int(leftSide), y: top, width: myColumnWidth14, height: 20)
    }
    
    private func lineEntry(_ line: reportLine, top: Int)
    {
        leftSide = 50
        
        writePDFEntry(title: line.column1, x: Int(leftSide), y: top, width: myColumnWidth1, height: myRowHeight)
        writePDFEntry(title: line.column2, x: Int(leftSide), y: top, width: myColumnWidth2, height: myRowHeight)
        writePDFEntry(title: line.column3, x: Int(leftSide), y: top, width: myColumnWidth3, height: myRowHeight)
        writePDFEntry(title: line.column4, x: Int(leftSide), y: top, width: myColumnWidth4, height: myRowHeight)
        writePDFEntry(title: line.column5, x: Int(leftSide), y: top, width: myColumnWidth5, height: myRowHeight)
        writePDFEntry(title: line.column6, x: Int(leftSide), y: top, width: myColumnWidth6, height: myRowHeight)
        writePDFEntry(title: line.column7, x: Int(leftSide), y: top, width: myColumnWidth7, height: myRowHeight)
        writePDFEntry(title: line.column8, x: Int(leftSide), y: top, width: myColumnWidth8, height: myRowHeight)
        writePDFEntry(title: line.column9, x: Int(leftSide), y: top, width: myColumnWidth9, height: myRowHeight)
        writePDFEntry(title: line.column10, x: Int(leftSide), y: top, width: myColumnWidth10, height: myRowHeight)
        writePDFEntry(title: line.column11, x: Int(leftSide), y: top, width: myColumnWidth11, height: myRowHeight)
        writePDFEntry(title: line.column12, x: Int(leftSide), y: top, width: myColumnWidth12, height: myRowHeight)
        writePDFEntry(title: line.column13, x: Int(leftSide), y: top, width: myColumnWidth13, height: myRowHeight)
        writePDFEntry(title: line.column14, x: Int(leftSide), y: top, width: myColumnWidth14, height: myRowHeight)
    }
    
    private func writePDFHeaderEntry(title: String, x: Int, y: Int, width: CGFloat, height: Int)
    {
//        let displayWidth = Double(width)/disvisor
       let displayWidth = (paperSize.width - 150) * (width / 100)
        
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
        
        leftSide += 5.0 + displayWidth
    }
    
    private func writePDFEntry(title: String, x: Int, y: Int, width: CGFloat, height: Int)
    {
//        let displayWidth = Double(width)/disvisor
        let displayWidth = (paperSize.width - 150) * (width / 100)
        
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
        
        leftSide += 5.0 + displayWidth
    }
    
    
    func save()
    {
        myDatabaseConnection.saveReport(myReportID,
                                        reportTitle: myReportName,
                                        reportDescription: myReportName,
                                        reportType: myReportType,
                                        systemReport: mySystemReport,
                                        teamID: myTeamID,
                                        orientation: myPaperOrientation,
                                        columnTitle1: myColumnTitle1,
                                        columnSource1: myColumnSource1,
                                        columnWidth1: Double(myColumnWidth1),
                                        columnTitle2: myColumnTitle2,
                                        columnSource2: myColumnSource2,
                                        columnWidth2: Double(myColumnWidth2),
                                        columnTitle3: myColumnTitle3,
                                        columnSource3: myColumnSource3,
                                        columnWidth3: Double(myColumnWidth3),
                                        columnTitle4: myColumnTitle4,
                                        columnSource4: myColumnSource4,
                                        columnWidth4: Double(myColumnWidth4),
                                        columnTitle5: myColumnTitle5,
                                        columnSource5: myColumnSource5,
                                        columnWidth5: Double(myColumnWidth5),
                                        columnTitle6: myColumnTitle6,
                                        columnSource6: myColumnSource6,
                                        columnWidth6: Double(myColumnWidth6),
                                        columnTitle7: myColumnTitle7,
                                        columnSource7: myColumnSource7,
                                        columnWidth7: Double(myColumnWidth7),
                                        columnTitle8: myColumnTitle8,
                                        columnSource8: myColumnSource8,
                                        columnWidth8: Double(myColumnWidth8),
                                        columnTitle9: myColumnTitle9,
                                        columnSource9: myColumnSource9,
                                        columnWidth9: Double(myColumnWidth9),
                                        columnTitle10: myColumnTitle10,
                                        columnSource10: myColumnSource10,
                                        columnWidth10: Double(myColumnWidth10),
                                        columnTitle11: myColumnTitle11,
                                        columnSource11: myColumnSource11,
                                        columnWidth11: Double(myColumnWidth11),
                                        columnTitle12: myColumnTitle12,
                                        columnSource12: myColumnSource12,
                                        columnWidth12: Double(myColumnWidth12),
                                        columnTitle13: myColumnTitle13,
                                        columnSource13: myColumnSource13,
                                        columnWidth13: Double(myColumnWidth13),
                                        columnWidth14: Double(myColumnWidth14),
                                        columnTitle14: myColumnTitle14,
                                        columnSource14: myColumnSource14,
                                        selectionCriteria1: mySelectionCriteria1,
                                        selectionCriteria2: mySelectionCriteria2,
                                        selectionCriteria3: mySelectionCriteria3,
                                        selectionCriteria4: mySelectionCriteria4,
                                        sortOrder1: mySortOrder1,
                                        sortOrder2: mySortOrder2,
                                        sortOrder3: mySortOrder3,
                                        sortOrder4: mySortOrder4)
    }
    
    func delete()
    {
        myDatabaseConnection.deleteReport(myReportID)
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

extension coreDatabase
{
    func saveReport(_ reportID: Int,
                        reportTitle: String,
                        reportDescription: String,
                        reportType: String,
                        systemReport: Bool,
                        teamID: Int,
                        orientation: String,
                        columnTitle1: String,
                        columnSource1: String,
                        columnWidth1: Double,
                        columnTitle2: String,
                        columnSource2: String,
                        columnWidth2: Double,
                        columnTitle3: String,
                        columnSource3: String,
                        columnWidth3: Double,
                        columnTitle4: String,
                        columnSource4: String,
                        columnWidth4: Double,
                        columnTitle5: String,
                        columnSource5: String,
                        columnWidth5: Double,
                        columnTitle6: String,
                        columnSource6: String,
                        columnWidth6: Double,
                        columnTitle7: String,
                        columnSource7: String,
                        columnWidth7: Double,
                        columnTitle8: String,
                        columnSource8: String,
                        columnWidth8: Double,
                        columnTitle9: String,
                        columnSource9: String,
                        columnWidth9: Double,
                        columnTitle10: String,
                        columnSource10: String,
                        columnWidth10: Double,
                        columnTitle11: String,
                        columnSource11: String,
                        columnWidth11: Double,
                        columnTitle12: String,
                        columnSource12: String,
                        columnWidth12: Double,
                        columnTitle13: String,
                        columnSource13: String,
                        columnWidth13: Double,
                        columnWidth14: Double,
                        columnTitle14: String,
                        columnSource14: String,
                        selectionCriteria1: String,
                        selectionCriteria2: String,
                        selectionCriteria3: String,
                        selectionCriteria4: String,
                        sortOrder1: String,
                        sortOrder2: String,
                        sortOrder3: String,
                        sortOrder4: String,
                   updateTime: Date =  Date(), updateType: String = "CODE")
    {
        var myItem: Reports!
        
        let myReturn = getReportDetails(reportID)
        
        if myReturn.count == 0
        { // Add
            myItem = Reports(context: objectContext)
            myItem.reportID = Int64(reportID)
            myItem.reportTitle = reportTitle
            myItem.reportDescription = reportDescription
            myItem.reportType = reportType
            myItem.systemReport = systemReport
            myItem.teamID = Int64(teamID)
            myItem.columnTitle1 = columnTitle1
            myItem.columnSource1 = columnSource1
            myItem.columnWidth1 = columnWidth1
            myItem.columnTitle2 = columnTitle2
            myItem.columnSource2 = columnSource2
            myItem.columnWidth2 = columnWidth2
            myItem.columnTitle3 = columnTitle3
            myItem.columnSource3 = columnSource3
            myItem.columnWidth3 = columnWidth3
            myItem.columnTitle4 = columnTitle4
            myItem.columnSource4 = columnSource4
            myItem.columnWidth4 = columnWidth4
            myItem.columnTitle5 = columnTitle5
            myItem.columnSource5 = columnSource5
            myItem.columnWidth5 = columnWidth5
            myItem.columnTitle6 = columnTitle6
            myItem.columnSource6 = columnSource6
            myItem.columnWidth6 = columnWidth6
            myItem.columnTitle7 = columnTitle7
            myItem.columnSource7 = columnSource7
            myItem.columnWidth7 = columnWidth7
            myItem.columnTitle8 = columnTitle8
            myItem.columnSource8 = columnSource8
            myItem.columnWidth8 = columnWidth8
            myItem.columnTitle9 = columnTitle9
            myItem.columnSource9 = columnSource9
            myItem.columnWidth9 = columnWidth9
            myItem.columnTitle10 = columnTitle10
            myItem.columnSource10 = columnSource10
            myItem.columnWidth10 = columnWidth10
            myItem.columnTitle11 = columnTitle11
            myItem.columnSource11 = columnSource11
            myItem.columnWidth11 = columnWidth11
            myItem.columnTitle12 = columnTitle12
            myItem.columnSource12 = columnSource12
            myItem.columnWidth12 = columnWidth12
            myItem.columnTitle13 = columnTitle13
            myItem.columnSource13 = columnSource13
            myItem.columnWidth13 = columnWidth13
            myItem.columnWidth14 = columnWidth14
            myItem.columnTitle14 = columnTitle14
            myItem.columnSource14 = columnSource14
            myItem.selectionCriteria1 = selectionCriteria1
            myItem.selectionCriteria2 = selectionCriteria2
            myItem.selectionCriteria3 = selectionCriteria3
            myItem.selectionCriteria4 = selectionCriteria4
            myItem.sortOrder1 = sortOrder1
            myItem.sortOrder2 = sortOrder2
            myItem.sortOrder3 = sortOrder3
            myItem.sortOrder4 = sortOrder4
            myItem.orientation = orientation
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                
                myItem.updateType = "Add"
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        else
        {
            myItem = myReturn[0]
            myItem.reportTitle = reportTitle
            myItem.reportDescription = reportDescription
            myItem.reportType = reportType
            myItem.systemReport = systemReport
            myItem.columnTitle1 = columnTitle1
            myItem.columnSource1 = columnSource1
            myItem.columnWidth1 = columnWidth1
            myItem.columnTitle2 = columnTitle2
            myItem.columnSource2 = columnSource2
            myItem.columnWidth2 = columnWidth2
            myItem.columnTitle3 = columnTitle3
            myItem.columnSource3 = columnSource3
            myItem.columnWidth3 = columnWidth3
            myItem.columnTitle4 = columnTitle4
            myItem.columnSource4 = columnSource4
            myItem.columnWidth4 = columnWidth4
            myItem.columnTitle5 = columnTitle5
            myItem.columnSource5 = columnSource5
            myItem.columnWidth5 = columnWidth5
            myItem.columnTitle6 = columnTitle6
            myItem.columnSource6 = columnSource6
            myItem.columnWidth6 = columnWidth6
            myItem.columnTitle7 = columnTitle7
            myItem.columnSource7 = columnSource7
            myItem.columnWidth7 = columnWidth7
            myItem.columnTitle8 = columnTitle8
            myItem.columnSource8 = columnSource8
            myItem.columnWidth8 = columnWidth8
            myItem.columnTitle9 = columnTitle9
            myItem.columnSource9 = columnSource9
            myItem.columnWidth9 = columnWidth9
            myItem.columnTitle10 = columnTitle10
            myItem.columnSource10 = columnSource10
            myItem.columnWidth10 = columnWidth10
            myItem.columnTitle11 = columnTitle11
            myItem.columnSource11 = columnSource11
            myItem.columnWidth11 = columnWidth11
            myItem.columnTitle12 = columnTitle12
            myItem.columnSource12 = columnSource12
            myItem.columnWidth12 = columnWidth12
            myItem.columnTitle13 = columnTitle13
            myItem.columnSource13 = columnSource13
            myItem.columnWidth13 = columnWidth13
            myItem.columnWidth14 = columnWidth14
            myItem.columnTitle14 = columnTitle14
            myItem.columnSource14 = columnSource14
            myItem.selectionCriteria1 = selectionCriteria1
            myItem.selectionCriteria2 = selectionCriteria2
            myItem.selectionCriteria3 = selectionCriteria3
            myItem.selectionCriteria4 = selectionCriteria4
            myItem.sortOrder1 = sortOrder1
            myItem.sortOrder2 = sortOrder2
            myItem.sortOrder3 = sortOrder3
            myItem.sortOrder4 = sortOrder4
            myItem.orientation = orientation
            
            if updateType == "CODE"
            {
                myItem.updateTime =  NSDate()
                if myItem.updateType != "Add"
                {
                    myItem.updateType = "Update"
                }
            }
            else
            {
                myItem.updateTime = updateTime as NSDate
                myItem.updateType = updateType
            }
        }
        
        saveContext()
        
        self.recordsProcessed += 1
    }
    
    func deleteReport(_ reportID: Int)
    {
        let myReturn = getReportDetails(reportID)
        
        if myReturn.count > 0
        {
            let myItem = myReturn[0]
            myItem.updateTime =  NSDate()
            myItem.updateType = "Delete"
        }
        
        saveContext()
    }
    
    func getReports(teamID: Int)->[Reports]
    {
        let fetchRequest = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(teamID == \(teamID)) && (updateType != \"Delete\") AND (systemReport != \"True\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getReports(teamID: Int, reportType: String)->[Reports]
    {
        let fetchRequest = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.

        let predicate = NSPredicate(format: "(teamID == \(teamID)) AND (reportType == \"\(reportType)\") AND (updateType != \"Delete\")")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func getReportDetails(_ reportID: Int)->[Reports]
    {
        let fetchRequest = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Create a new predicate that filters out any object that
        // doesn't have a title of "Best Language" exactly.
        let predicate = NSPredicate(format: "(reportID == \(reportID))")
        
        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func resetAllReports()
    {
        let fetchRequest = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            for myItem in fetchResults
            {
                myItem.updateTime =  NSDate()
                myItem.updateType = "Delete"
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func clearDeletedReports(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        saveContext()
    }
    
    func clearSyncedReports(predicate: NSPredicate)
    {
        let fetchRequest2 = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Set the predicate on the fetch request
        fetchRequest2.predicate = predicate
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                myItem2.updateType = ""
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
    
    func getReportsForSync(_ syncDate: Date) -> [Reports]
    {
        let fetchRequest = NSFetchRequest<Reports>(entityName: "Reports")
        
        let predicate = NSPredicate(format: "(updateTime >= %@)", syncDate as CVarArg)
        
        // Set the predicate on the fetch request
        
        fetchRequest.predicate = predicate
        // Execute the fetch request, and cast the results to an array of  objects
        do
        {
            let fetchResults = try objectContext.fetch(fetchRequest)
            
            return fetchResults
        }
        catch
        {
            print("Error occurred during execution: \(error)")
            return []
        }
    }
    
    func deleteAllReports()
    {
        let fetchRequest2 = NSFetchRequest<Reports>(entityName: "Reports")
        
        // Execute the fetch request, and cast the results to an array of LogItem objects
        do
        {
            let fetchResults2 = try objectContext.fetch(fetchRequest2)
            for myItem2 in fetchResults2
            {
                self.objectContext.delete(myItem2 as NSManagedObject)
            }
        }
        catch
        {
            print("Error occurred during execution: \(error)")
        }
        
        saveContext()
    }
}

extension CloudKitInteraction
{
    func saveReportsToCloudKit()
    {
        for myItem in myDatabaseConnection.getReportsForSync(myDatabaseConnection.getSyncDateForTable(tableName: "Reports"))
        {
            saveReportsRecordToCloudKit(myItem, teamID: currentUser.currentTeam!.teamID)
        }
    }
    
    func updateReportsInCoreData()
    {
        let predicate: NSPredicate = NSPredicate(format: "(updateTime >= %@) AND \(buildTeamList(currentUser.userID))", myDatabaseConnection.getSyncDateForTable(tableName: "Reports") as CVarArg)
        let query: CKQuery = CKQuery(recordType: "reports", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            self.updateReportsRecord(record)
        }
        let operationQueue = OperationQueue()
        
        executePublicQueryOperation(targetTable: "reports", queryOperation: operation, onOperationQueue: operationQueue)
    }
    
    func deleteReports(reportID: Int)
    {
        let sem = DispatchSemaphore(value: 0);
        
        var myRecordList: [CKRecordID] = Array()
        let predicate: NSPredicate = NSPredicate(format: "\(buildTeamList(currentUser.userID)) AND (reportID == \(reportID))")
        let query: CKQuery = CKQuery(recordType: "reports", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: {(results: [CKRecord]?, error: Error?) in
            for record in results!
            {
                myRecordList.append(record.recordID)
            }
            self.performPublicDelete(myRecordList)
            sem.signal()
        })
        
        sem.wait()
    }
    
    func saveReportsRecordToCloudKit(_ sourceRecord: Reports, teamID: Int)
    {
        let sem = DispatchSemaphore(value: 0)
        let predicate = NSPredicate(format: "(reportID == \(sourceRecord.reportID)) AND \(buildTeamList(currentUser.userID))") // better be accurate to get only the record you need
        let query = CKQuery(recordType: "reports", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                NSLog("Error querying records: \(error!.localizedDescription)")
            }
            else
            {
                // Lets go and get the additional details from the context1_1 table
                
                if records!.count > 0
                {
                    let record = records!.first// as! CKRecord
                    // Now you have grabbed your existing record from iCloud
                    // Apply whatever changes you want
                    
                    record!.setValue(sourceRecord.reportTitle, forKey: "reportTitle")
                    record!.setValue(sourceRecord.reportDescription, forKey: "reportDescription")
                    record!.setValue(sourceRecord.reportType, forKey: "reportType")
                    if sourceRecord.systemReport
                    {
                        record!.setValue("True", forKey: "systemReport")
                    }
                    else
                    {
                        record!.setValue("False", forKey: "systemReport")
                    }
                    record!.setValue(sourceRecord.columnTitle1, forKey: "columnTitle1")
                    record!.setValue(sourceRecord.columnSource1, forKey: "columnSource1")
                    record!.setValue(sourceRecord.columnWidth1, forKey: "columnWidth1")
                    record!.setValue(sourceRecord.columnTitle2, forKey: "columnTitle2")
                    record!.setValue(sourceRecord.columnSource2, forKey: "columnSource2")
                    record!.setValue(sourceRecord.columnWidth2, forKey: "columnWidth2")
                    record!.setValue(sourceRecord.columnTitle3, forKey: "columnTitle3")
                    record!.setValue(sourceRecord.columnSource3, forKey: "columnSource3")
                    record!.setValue(sourceRecord.columnWidth3, forKey: "columnWidth3")
                    record!.setValue(sourceRecord.columnTitle4, forKey: "columnTitle4")
                    record!.setValue(sourceRecord.columnSource4, forKey: "columnSource4")
                    record!.setValue(sourceRecord.columnWidth4, forKey: "columnWidth4")
                    record!.setValue(sourceRecord.columnTitle5, forKey: "columnTitle5")
                    record!.setValue(sourceRecord.columnSource5, forKey: "columnSource5")
                    record!.setValue(sourceRecord.columnWidth5, forKey: "columnWidth5")
                    record!.setValue(sourceRecord.columnTitle6, forKey: "columnTitle6")
                    record!.setValue(sourceRecord.columnSource6, forKey: "columnSource6")
                    record!.setValue(sourceRecord.columnWidth6, forKey: "columnWidth6")
                    record!.setValue(sourceRecord.columnTitle7, forKey: "columnTitle7")
                    record!.setValue(sourceRecord.columnSource7, forKey: "columnSource7")
                    record!.setValue(sourceRecord.columnWidth7, forKey: "columnWidth7")
                    record!.setValue(sourceRecord.columnTitle8, forKey: "columnTitle8")
                    record!.setValue(sourceRecord.columnSource8, forKey: "columnSource8")
                    record!.setValue(sourceRecord.columnWidth8, forKey: "columnWidth8")
                    record!.setValue(sourceRecord.columnTitle9, forKey: "columnTitle9")
                    record!.setValue(sourceRecord.columnSource9, forKey: "columnSource9")
                    record!.setValue(sourceRecord.columnWidth9, forKey: "columnWidth9")
                    record!.setValue(sourceRecord.columnTitle10, forKey: "columnTitle10")
                    record!.setValue(sourceRecord.columnSource10, forKey: "columnSource10")
                    record!.setValue(sourceRecord.columnWidth10, forKey: "columnWidth10")
                    record!.setValue(sourceRecord.columnTitle11, forKey: "columnTitle11")
                    record!.setValue(sourceRecord.columnSource11, forKey: "columnSource11")
                    record!.setValue(sourceRecord.columnWidth11, forKey: "columnWidth11")
                    record!.setValue(sourceRecord.columnTitle12, forKey: "columnTitle12")
                    record!.setValue(sourceRecord.columnSource12, forKey: "columnSource12")
                    record!.setValue(sourceRecord.columnWidth12, forKey: "columnWidth12")
                    record!.setValue(sourceRecord.columnTitle13, forKey: "columnTitle13")
                    record!.setValue(sourceRecord.columnSource13, forKey: "columnSource13")
                    record!.setValue(sourceRecord.columnWidth13, forKey: "columnWidth13")
                    record!.setValue(sourceRecord.columnWidth14, forKey: "columnWidth14")
                    record!.setValue(sourceRecord.columnTitle14, forKey: "columnTitle14")
                    record!.setValue(sourceRecord.columnSource14, forKey: "columnSource14")
                    record!.setValue(sourceRecord.selectionCriteria1, forKey: "selectionCriteria1")
                    record!.setValue(sourceRecord.selectionCriteria2, forKey: "selectionCriteria2")
                    record!.setValue(sourceRecord.selectionCriteria3, forKey: "selectionCriteria3")
                    record!.setValue(sourceRecord.selectionCriteria4, forKey: "selectionCriteria4")
                    record!.setValue(sourceRecord.sortOrder1, forKey: "sortOrder1")
                    record!.setValue(sourceRecord.sortOrder2, forKey: "sortOrder2")
                    record!.setValue(sourceRecord.sortOrder3, forKey: "sortOrder3")
                    record!.setValue(sourceRecord.sortOrder4, forKey: "sortOrder4")
                    record!.setValue(sourceRecord.orientation, forKey: "orientation")

                    if sourceRecord.updateTime != nil
                    {
                        record!.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record!.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    // Save this record again
                    self.publicDB.save(record!, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully updated record!")
                            }
                        }
                    })
                }
                else
                {  // Insert
                    let record = CKRecord(recordType: "reports")
                    
                    record.setValue(sourceRecord.reportID, forKey: "reportID")
                    record.setValue(sourceRecord.reportTitle, forKey: "reportTitle")
                    record.setValue(sourceRecord.reportDescription, forKey: "reportDescription")
                    record.setValue(sourceRecord.reportType, forKey: "reportType")
                    if sourceRecord.systemReport
                    {
                        record.setValue("True", forKey: "systemReport")
                    }
                    else
                    {
                        record.setValue("False", forKey: "systemReport")
                    }
                    record.setValue(sourceRecord.teamID, forKey: "teamID")
                    record.setValue(sourceRecord.columnTitle1, forKey: "columnTitle1")
                    record.setValue(sourceRecord.columnSource1, forKey: "columnSource1")
                    record.setValue(sourceRecord.columnWidth1, forKey: "columnWidth1")
                    record.setValue(sourceRecord.columnTitle2, forKey: "columnTitle2")
                    record.setValue(sourceRecord.columnSource2, forKey: "columnSource2")
                    record.setValue(sourceRecord.columnWidth2, forKey: "columnWidth2")
                    record.setValue(sourceRecord.columnTitle3, forKey: "columnTitle3")
                    record.setValue(sourceRecord.columnSource3, forKey: "columnSource3")
                    record.setValue(sourceRecord.columnWidth3, forKey: "columnWidth3")
                    record.setValue(sourceRecord.columnTitle4, forKey: "columnTitle4")
                    record.setValue(sourceRecord.columnSource4, forKey: "columnSource4")
                    record.setValue(sourceRecord.columnWidth4, forKey: "columnWidth4")
                    record.setValue(sourceRecord.columnTitle5, forKey: "columnTitle5")
                    record.setValue(sourceRecord.columnSource5, forKey: "columnSource5")
                    record.setValue(sourceRecord.columnWidth5, forKey: "columnWidth5")
                    record.setValue(sourceRecord.columnTitle6, forKey: "columnTitle6")
                    record.setValue(sourceRecord.columnSource6, forKey: "columnSource6")
                    record.setValue(sourceRecord.columnWidth6, forKey: "columnWidth6")
                    record.setValue(sourceRecord.columnTitle7, forKey: "columnTitle7")
                    record.setValue(sourceRecord.columnSource7, forKey: "columnSource7")
                    record.setValue(sourceRecord.columnWidth7, forKey: "columnWidth7")
                    record.setValue(sourceRecord.columnTitle8, forKey: "columnTitle8")
                    record.setValue(sourceRecord.columnSource8, forKey: "columnSource8")
                    record.setValue(sourceRecord.columnWidth8, forKey: "columnWidth8")
                    record.setValue(sourceRecord.columnTitle9, forKey: "columnTitle9")
                    record.setValue(sourceRecord.columnSource9, forKey: "columnSource9")
                    record.setValue(sourceRecord.columnWidth9, forKey: "columnWidth9")
                    record.setValue(sourceRecord.columnTitle10, forKey: "columnTitle10")
                    record.setValue(sourceRecord.columnSource10, forKey: "columnSource10")
                    record.setValue(sourceRecord.columnWidth10, forKey: "columnWidth10")
                    record.setValue(sourceRecord.columnTitle11, forKey: "columnTitle11")
                    record.setValue(sourceRecord.columnSource11, forKey: "columnSource11")
                    record.setValue(sourceRecord.columnWidth11, forKey: "columnWidth11")
                    record.setValue(sourceRecord.columnTitle12, forKey: "columnTitle12")
                    record.setValue(sourceRecord.columnSource12, forKey: "columnSource12")
                    record.setValue(sourceRecord.columnWidth12, forKey: "columnWidth12")
                    record.setValue(sourceRecord.columnTitle13, forKey: "columnTitle13")
                    record.setValue(sourceRecord.columnSource13, forKey: "columnSource13")
                    record.setValue(sourceRecord.columnWidth13, forKey: "columnWidth13")
                    record.setValue(sourceRecord.columnWidth14, forKey: "columnWidth14")
                    record.setValue(sourceRecord.columnTitle14, forKey: "columnTitle14")
                    record.setValue(sourceRecord.columnSource14, forKey: "columnSource14")
                    record.setValue(sourceRecord.selectionCriteria1, forKey: "selectionCriteria1")
                    record.setValue(sourceRecord.selectionCriteria2, forKey: "selectionCriteria2")
                    record.setValue(sourceRecord.selectionCriteria3, forKey: "selectionCriteria3")
                    record.setValue(sourceRecord.selectionCriteria4, forKey: "selectionCriteria4")
                    record.setValue(sourceRecord.sortOrder1, forKey: "sortOrder1")
                    record.setValue(sourceRecord.sortOrder2, forKey: "sortOrder2")
                    record.setValue(sourceRecord.sortOrder3, forKey: "sortOrder3")
                    record.setValue(sourceRecord.sortOrder4, forKey: "sortOrder4")
                    record.setValue(sourceRecord.orientation, forKey: "orientation")


                    if sourceRecord.updateTime != nil
                    {
                        record.setValue(sourceRecord.updateTime, forKey: "updateTime")
                    }
                    record.setValue(sourceRecord.updateType, forKey: "updateType")
                    
                    self.publicDB.save(record, completionHandler: { (savedRecord, saveError) in
                        if saveError != nil
                        {
                            NSLog("Error saving record: \(saveError!.localizedDescription)")
                            self.saveOK = false
                        }
                        else
                        {
                            if debugMessages
                            {
                                NSLog("Successfully saved record!")
                            }
                        }
                    })
                }
            }
            sem.signal()
        })
        sem.wait()
    }
    
    func updateReportsRecord(_ sourceRecord: CKRecord)
    {
        let reportTitle = sourceRecord.object(forKey: "reportTitle") as! String
        let reportDescription = sourceRecord.object(forKey: "reportDescription") as! String
        let reportType = sourceRecord.object(forKey: "reportType") as! String
        let columnTitle1 = sourceRecord.object(forKey: "columnTitle1") as! String
        let columnSource1 = sourceRecord.object(forKey: "columnSource1") as! String
        let columnTitle2 = sourceRecord.object(forKey: "columnTitle2") as! String
        let columnSource2 = sourceRecord.object(forKey: "columnSource2") as! String
        let columnTitle3 = sourceRecord.object(forKey: "columnTitle3") as! String
        let columnSource3 = sourceRecord.object(forKey: "columnSource3") as! String
        let columnTitle4 = sourceRecord.object(forKey: "columnTitle4") as! String
        let columnSource4 = sourceRecord.object(forKey: "columnSource4") as! String
        let columnTitle5 = sourceRecord.object(forKey: "columnTitle5") as! String
        let columnSource5 = sourceRecord.object(forKey: "columnSource5") as! String
        let columnTitle6 = sourceRecord.object(forKey: "columnTitle6") as! String
        let columnSource6 = sourceRecord.object(forKey: "columnSource6") as! String
        let columnTitle7 = sourceRecord.object(forKey: "columnTitle7") as! String
        let columnSource7 = sourceRecord.object(forKey: "columnSource7") as! String
        let columnTitle8 = sourceRecord.object(forKey: "columnTitle8") as! String
        let columnSource8 = sourceRecord.object(forKey: "columnSource8") as! String
        let columnTitle9 = sourceRecord.object(forKey: "columnTitle9") as! String
        let columnSource9 = sourceRecord.object(forKey: "columnSource9") as! String
        let columnTitle10 = sourceRecord.object(forKey: "columnTitle10") as! String
        let columnSource10 = sourceRecord.object(forKey: "columnSource10") as! String
        let columnTitle11 = sourceRecord.object(forKey: "columnTitle11") as! String
        let columnSource11 = sourceRecord.object(forKey: "columnSource11") as! String
        let columnTitle12 = sourceRecord.object(forKey: "columnTitle12") as! String
        let columnSource12 = sourceRecord.object(forKey: "columnSource12") as! String
        let columnTitle13 = sourceRecord.object(forKey: "columnTitle13") as! String
        let columnSource13 = sourceRecord.object(forKey: "columnSource13") as! String
        let columnTitle14 = sourceRecord.object(forKey: "columnTitle14") as! String
        let columnSource14 = sourceRecord.object(forKey: "columnSource14") as! String
        let selectionCriteria1 = sourceRecord.object(forKey: "selectionCriteria1") as! String
        let selectionCriteria2 = sourceRecord.object(forKey: "selectionCriteria2") as! String
        let selectionCriteria3 = sourceRecord.object(forKey: "selectionCriteria3") as! String
        let selectionCriteria4 = sourceRecord.object(forKey: "selectionCriteria4") as! String
        let sortOrder1 = sourceRecord.object(forKey: "sortOrder1") as! String
        let sortOrder2 = sourceRecord.object(forKey: "sortOrder2") as! String
        let sortOrder3 = sourceRecord.object(forKey: "sortOrder3") as! String
        let sortOrder4 = sourceRecord.object(forKey: "sortOrder4") as! String
        let orientation = sourceRecord.object(forKey: "orientation") as! String
        
        var columnWidth1: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth1") != nil
        {
            columnWidth1 = sourceRecord.object(forKey: "columnWidth1") as! Double
        }

        var columnWidth2: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth2") != nil
        {
            columnWidth2 = sourceRecord.object(forKey: "columnWidth2") as! Double
        }

        var columnWidth3: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth3") != nil
        {
            columnWidth3 = sourceRecord.object(forKey: "columnWidth3") as! Double
        }

        var columnWidth4: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth4") != nil
        {
            columnWidth4 = sourceRecord.object(forKey: "columnWidth4") as! Double
        }

        var columnWidth5: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth5") != nil
        {
            columnWidth5 = sourceRecord.object(forKey: "columnWidth5") as! Double
        }

        var columnWidth6: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth6") != nil
        {
            columnWidth6 = sourceRecord.object(forKey: "columnWidth6") as! Double
        }

        var columnWidth7: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth7") != nil
        {
            columnWidth7 = sourceRecord.object(forKey: "columnWidth7") as! Double
        }

        var columnWidth8: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth8") != nil
        {
            columnWidth8 = sourceRecord.object(forKey: "columnWidth8") as! Double
        }

        var columnWidth9: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth9") != nil
        {
            columnWidth9 = sourceRecord.object(forKey: "columnWidth9") as! Double
        }

        var columnWidth10: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth10") != nil
        {
            columnWidth10 = sourceRecord.object(forKey: "columnWidth10") as! Double
        }

        var columnWidth11: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth11") != nil
        {
            columnWidth11 = sourceRecord.object(forKey: "columnWidth11") as! Double
        }

        var columnWidth12: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth12") != nil
        {
            columnWidth12 = sourceRecord.object(forKey: "columnWidth12") as! Double
        }

        var columnWidth13: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth13") != nil
        {
            columnWidth13 = sourceRecord.object(forKey: "columnWidth13") as! Double
        }

        var columnWidth14: Double = 0.0
        if sourceRecord.object(forKey: "columnWidth14") != nil
        {
            columnWidth14 = sourceRecord.object(forKey: "columnWidth14") as! Double
        }

        var reportID: Int = 0
        if sourceRecord.object(forKey: "reportID") != nil
        {
            reportID = sourceRecord.object(forKey: "reportID") as! Int
        }
        
        var updateTime = Date()
        if sourceRecord.object(forKey: "updateTime") != nil
        {
            updateTime = sourceRecord.object(forKey: "updateTime") as! Date
        }
        
        var updateType: String = ""
        if sourceRecord.object(forKey: "updateType") != nil
        {
            updateType = sourceRecord.object(forKey: "updateType") as! String
        }
        
        var systemReport: Bool = false
        
        if sourceRecord.object(forKey: "systemReport") as! String == "True"
        {
            systemReport = true
        }

        var teamID: Int = 0
        if sourceRecord.object(forKey: "teamID") != nil
        {
            teamID = sourceRecord.object(forKey: "teamID") as! Int
        }
        
        myDatabaseConnection.recordsToChange += 1
        
        while self.recordCount > 0
        {
            usleep(self.sleepTime)
        }
        
        self.recordCount += 1
        
        myDatabaseConnection.saveReport(reportID,
                                       reportTitle: reportTitle,
                                       reportDescription: reportDescription,
                                       reportType: reportType,
                                       systemReport: systemReport,
                                       teamID: teamID,
                                       orientation: orientation,
                                       columnTitle1: columnTitle1,
                                       columnSource1: columnSource1,
                                       columnWidth1: columnWidth1,
                                       columnTitle2: columnTitle2,
                                       columnSource2: columnSource2,
                                       columnWidth2: columnWidth2,
                                       columnTitle3: columnTitle3,
                                       columnSource3: columnSource3,
                                       columnWidth3: columnWidth3,
                                       columnTitle4: columnTitle4,
                                       columnSource4: columnSource4,
                                       columnWidth4: columnWidth4,
                                       columnTitle5: columnTitle5,
                                       columnSource5: columnSource5,
                                       columnWidth5: columnWidth5,
                                       columnTitle6: columnTitle6,
                                       columnSource6: columnSource6,
                                       columnWidth6: columnWidth6,
                                       columnTitle7: columnTitle7,
                                       columnSource7: columnSource7,
                                       columnWidth7: columnWidth7,
                                       columnTitle8: columnTitle8,
                                       columnSource8: columnSource8,
                                       columnWidth8: columnWidth8,
                                       columnTitle9: columnTitle9,
                                       columnSource9: columnSource9,
                                       columnWidth9: columnWidth9,
                                       columnTitle10: columnTitle10,
                                       columnSource10: columnSource10,
                                       columnWidth10: columnWidth10,
                                       columnTitle11: columnTitle11,
                                       columnSource11: columnSource11,
                                       columnWidth11: columnWidth11,
                                       columnTitle12: columnTitle12,
                                       columnSource12: columnSource12,
                                       columnWidth12: columnWidth12,
                                       columnTitle13: columnTitle13,
                                       columnSource13: columnSource13,
                                       columnWidth13: columnWidth13,
                                       columnWidth14: columnWidth14,
                                       columnTitle14: columnTitle14,
                                       columnSource14: columnSource14,
                                       selectionCriteria1: selectionCriteria1,
                                       selectionCriteria2: selectionCriteria2,
                                       selectionCriteria3: selectionCriteria3,
                                       selectionCriteria4: selectionCriteria4,
                                       sortOrder1: sortOrder1,
                                       sortOrder2: sortOrder2,
                                       sortOrder3: sortOrder3,
                                       sortOrder4: sortOrder4,
                                       updateTime: updateTime, updateType: updateType)
        self.recordCount -= 1
    }
}
