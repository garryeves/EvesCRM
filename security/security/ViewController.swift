//
//  ViewController.swift
//  security
//
//  Created by Garry Eves on 9/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {

//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }

    override func viewDidLoad() {
        if let accessToken = AccessToken.current
        {
print("Already logged in")
        }
        else
        {
            let myLoginButton = UIButton(type: .custom)
            myLoginButton.backgroundColor = UIColor.darkGray
            myLoginButton.frame = CGRect(x:0, y:0, width:180, height:40);
            myLoginButton.center = view.center;
            myLoginButton.setTitle("Login Using Facebook", for: .normal)
            // Handle clicks on the button
            myLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)

            view.addSubview(myLoginButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func loginButtonClicked()
    {
        let loginManager = LoginManager()
        loginManager.logIn([ ReadPermission.publicProfile, ReadPermission.email ], viewController: self)
        { loginResult in
            switch loginResult
            {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in!")
            }
        }
    }
}

