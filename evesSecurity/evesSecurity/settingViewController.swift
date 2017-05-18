//
//  settingViewController.swift
//  evesSecurity
//
//  Created by Garry Eves on 15/5/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class settingsViewController: UIViewController, UIPopoverPresentationControllerDelegate
{
    @IBOutlet weak var btnTeam: UIButton!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnPerAddInfo: UIButton!
    
    override func viewDidLoad()
    {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnTeam(_ sender: UIButton)
    {
        let orgEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "orgEdit") as! orgEditViewController
        orgEditViewControl.workingOrganisation = currentUser!.currentTeam
        self.present(orgEditViewControl, animated: true, completion: nil)
    }

    @IBAction func btnUser(_ sender: UIButton)
    {
        let userEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "userForm") as! userFormViewController
        userEditViewControl.workingUser = currentUser
        self.present(userEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnPassword(_ sender: UIButton)
    {
        let passwordView = loginStoryboard.instantiateViewController(withIdentifier: "setPassword") as! setPasswordViewController
        passwordView.modalPresentationStyle = .popover
        
        let popover = passwordView.popoverPresentationController!
        popover.delegate = self
        popover.sourceView = sender
        popover.sourceRect = sender.bounds
        popover.permittedArrowDirections = .any
        passwordView.preferredContentSize = CGSize(width: 600,height: 500)
        
        self.present(passwordView, animated: true, completion: nil)
    }
    
    @IBAction func btnPerAddInfo(_ sender: UIButton)
    {
        let addPerInfoViewControl = personStoryboard.instantiateViewController(withIdentifier: "AddPersonInfo") as! addPerInfoMaintenanceViewController
        self.present(addPerInfoViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
}

