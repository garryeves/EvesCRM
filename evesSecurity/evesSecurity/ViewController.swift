//
//  ViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit

class ViewController: UIViewController {

    override func viewDidLoad() {
//        if let accessToken = AccessToken.current
//        {
//            print("Already logged in")
//            getEmailAddress()
//        }
//        else
//        {
//            let myLoginButton = UIButton(type: .custom)
//            myLoginButton.backgroundColor = UIColor.darkGray
//            myLoginButton.frame = CGRect(x:0, y:0, width:180, height:40);
//            myLoginButton.center = view.center;
//            myLoginButton.setTitle("Login Using Facebook", for: .normal)
//            // Handle clicks on the button
//            myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
//            
//            view.addSubview(myLoginButton)
//        }
//        
        let alf = UserItem(userID: 1)
  sleep(5)
        let encryptedText = alf.encryptText("Garry Was Here")
        
        alf.decryptText(encryptedText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loginButtonClicked()
    {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult
            {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
                
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("granted \(grantedPermissions.contains("email"))")
                print("Logged in user! \(loginResult)")
                print("accesstoken - \(accessToken)")
                print("user ID - \(accessToken.userId)")
                self.getEmailAddress()
            }
        }
    }

    func getEmailAddress()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters:  ["fields":"email,name"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if let fbData = result as? [String:Any]
                {
                    userName = fbData["name"] as! String
                    userEmail = fbData["email"] as! String
                    print(userName)
                    print(userEmail)
                }
            }
        })
    }


}

