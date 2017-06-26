//
//  IAPViewController.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import UIKit

class IAPViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tblIAPs: UITableView!

    fileprivate var iap: IAPHandler!
    
    override func viewDidLoad()
    {
        notificationCenter.addObserver(self, selector: #selector(self.refreshScreen), name: NotificationIAPSListed, object: nil)
        
        iap = IAPHandler()
        iap.listPurchases()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return iap.productsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier:"cellIAP", for: indexPath) as! IAPItem
            
        cell.lblDescription.text = iap.productNames[indexPath.row]
        cell.lblCost.text = iap.productCost[indexPath.row]
        cell.entryID = indexPath.row
        return cell

    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func refreshScreen()
    {
        notificationCenter.removeObserver(NotificationIAPSListed)
        tblIAPs.reloadData()
    }
}

class IAPItem: UITableViewCell
{
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var btnSubscribe: UIButton!
    
    var entryID: Int!
    
    @IBAction func btnSubscribe(_ sender: UIButton)
    {
    }
}
