//
//  ContactDetails.swift
//  EvesCRM
//
//  Created by Garry Eves on 16/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

//This file is used to populate Contact details table

import Foundation
import Contacts
    
let contactDataArray = [
      CNContactNamePrefixKey,
      CNContactGivenNameKey,
      CNContactMiddleNameKey,
      CNContactFamilyNameKey,
      CNContactPreviousFamilyNameKey,
      CNContactNameSuffixKey,
      CNContactNicknameKey,
      CNContactOrganizationNameKey,
      CNContactDepartmentNameKey,
      CNContactJobTitleKey,
      CNContactBirthdayKey,
      CNContactNoteKey,
      CNContactTypeKey,
      CNContactPhoneNumbersKey,
      CNContactEmailAddressesKey,
      CNContactPostalAddressesKey,
      CNContactDatesKey,
      CNContactUrlAddressesKey,
      CNContactRelationsKey,
      CNContactSocialProfilesKey,
      CNContactInstantMessageAddressesKey,
      CNContactPhoneticGivenNameKey,
      CNContactPhoneticMiddleNameKey,
      CNContactPhoneticFamilyNameKey,
      CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
    ] as [Any]

class iOSContact
{
    fileprivate var myFacebookID: String = ""
    fileprivate var myLinkedInID: String = ""
    fileprivate var myTwitterID: String = ""
    fileprivate var tableContents:[TableData] = [TableData]()
    fileprivate var myContactRecord: CNContact!
    fileprivate var myEmailAddresses: [String]!
    fileprivate var myFullName: String = ""
    
    var facebookID: String
        {
        get
        {
            return myFacebookID
        }
    }
    
    var linkedInID: String
        {
        get
        {
            return myLinkedInID
        }
    }
    
    var twitterID: String
        {
        get
        {
            return myTwitterID
        }
    }
    
    var tableData: [TableData]
        {
        get
        {
            return tableContents
        }
    }
    
    var contactRecord: CNContact
        {
        get
        {
            return myContactRecord
        }
    }
    
    var emailAddresses: [String]
        {
        get
        {
            return myEmailAddresses
        }
    }
    
    var fullName: String
        {
        get
        {
            return myFullName
        }
    }
    
    init (contactRecord: CNContact)
    {
        var myString: String = ""
        
        myContactRecord = contactRecord
        tableContents.removeAll()
        myEmailAddresses = Array()

        myFullName = CNContactFormatter.string(from: contactRecord, style: CNContactFormatterStyle.fullName)!
        
/*        myFullName = "\(myContactRecord.givenName)"
        
        if myContactRecord.middleName != ""
        {
            myFullName += " \(myContactRecord.middleName)"
        }

        if myContactRecord.familyName != ""
        {
            myFullName += " \(myContactRecord.familyName)"
        }
*/
        myString = "Name : \(myFullName)"
        writeRowToArray(myString, table: &tableContents)

        for myAddress in myContactRecord.postalAddresses
        {
           if myAddress.label != nil
           {
                switch myAddress.label!
                {
                    case CNLabelHome :
                        myString = "Home : "

                    case CNLabelWork :
                        myString = "Work : "
                    
                    case CNLabelOther :
                        myString = "Other : "
                    
                    default :
                        myString = "Unknown Address : \(myAddress.label!) : "
                }
                
                let myAddressValue = myAddress.value 
                if myAddressValue.street != ""
                {
                    myString += "\(myAddressValue.street)"
                }
                if myAddressValue.city != ""
                {
                    myString += "\n\(myAddressValue.city)"
                }
                
                if myAddressValue.state != ""
                {
                    myString += "\n\(myAddressValue.state)"
                }
                if myAddressValue.country != ""
                {
                    myString += "\n\(myAddressValue.country)"
                }
                if myAddressValue.postalCode != ""
                {
                    myString += "\n\(myAddressValue.postalCode)"
                }
                
                writeRowToArray(myString, table: &tableContents)
            }
        }
        
        if myContactRecord.organizationName != ""
        {
            myString = "Organization : \(myContactRecord.organizationName)"
            writeRowToArray(myString, table: &tableContents)
        }
        
        if myContactRecord.departmentName != ""
        {
            myString = "Dept : \(myContactRecord.departmentName)"
            writeRowToArray(myString, table: &tableContents)
        }
        
        if myContactRecord.jobTitle != ""
        {
            myString = "Job Title : \(myContactRecord.jobTitle)"
            writeRowToArray(myString, table: &tableContents)
        }
        
        for myPhone in myContactRecord.phoneNumbers
        {
            if myPhone.label != nil
            {
                switch myPhone.label!
                {
                    case CNLabelHome :
                        myString = "Home : "
                        
                    case CNLabelWork :
                        myString = "Work : "
                        
                    case CNLabelOther :
                        myString = "Other : "
                        
                    case CNLabelPhoneNumberiPhone :
                        myString = "iPhone : "
                    
                    case CNLabelPhoneNumberMobile :
                        myString = "Mobile : "
                    
                    case CNLabelPhoneNumberMain :
                        myString = "Main : "

                    case CNLabelPhoneNumberHomeFax :
                        myString = "Home Fax : "

                    case CNLabelPhoneNumberWorkFax :
                        myString = "Work Fax : "

                    case CNLabelPhoneNumberOtherFax :
                        myString = "Other Fax : "
                    
                    case CNLabelPhoneNumberPager :
                        myString = "Pager : "

                    default :
                        myString = "Unknown phone number : \(myPhone.label!) : "
                }
                let myPhoneValue = myPhone.value 
                myString += "\(myPhoneValue.stringValue)"
                
                writeRowToArray(myString, table: &tableContents)
            }
        }

        for myEmail in myContactRecord.emailAddresses
        {
            if myEmail.label != nil
            {
                switch myEmail.label!
                {
                    case CNLabelEmailiCloud :
                        myString = "iCloud Email : "

                    case CNLabelHome :
                        myString = "Home Email : "
                    
                    case CNLabelWork :
                        myString = "Work Email : "
                    
                    case CNLabelOther :
                        myString = "Other Email : "
                    
                    default :
                        myString = "Unknown email address : \(myEmail.label!) : "
                }
                let myEmailValue = myEmail.value as String
                myString += "\(myEmailValue)"
                
                writeRowToArray(myString, table: &tableContents)
                
                myEmailAddresses.append(myEmailValue)
            }
        }

        if myContactRecord.note != ""
        {
            myString = "Note : \(myContactRecord.note)"
            writeRowToArray(myString, table: &tableContents)
        }
        
        if myContactRecord.birthday?.date != nil
        {
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateStyle = .long

            myString = "Birthday : \(myDateFormatter.string(from: (myContactRecord.birthday?.date)!))"
            writeRowToArray(myString, table: &tableContents)
        }
        
        for myIM in myContactRecord.instantMessageAddresses
        {
            switch myIM.value.service
            {
                case CNInstantMessageServiceAIM :
                    myString = "AIM : "

                case CNInstantMessageServiceFacebook :
                    myString = "Facebook : "

                case CNInstantMessageServiceGaduGadu :
                    myString = "GaduGadu : "

                case CNInstantMessageServiceGoogleTalk :
                    myString = "Google Talk : "

                case CNInstantMessageServiceICQ :
                    myString = "ICQ : "

                case CNInstantMessageServiceJabber :
                    myString = "Jabber : "

                case CNInstantMessageServiceMSN :
                    myString = "MSN : "

                case CNInstantMessageServiceQQ :
                    myString = "QQ : "

                case CNInstantMessageServiceSkype :
                    myString = "SkyPE : "

                case CNInstantMessageServiceYahoo :
                    myString = "Yahoo : "

                default :
                    myString = "Unknown IM address : \(myIM.label!) : "
            }
            let myIMValue = myIM.value 
            myString += "\(myIMValue.username)"
            
            writeRowToArray(myString, table: &tableContents)
        }

        for mySocial in myContactRecord.socialProfiles
        {
            switch mySocial.value.service
            {
                case CNSocialProfileServiceFacebook :
                    myString = "Facebook : "
                
                case CNSocialProfileServiceFlickr :
                    myString = "Flickr : "
                
                case CNSocialProfileServiceLinkedIn :
                    myString = "LinkedIN : "
                
                case CNSocialProfileServiceMySpace :
                    myString = "MySpace : "
                
                case CNSocialProfileServiceSinaWeibo :
                    myString = "Sina Weibo : "
                
                case CNSocialProfileServiceTencentWeibo :
                    myString = "Tencent Weibo : "
                
                case CNSocialProfileServiceTwitter :
                    myString = "Twitter : "
                
                case CNSocialProfileServiceYelp :
                    myString = "Yelp : "
                
                case CNSocialProfileServiceGameCenter :
                    myString = "GameCenter : "
                
                default :
                    myString = "Unknown Social address : \(mySocial.value.service) : "
            }
            let mySocialValue = mySocial.value 
            myString += "\(mySocialValue.username)"
            
            writeRowToArray(myString, table: &tableContents)
        }

        for myURL in myContactRecord.urlAddresses
        {
            if myURL.label != nil
            {
                switch myURL.label!
                {
                    case CNLabelURLAddressHomePage :
                        myString = "Home Page : "
                    
                    default :
                        myString = "Unknown URL address : \(myURL.label!) : "
                }
                let myURLValue = myURL.value as String
                myString += "\(myURLValue)"
                
                writeRowToArray(myString, table: &tableContents)
            }
        }

        if myContactRecord.nickname != ""
        {
            myString = "Nickname : \(myContactRecord.nickname)"
            writeRowToArray(myString, table: &tableContents)
        }
    }
}

func findPersonRecordByID(_ recordID: String) -> CNContact!
{
    var person: CNContact!
    
    //  there may be a better way to do this, but it works.
    do
    {
        let myPeople = try adbk.unifiedContacts(matching: CNContact.predicateForContacts(withIdentifiers: [recordID]), keysToFetch: contactDataArray as! [CNKeyDescriptor])
        
        if myPeople.count > 0
        {
            person = myPeople[0]
        }
//        person = try adbk.unifiedContactsMatchingPredicate(CNContact.predicateForContactsWithIdentifiers([recordID]), keysToFetch: contactDataArray)[0]
    }
    catch let error as NSError
    {
        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        print("Failure to save context: \(error)")
    }
    
    return person
}


func findPersonRecord(_ name: String) -> CNContact!
{
    var person: CNContact!

    //  there may be a better way to do this, but it works.
    do
    {
        let myPeople = try adbk.unifiedContacts(matching: CNContact.predicateForContacts(matchingName: name), keysToFetch: contactDataArray as! [CNKeyDescriptor])
        
        if myPeople.count > 0
        {
            person = myPeople[0]
        }
//        person = try adbk.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName(name), keysToFetch: contactDataArray)[0]
    }
    catch let error as NSError
    {
        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        
        print("Failure to save context: \(error)")
    }
    
    return person
}

func findPersonbyEmail(_ searchEmail: String) -> CNContact!
{
    //  there may be a better way to do this, but it works.
    var person: CNContact!
    
    let fetch = CNContactFetchRequest(keysToFetch: contactDataArray as! [CNKeyDescriptor])
  //  fetch.keysToFetch = [CNContactEmailAddressesKey] // Enter the keys for the values you want to fetch here
    fetch.unifyResults = true
    fetch.predicate = nil // Set this to nil will give you all Contacts
    do
    {
        _ = try adbk.enumerateContacts(with: fetch, usingBlock:
                {
                    contact, cursor in
                    // Do something with the result...for example put it in an array of CNContacts as shown below
                    let theContact = contact as CNContact
                    
                    for myEmail in contact.emailAddresses
                    {
                        if myEmail.value as String == searchEmail
                        {
                            person = theContact
                            break
                        }
                    }
                })
        
    }
    catch
    {
        print("Error")
    }

    return person
}
    
func createAddressBook() -> Bool
{
    if adbk != nil
    {
        return true
    }
    
    let sem = DispatchSemaphore(value: 0)

    let myAdbk = CNContactStore()
    myAdbk.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in

        sem.signal()
    }
    
    sem.wait()

    adbk = myAdbk
        
    return true
}
    
func determineAddressBookStatus() -> Bool
{
    var retVal: Bool = false
    
    let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    
    switch authorizationStatus
    {
        case .authorized:
            retVal = true
        
        case .denied:
            retVal = false
        
        case .notDetermined:
            retVal = false
        
        default:
            retVal = false

    }
    
    return retVal
}

