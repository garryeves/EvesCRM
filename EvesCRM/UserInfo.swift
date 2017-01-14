/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CloudKit

class UserInfo {
  
  let container : CKContainer
  var userRecordID : CKRecordID!
  var contacts = [AnyObject]()
  
  init (container : CKContainer) {
    self.container = container;
  }
  
//  func loggedInToICloud(completion : (accountStatus : CKAccountStatus, error : NSError!) -> ()) {
    //replace this stub
//    completion(accountStatus: .CouldNotDetermine, error: nil)
//  }
    
    func loggedInToICloud() -> CKAccountStatus
    {
        var returnStatus: CKAccountStatus!
        
        let sem = DispatchSemaphore(value: 0);
        
        container.accountStatus(completionHandler: {(accountStatus: CKAccountStatus, error: Error? ) in
            returnStatus = accountStatus
            
            sem.signal()
        })
        
        sem.wait()
        
        return returnStatus
    }

  
  func userID(_ completion: @escaping (_ userRecordID: CKRecordID?, _ error: Error?)->()) {
    if userRecordID != nil {
      completion(userRecordID, nil)
    } else {
      self.container.fetchUserRecordID() {
        recordID, error in
        if recordID != nil {
          self.userRecordID = recordID
        }
        completion(recordID, error as Error?)
      }
    }
  }
  
  func userInfo(_ recordID: CKRecordID!,
    completion:(_ userInfo: CKUserIdentity?, _ error: Error?)->()) {
      //replace this stub
      completion(nil, nil)
  }
  
  func requestDiscoverability(_ completion: (_ discoverable: Bool) -> ()) {
    //replace this stub
    completion(false)
  }
  
  func userInfo(_ completion: @escaping (_ userInfo: CKUserIdentity?, _ error: Error?)->()) {
NSLog("gre userinfo")
    requestDiscoverability() { discoverable in
      self.userID() { recordID, error in
        if error != nil {
          completion(nil, error)
        } else {
          self.userInfo(recordID, completion: completion )
        }
      }
    }
  }
  
  func findContacts(_ completion: (_ userInfos:[AnyObject]?, _ error: Error?)->()) {
    completion([CKRecordID](), nil)
  }
}

