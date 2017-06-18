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
    @IBOutlet weak var btnPassword: UIButton!
    @IBOutlet weak var btnPerAddInfo: UIButton!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnDropbown: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        refreshScreen()
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
    
    @IBAction func btnDropdowns(_ sender: UIButton)
    {
        let dropdownEditViewControl = loginStoryboard.instantiateViewController(withIdentifier: "dropdownMaintenance") as! dropdownMaintenanceViewController
        self.present(dropdownEditViewControl, animated: true, completion: nil)
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        
    }
}

