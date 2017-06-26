//
//  IAPClass.swift
//  Shift Dashboard
//
//  Created by Garry Eves on 26/6/17.
//  Copyright © 2017 Garry Eves. All rights reserved.
//

import Foundation
import StoreKit

let NotificationIAPSListed = Notification.Name("NotificationIAPSListed")

class IAPHandler: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    fileprivate let consumableID = "TestIAP"
    fileprivate let subscriptionID = "1m5"
    
    fileprivate var productID = ""
    var productRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()

    var productsCount: Int
    {
        return iapProducts.count
    }
    
    var productNames: [String]
    {
        var returnArray: [String] = Array()
        
        for IAPItem in iapProducts
        {
            returnArray.append(IAPItem.localizedDescription)
        }
        
        return returnArray
    }
    
    var productCost: [String]
    {
        var returnArray: [String] = Array()
        
        for IAPItem in iapProducts
        {
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = IAPItem.priceLocale
            let priceStr = numberFormatter.string(from: IAPItem.price)
            
            returnArray.append(priceStr!)
        }
        
        return returnArray
    }
    
    func listPurchases()
    {
        let productIdentifiers = Set([consumableID,
                                        subscriptionID]
        )
        
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        print("Got list of products.")
        if response.products.count > 0
        {
            iapProducts = response.products
            
            for IAPItem in iapProducts
            {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = IAPItem.priceLocale
                let priceStr = numberFormatter.string(from: IAPItem.price)
                
                print("Product = \(IAPItem.localizedDescription) for \(priceStr!)")
            }
        }
        
        notificationCenter.post(name: NotificationIAPSListed, object: nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("Failed to load list of products.")
//        print("Error: \(error.localizedDescription)")
//        productsRequestCompletionHandler?(false, nil)
//        clearRequestAndHandler()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        print("payment queue")
    }
}
