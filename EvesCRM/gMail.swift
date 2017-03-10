//
//  gMail.swift
//  Contacts Dashboard
//
//  Created by Garry Eves on 9/06/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import Foundation
import AddressBook
import GoogleSignIn
import GoogleAPIClientForREST

//import AppKit


class gmailMessage: NSObject
{
    fileprivate var mySubject: String = ""
    fileprivate var myFrom: String = ""
    fileprivate var myTo: String = ""
    fileprivate var myDateString: String = ""
    fileprivate var myDate: Date = Date()
    fileprivate var myID: String = ""
    fileprivate var myThreadId: String = ""
    fileprivate var mySnippet: String = ""
    fileprivate var myBody: String = ""
    
    var subject: String
    {
        get
        {
            return mySubject
        }
    }
    
    var id: String
        {
        get
        {
            return myID
        }
        set
        {
            myID = newValue
        }
    }
    
    var threadId: String
        {
        get
        {
            return myThreadId
        }
        set
        {
            myThreadId = newValue
        }
    }

    var snippet: String
        {
        get
        {
            return mySnippet
        }
    }

    var from: String
        {
        get
        {
            return myFrom
        }
    }

    var to: String
        {
        get
        {
            return myTo
        }
    }

    var dateReceived: String
        {
        get
        {
            let myDateFormatter = DateFormatter()
                
            let dateFormat = DateFormatter.Style.medium
            let timeFormat = DateFormatter.Style.short
         //GRE   myDateFormatter.timeZone = TimeZone()
            myDateFormatter.dateStyle = dateFormat
            myDateFormatter.timeStyle = timeFormat
                
            /* Instantiate the event store */
            let returnDate = myDateFormatter.string(from: myDate)
                
            return returnDate
        }
    }
    
    var body: String
        {
        get
        {
            return myBody
        }
    }

    func populateMessage(_ inData: gmailData)
    {
        // Make call to get the full details of the message
        // format as full
        let workingString = "https://www.googleapis.com/gmail/v1/users/me/messages/\(myID)?format=full"
        
        let myString = inData.getData(workingString)
        
       splitString(myString)
    }
    
    fileprivate func splitString(_ inString: String)
    {
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let tempStr3 = inString.replacingOccurrences(of: "\\u003e,", with: "")
        let tempStr4 = tempStr3.replacingOccurrences(of: "\\u003c,", with: "")
        let tempStr5 = tempStr4.replacingOccurrences(of: "\\u003e", with: "")
        let tempStr6 = tempStr5.replacingOccurrences(of: "\\u003c", with: "")
//if myID == "12613a7c784c8656"
//{
//println("inString = \(inString)")
//}
        var split: [String]!
        var passNum: Int = 1
        
        if tempStr6.range(of: "\"labelIds\": [") != nil
        {
            // We can split based on label ID
            split = tempStr6.components(separatedBy: "],")
            passNum = 1
        }
        else
        {
            split = Array()
            split.append(tempStr6)
            passNum = 2
        }
  
        
        var messageType : String = "RECEIVED"

        for myItem in split
        {
            if passNum == 1
            {
                // This is a wrapper portion so we do nothing

                if myItem.range(of: "SENT") != nil
                {
                    //This is a messgae that ahs been SENT as opposed to received
                    messageType = "SENT"
                }
            }
    
            if passNum == 2
            {
                let split2 = myItem.components(separatedBy: "\"headers\": [")

                var pass2Num: Int = 1
                for myItem2 in split2
                {
                    // lets get rid of the "
                    let tempPassStr = myItem2.replacingOccurrences(of: "\"\"", with: "\".\"")
                    
                    if pass2Num == 1
                    {
                        let split3 = tempPassStr.components(separatedBy: "\",")
                        for myItem3 in split3
                        {
                            if myItem3.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""
                            {
                                let split4 = myItem3.components(separatedBy: "\":")
                                let keyString = split4[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                let keyString2 = keyString.replacingOccurrences(of: "\"", with: "")
                                let valueString = split4[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                let valueString2 = valueString.replacingOccurrences(of: "\"", with: "") as String
                            
                                if keyString2 == "snippet"
                                {
                                    if valueString2.range(of: "http") == nil
                                    {
                                        let sDecodea = valueString2.replacingOccurrences(of: "% ", with: "GREPCENTGRE")
                                        let sDecode1 = sDecodea.removingPercentEncoding
                                        let sDecode2 = sDecode1?.replacingOccurrences(of: "&#39;", with: "'")
                                        let sDecode3 = sDecode2?.replacingOccurrences(of: "&quot;", with: "\"")
                                        let sDecode4 = sDecode3?.replacingOccurrences(of: "&lt;", with: "<")
                                        let sDecode5 = sDecode4?.replacingOccurrences(of: "&gt;", with: ">")
                                        let sDecode6 = sDecode5?.replacingOccurrences(of: "GREPCENTGRE", with: "% ")
                                    
                                        mySnippet = sDecode6!
                                    }
                                    else
                                    {
                                        mySnippet = valueString2
                                    }
                                }
                            }
                        }
                    }
                    
                    if pass2Num == 2
                    {
                        
                        processMessageDetails(tempPassStr)
                    }
                    pass2Num = pass2Num + 1
                }
            }

            if passNum == 3 && messageType == "SENT"
            {
                processMessageDetails(myItem)
            }
            else if passNum == 3
            {
                processMessageBody(myItem)
            }

            if passNum > 3
            {
                processMessageBody(myItem)
            }
            
            passNum = passNum + 1
        }
    }
    
    fileprivate func processMessageBody(_ inString: String)
    {
        // Start to break the message body down
        
        // Does the incoming part contain the data clause
        if inString.range(of: "\"data\"") != nil
        {
            let split1 = inString.components(separatedBy: "\"data\":")
            // This gives the Header part, and also the body + trailer
            
            let split2 = split1[1].components(separatedBy: "\"")

            // This splits the body and gives us a "dummy" headers, as first char is a ", the actual body and the trailer record
            
            let myTmp1 = split2[1].replacingOccurrences(of: "-", with: "+")
            let myTmp2 = myTmp1.replacingOccurrences(of: "_", with: "/")
            
            let decodedData = Data(base64Encoded: myTmp2, options: .ignoreUnknownCharacters)
            
            if decodedData != nil
            {
                let decodedString = NSString(data: decodedData!, encoding: String.Encoding.utf8.rawValue)

                if decodedString != nil
                {
                    myBody = decodedString! as String
                }
            }
        }
    }

    fileprivate func processMessageDetails(_ inString: String)
    {
        let temp2Pass = inString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let temp2Pass0 = temp2Pass.replacingOccurrences(of: "},", with: "*^&,")
        let temp2Pass1 = temp2Pass0.replacingOccurrences(of: "\",", with: "\"*^&,")
        let temp2Pass2 = temp2Pass1.replacingOccurrences(of: "}", with: "")
        let temp2Pass3 = temp2Pass2.replacingOccurrences(of: "{", with: "")
        
        // Dates have a comma so need to get rid of them
        
        let temp2Pass4 = temp2Pass3.replacingOccurrences(of: "Mon,", with: "Mon")
        let temp2Pass5 = temp2Pass4.replacingOccurrences(of: "Tue,", with: "Tue")
        let temp2Pass6 = temp2Pass5.replacingOccurrences(of: "Wed,", with: "Wed")
        let temp2Pass7 = temp2Pass6.replacingOccurrences(of: "Thu,", with: "Thu")
        let temp2Pass8 = temp2Pass7.replacingOccurrences(of: "Fri,", with: "Fri")
        let temp2Pass9 = temp2Pass8.replacingOccurrences(of: "Sat,", with: "Sat")
        let temp2Pass10 = temp2Pass9.replacingOccurrences(of: "Sun,", with: "Sun")
        let temp2Pass11 = temp2Pass10.replacingOccurrences(of: "to:", with: "to")
        let temp2Pass12 = temp2Pass11.replacingOccurrences(of: "http:", with: "http")
        let temp2Pass13 = temp2Pass12.replacingOccurrences(of: "https:", with: "https")
        let temp2Pass14 = temp2Pass13.replacingOccurrences(of: ", ", with: " ")
        let temp2Pass15 = temp2Pass14.replacingOccurrences(of: "\\", with: "")
        
        let split3 = temp2Pass15.components(separatedBy: "*^&,")
        var split3Pass1: Bool = true
        var keyString2: String = ""
        var valueString2: String = ""
        for myItem3 in split3
        {
            let stripSpaces = myItem3.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if stripSpaces != ""
            {
                
                let split4 = stripSpaces.components(separatedBy: "\":")

                if split4.count > 1
                {
                    if split3Pass1
                    {
                        // Item is the key
                        let keyString = split4[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        keyString2 = keyString.replacingOccurrences(of: "\"", with: "")
                        split3Pass1 = false
                    }
                    else
                    {
                        let valueString = split4[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        valueString2 = valueString.replacingOccurrences(of: "\"", with: "")

                        switch keyString2
                        {
                        case "Subject":
                            mySubject = valueString2
                        
                        case "From":
                            myFrom = valueString2
                        
                        case "To":
                            myTo = valueString2
                        
                        case "Date":
                            myDateString = valueString2  // fallback date, if required
                            // here we need to do the correct formatting of the date
                            // There are multiple formats for the date, so we need to make sure we can get the correct one
                        
                            // first split off the bits after the +, as they all have that in common
                            
                            var timeAdjuststring: String = ""
                            var timeAdjustmentType: String = "+"
                            var hoursAdjustment: Int = 0
                            var minutesAdjustment: Int = 0
                            var splitDate: [String]!
                            
                            splitDate = valueString2.components(separatedBy: "+")

                            let numberCheck = characterAtIndex(valueString2, index: 0)
                            
                            let myDateFormatter = DateFormatter()
                            
                            if splitDate.count > 1
                            {// do for + hours
                                if valueString2.range(of: "(") != nil
                                { // This one has the Timezone included in it, format example Mon 15 June 2015 23:49:09 +0000 (UTC)
                                    myDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
                                    
                                    // Lets get rid of the timezone bit
                    
                                    let splitZone = splitDate[1].components(separatedBy: " ")
                                    timeAdjuststring = splitZone[0]
                                }
                                else if  numberCheck >= "0" && numberCheck <= "9"
                                { // format = 16 June 2015 15:55:37 +1000
                                    myDateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
                                    timeAdjuststring = splitDate[1]
                                }
                                else
                                {// format = Mon 15 June 2015 02:59:09 +0000
                                    myDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
                                    timeAdjuststring = splitDate[1]
                                }
                            }
                            else
                            {
                            // Belt and braces, so for - hours
                                timeAdjustmentType = "-"
                                splitDate = valueString2.components(separatedBy: "-")
                                
                                if valueString2.range(of: "(") != nil
                                { // This one has the Timezone included in it, format example Mon 15 June 2015 23:49:09 +0000 (UTC)
                                    myDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
                                    
                                    // Lets get rid of the timezone bit
                                    
                                    let splitZone = splitDate[1].components(separatedBy: " ")
                                    timeAdjuststring = splitZone[0]
                                }
                                else if  numberCheck >= "0" && numberCheck <= "9"
                                { // format = 16 June 2015 15:55:37 +1000
                                    myDateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
                                    timeAdjuststring = splitDate[1]
                                }
                                else
                                {// format = Mon 15 June 2015 02:59:09 +0000
                                    if splitDate.count > 1
                                    {
                                        myDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss"
                                        timeAdjuststring = splitDate[1]
                                    }
                                    else
                                    {
                                        myDateFormatter.dateFormat = "EEE dd MMM yyyy HH:mm:ss v"
                                        timeAdjuststring = ""
                                    }
                                }
                            }
                            
                            // Work out the timezone change

                            // first 2 give us the hours
                            
                            if timeAdjuststring != ""
                            {
                                let hoursTemp = Int(timeAdjuststring.substring(with: (timeAdjuststring.startIndex ..< timeAdjuststring.characters.index(timeAdjuststring.startIndex, offsetBy: 2))))!
                            
                                if timeAdjustmentType == "+"
                                {
                                    hoursAdjustment = 0 - hoursTemp
                                }
                                else
                                {
                                    hoursAdjustment = hoursTemp
                                }
                            
                                // last 2 give us the minutes
                                let minutesTemp = Int(timeAdjuststring.substring(with: (timeAdjuststring.characters.index(timeAdjuststring.startIndex, offsetBy: 2) ..< timeAdjuststring.characters.index(timeAdjuststring.endIndex, offsetBy: -1))))!
                            
                                if timeAdjustmentType == "+"
                                {
                                    minutesAdjustment = 0 - minutesTemp
                                }
                                else
                                {
                                    minutesAdjustment = minutesTemp
                                }
                            }
                            
                            let tempDate: Date = myDateFormatter.date(from: splitDate[0])!
                            
                            let tempDate1 = Calendar.current.date(
                                byAdding: .hour,
                                value: hoursAdjustment,
                                to: tempDate)

                            let tempDate2 = Calendar.current.date(
                                byAdding: .minute,
                                value: minutesAdjustment,
                                to: tempDate1!)

                            let timezoneAdjust = NSTimeZone.local.secondsFromGMT()
                            
                            let timezoneAdjust2 = (timezoneAdjust / 60) / 60
                            
                            let tempDate3 = Calendar.current.date(
                                byAdding: .hour,
                                value: timezoneAdjust2,
                                to: tempDate2!)

                            myDate = tempDate3!
                            myDateString = valueString2
                        
                        default:
                            _ = 1
                        
                        }
                    
                        keyString2 = ""
                        valueString2 = ""
                    
                        split3Pass1 = true
                    }
                }
            }
        }
    }
}

class gmailMessages: NSObject
{
    fileprivate var myMessages: [gmailMessage] = []
    fileprivate var myGmailData: gmailData!
    
    var messages: [gmailMessage]
    {
        get
        {
            return myMessages
        }
    }
    
    init(inGmailData: gmailData)
    {
        super.init()
        myGmailData = inGmailData
    }
    
    func getPersonMessages(_ inString: String, emailAddresses: [String], inMessageType: String)
    {
        // this is used to get the messages
        
        var workingString: String = "https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=20"

        if inMessageType == "Hangouts"
        {
            workingString += "&q=is:chat"
        }
        else
        {
            workingString += "&q=-is:chat"
        }
        
        // Searching for a person
        // Add in a search by name
        workingString += " \"\(inString)\""
            
        // Go and get email addresses for the person
            
        for emailAddress in emailAddresses
        {
            workingString += " OR from:\(emailAddress)"
            workingString += " OR to:\(emailAddress)"
            workingString += " OR cc:\(emailAddress)"
            workingString += " OR bcc:\(emailAddress)"
        }

        let myString = myGmailData.getData(workingString)

        splitString(myString)
        
        if inMessageType == "Hangouts"
        {
           // listMessages()
            notificationCenter.post(name: NotificationHangoutsDidFinish, object: nil)
        }
        else
        {
            notificationCenter.post(name: NotificationGmailDidFinish, object: nil)
        }
    }
    
    func getProjectMessages(_ inString: String, inMessageType: String)
    {
        // this is used to get the messages
        
        var workingString: String = "https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=20"
        
        if inMessageType == "Hangouts"
        {
            workingString += "&q=is:chat"
        }
        else
        {
            workingString += "&q=-is:chat"
        }
        
        workingString += " \"\(inString)\""
        
        let myString = myGmailData.getData(workingString)
        
        splitString(myString)
        
        if inMessageType == "Hangouts"
        {
            // listMessages()
            notificationCenter.post(name: NotificationHangoutsDidFinish, object: nil)
        }
        else
        {
            notificationCenter.post(name: NotificationGmailDidFinish, object: nil)
        }
        
    }
    
    func getInbox()
    {
        // this is used to get the messages
        
        var workingString: String = "https://www.googleapis.com/gmail/v1/users/me/messages?maxResults=20"
        
        workingString += "&q=in:inbox"
        
        let myString = myGmailData.getData(workingString)
        
        splitString(myString)
        
        notificationCenter.post(name: NotificationGmailInboxLoadDidFinish, object: nil)
    }

    
    fileprivate func splitString(_ inString: String)
    {
        var processedFileHeader: Bool = false
        var firstItem2: Bool = true
        
        // we need to do a bit of "dodgy" working, I want to be able to split strings based on :, but : is natural in dates and URTLs. so need to change it to seomthign esle,
        //string out the : data and then change back
        
        let tempStr1 = inString.replacingOccurrences(of: "},", with: "")
        let tempStr2 = tempStr1.replacingOccurrences(of: "}", with: "")
        let tempStr3 = tempStr2.replacingOccurrences(of: "],", with: "")
        let tempStr4 = tempStr3.replacingOccurrences(of: "\"", with: "")

        let split = tempStr4.components(separatedBy: "{")
        
        myMessages = Array()
        
        for myItem in split
        {
            if !processedFileHeader
            {
                // Ignore the first line, it is a header
                processedFileHeader = true
            }
            else
            {
                // need to further split the items into its component parts
                let split2 = myItem.components(separatedBy: ",")
                firstItem2 = true
                let myMessage = gmailMessage()
                for myItem2 in split2
                {
                    var split3: [String]
                    
                    if firstItem2
                    {  // strip out characters upto and including the first comma
                        let end = myItem2.characters.index(myItem2.endIndex, offsetBy: -1)
                        let start = myItem2.characters.index(of: ",")
                        
                        var selectedString: String = ""
                        
                        if start != nil
                        {
                            let myStart = myItem2.index(after: (start)!)
                            selectedString = myItem2[myStart...end]
                        }
                        else
                        { // no space found
                            selectedString = myItem2
                        }
                        
                        split3 = selectedString.components(separatedBy: ":")
                        firstItem2 = false
                    }
                    else
                    {
                        split3 = myItem2.components(separatedBy: ":")
                    }

                    let keyString = split3[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let valueString = split3[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    // now split each of these into value pairs - how to store?  Maybe in a Collection??

                    switch keyString
                    {
                    case "id" :
                        myMessage.id = valueString
                        
                    case "threadId" :
                        myMessage.threadId = valueString
                        
                    default:
                        _ = 1
                    }
                }
                
                if myMessage.id != ""
                {
                    myMessages.append(myMessage)
                }
            }
        }
        
        // Make call to populate Messages with full details
        
        var tempMessages: [gmailMessage] = Array()
        
        for myMessage in myMessages
        {
            myMessage.populateMessage(myGmailData)
            if myMessage.mySubject != "DELETEME"
            {
                tempMessages.append(myMessage)
            }
        }

        myMessages = tempMessages
    }
    
    func listMessages()
    {
        for myMessage in myMessages
        {
            print("id = \(myMessage.id) - subject - \(myMessage.subject)")
            print("from = \(myMessage.from) - to - \(myMessage.to)")
            print("sent = \(myMessage.dateReceived)")
            
            
            print("\n\n")
        }
    }
}

#if os(iOS)
class gmailData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, GIDSignInUIDelegate, URLSessionDelegate
{
    // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
    fileprivate let CLIENT_ID = "344184320417-h2nr89gi0ji02tbcs7f7kpj0kevuhq6f.apps.googleusercontent.com"
    fileprivate let gmailSecret = "USKddrDHh2aL6C2rzQGmrYku"
    fileprivate let kKeychainItemName = "OAuth Sample: Google Mail"
    fileprivate let kShouldSaveInKeychainKey = "shouldSaveInKeychain"
    fileprivate var mySourceViewController: UIViewController!
    
    fileprivate var auth: GIDAuthentication!
    fileprivate var currentUser: GIDGoogleUser!
    
    fileprivate var myInString: String = ""
    fileprivate var myQueryType: String = ""
    
    var sourceViewController: UIViewController
    {
        get
        {
            return mySourceViewController
        }
        set
        {
            mySourceViewController = newValue
        }
    }
  
    override init()
    {
        super.init()
        notificationCenter.addObserver(self, selector: #selector(gmailData.gmailSignedIn(_:)), name: NotificationGmailSignedIn, object: nil)
    }
    
    func shouldSaveInKeychain() -> Bool
    {
        let defaults: UserDefaults = UserDefaults.standard
        let flag = defaults.bool(forKey: kShouldSaveInKeychainKey)
        return flag
    }
    
    func connectToGmail()
    {
        if currentUser == nil
        {
            GIDSignIn.sharedInstance().uiDelegate = self
                
            GIDSignIn.sharedInstance().clientID = CLIENT_ID
            GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/gmail.readonly"]
                
                // Uncomment to automatically sign in the user.
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func getData(_ inURLString: String) -> String
    {
        var myReturnString: String = ""
        
        // Swap userId for the userd ID
        
        let escapedURL: String = inURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let url: URL = URL(string: escapedURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        if currentUser != nil
        {
            request.setValue("Bearer \(GIDSignIn.sharedInstance().currentUser.authentication.accessToken!)", forHTTPHeaderField: "Authorization")
            // Send the HTTP request
                let sem = DispatchSemaphore(value: 0);
                
                URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
                    
                    let httpResponse = response as? HTTPURLResponse
                    let status = httpResponse!.statusCode

                    if status == 200
                    {
                        // this means data was retrieved OK
                        myReturnString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                    }
                    else if status == 201
                    {
                        print("gmailData: Page created!")
                    }
                    else
                    {
                        print("gmailData: getData: There was an error accessing the gmailData data. Response code: \(status)")
                    }
                    sem.signal()
                }.resume()
                sem.wait()
        }
        return myReturnString
    }
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!)
    {
     //   myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!)
    {
        mySourceViewController.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!)
    {
        mySourceViewController.dismiss(animated: true, completion: nil)
    }
    
    func gmailSignedIn(_ notification: Notification)
    {
        currentUser = GIDSignIn.sharedInstance().currentUser
        if mySourceViewController is GTDInboxViewController
        {
            notificationCenter.post(name: NotificationGmailInboxConnected, object: nil)
        }
        else
        {
            notificationCenter.post(name: NotificationGmailConnected, object: nil)
        }
    }
}

#else
      
    class gmailData: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate
    {
        // Set the CLIENT_ID value to be the one you get from http://manage.dev.live.com/
        private let CLIENT_ID = "344184320417-h2nr89gi0ji02tbcs7f7kpj0kevuhq6f.apps.googleusercontent.com"
        private let gmailSecret = "USKddrDHh2aL6C2rzQGmrYku"
        private let kKeychainItemName = "Contacts Dashboard Gmail"
        private let kShouldSaveInKeychainKey = "shouldSaveInKeychain"
        
        private var auth: GTMOAuth2Authentication!
        private var currentUser: String = ""
        
        private var myInString: String = ""
        private var myQueryType: String = ""
        
        private let scopes = [kGTLAuthScopeGmailReadonly]
        private let service = GTLServiceGmail()
        private var myParentViewController: NSViewController!
        
        init(parentViewController: NSViewController)
        {
            super.init()
            
            myParentViewController = parentViewController
            
            if let auth = GTMOAuth2WindowController.authForGoogleFromKeychainForName(
                kKeychainItemName,
                clientID: CLIENT_ID,
                clientSecret: gmailSecret)
            {
                service.authorizer = auth
            }
            
            if let authorizer = service.authorizer,
                let canAuth = authorizer.canAuthorize, canAuth
            {
                fetchLabels()
            }
            else
            {
                let myStart = myParentViewController.storyboard?.instantiateControllerWithIdentifier("GTMOAuth2Window") as! GTMOAuth2WindowController
                
                myStart.showWindow(myStart)
            }
        }
        
        // Construct a query and get a list of upcoming labels from the gmail API
        func fetchLabels()
        {
            let query = GTLQueryGmail.queryForUsersLabelsList()
            service.executeQuery(query,
                delegate: self,
                didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
            )
        }
        
        // Display the labels in the UITextView
        func displayResultWithTicket(ticket : GTLServiceTicket,
            finishedWithObject labelsResponse : GTLGmailListLabelsResponse,
            error : NSError?)
        {
                
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
                
            var labelString = ""
                
            if !labelsResponse.labels.isEmpty
            {
                labelString += "Labels:\n"
                for label in labelsResponse.labels as! [GTLGmailLabel]
                {
                    labelString += "\(label.name)\n"
                }
            }
            else
            {
                labelString = "No labels found."
            }
        }
        
        // Creates the auth controller for authorizing access to Gmail API
        private func createAuthController() -> GTMOAuth2WindowController
        {
            let scopeString = scopes.joinWithSeparator("")
          
            return GTMOAuth2WindowController(
                scope: scopeString,
                clientID: CLIENT_ID,
                clientSecret: gmailSecret,
                keychainItemName: kKeychainItemName,
                resourceBundle: nil
            )
        }
        
        // Handle completion of the authorization process, and update the Gmail API
        // with the new credentials.
        func viewController(vc : NSViewController,
            finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?)
        {
                
            if let error = error
            {
                service.authorizer = nil
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
                
            service.authorizer = authResult
            myParentViewController.dismissViewController(vc)
        }
        
        // Helper for showing an alert
        func showAlert(title : String, message: String)
        {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = message
            alert.addButtonWithTitle("OK")
            
            let _ = alert.runModal()
        }
        
        func getData(inURLString: String) -> String
        {
            return ""
        }
}
    
#endif
