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
let NotificationIAPSPurchased = Notification.Name("NotificationIAPSPurchased")

let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")

public enum serviceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

public enum Result<T> {
    case failure(serviceError)
    case success(T)
}

private let IAPDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
    
    return formatter
}()

public typealias SessionId = String

public struct PaidSubscription {
    
    public let productId: String
    public let purchaseDate: Date
    public let expiresDate: Date
    
    public var isActive: Bool {
        // is current date between purchaseDate and expiresDate?
        return (purchaseDate...expiresDate).contains(Date())
    }
    
    init?(json: [String: Any]) {
        guard
            let productId = json["product_id"] as? String,
            let purchaseDateString = json["purchase_date"] as? String,
            let purchaseDate = IAPDateFormatter.date(from: purchaseDateString),
            let expiresDateString = json["expires_date"] as? String,
            let expiresDate = IAPDateFormatter.date(from: expiresDateString)
            else {
                return nil
        }

        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expiresDate = expiresDate
    }
}

public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void

public struct Session {
    public let id: SessionId
    public var paidSubscriptions: [PaidSubscription]
    
    public var currentSubscription: PaidSubscription? {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateStringFormatter.date(from: "2016-01-01")!
       
        let activeSubscriptions = paidSubscriptions.filter { $0.purchaseDate >= startDate }
        
        let sortedByMostRecentPurchase = activeSubscriptions.sorted { $0.purchaseDate > $1.purchaseDate }
        
        return sortedByMostRecentPurchase.first
    }
    
    public var receiptData: Data
    public var parsedReceipt: [String: Any]
    
    init(receiptData: Data, parsedReceipt: [String: Any]) {
        id = UUID().uuidString
        self.receiptData = receiptData
        self.parsedReceipt = parsedReceipt
        
        if let receipt = parsedReceipt["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? Array<[String: Any]> {
            var subscriptions = [PaidSubscription]()
            for purchase in purchases {

                if let paidSubscription = PaidSubscription(json: purchase) {
                    subscriptions.append(paidSubscription)
                }
            }
            paidSubscriptions = subscriptions
        } else {
            paidSubscriptions = []
        }
    }
    
}

// MARK: - Equatable

extension Session: Equatable {
    public static func ==(lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}

class IAPHandler: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    fileprivate let sharedSecret = "638828c8d37a483abf0c7207e8908183"
    fileprivate let IAPConsumableID = "TestIAP"
    fileprivate let IAPSubscriptionID1m5 = "com.garryeves.1m5"
    fileprivate let IAPSubscriptionID1m10 = "com.garryeves.1m10"
    fileprivate let IAPSubscriptionID1m20 = "com.garryeves.1m20"
    fileprivate let IAPSubscriptionID1y5 = "com.garryeves.1y5"
    fileprivate let IAPSubscriptionID1y10 = "com.garryeves.1y10"
    fileprivate let IAPSubscriptionID1y20 = "com.garryeves.1y20"
    fileprivate let IAPSubscriptionIDtest = "com.garryeves.test"
    
    fileprivate var productID = ""
    var productRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    fileprivate var myPuchasedExpiryDate: Date = Date()
    fileprivate var myPurchasedUsers: Int = 1

    private var sessions = [SessionId: Session]()
    
    var hasReceiptData: Bool
    {
        return loadReceipt() != nil
    }
    
    var currentSessionId: String?
    {
        didSet
        {
            NotificationCenter.default.post(name: sessionIdSetNotification, object: currentSessionId)
        }
    }
    
    var currentSubscription: PaidSubscription?
    
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
    
    var purchasedExpiryDate: Date
    {
        return myPuchasedExpiryDate
    }
    
    var purchasedUsers: Int
    {
        return myPurchasedUsers
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
        let productIdentifiers = Set([IAPConsumableID,
                                        IAPSubscriptionID1m5,
                                        IAPSubscriptionID1m10,
                                        IAPSubscriptionID1m20,
                                        IAPSubscriptionID1y5,
                                        IAPSubscriptionID1y10,
                                        IAPSubscriptionID1y20,
                                        IAPSubscriptionIDtest
            ]
        )
        
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }
    
    var canMakePurchases: Bool
    {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseProduct(_ indexItem: Int)
    {
        let product = iapProducts[indexItem]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        
        productID = product.productIdentifier
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        if response.products.count > 0
        {
            iapProducts = response.products
        }
        
        notificationCenter.post(name: NotificationIAPSListed, object: nil)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error)
    {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
//        productsRequestCompletionHandler?(false, nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            if let trans = transaction as SKPaymentTransaction?
            {
                switch trans.transactionState
                {
                    case .purchased:
                        SKPaymentQueue.default().finishTransaction(transaction)
                        
                        uploadReceipt { (success) in
                            DispatchQueue.main.async
                            {
                                self.processSuccess()
                                notificationCenter.post(name: NotificationIAPSPurchased, object: nil)
                            }
                        }
                        
                        break
                        
                    case .failed:
                        SKPaymentQueue.default().finishTransaction(transaction)
                        myPuchasedExpiryDate = Date()
                        myPurchasedUsers = 1
                        notificationCenter.post(name: NotificationIAPSPurchased, object: nil)
                        
                        break
                    case .restored:
                        SKPaymentQueue.default().finishTransaction(transaction)
                        myPuchasedExpiryDate = Date()
                        myPurchasedUsers = 1
                        notificationCenter.post(name: NotificationIAPSPurchased, object: nil)
                        
                        break
                    
                    default:
                        break
                }
            }
        }
    }
    
    func processSuccess()
    {
print("product = \(currentSubscription!.productId) purchase date = \(currentSubscription!.purchaseDate) expires date = \(currentSubscription!.expiresDate) isactive = \(currentSubscription!.isActive)")
        
        switch currentSubscription!.productId
        {
            case IAPConsumableID:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 15
                
            case IAPSubscriptionID1m5:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 5
                
            case IAPSubscriptionID1m10:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 10
                
            case IAPSubscriptionID1m20:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 20
                
            case IAPSubscriptionID1y5:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 5
                
            case IAPSubscriptionID1y10:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 10
                
            case IAPSubscriptionID1y20:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 20
                
            case IAPSubscriptionIDtest:
                myPuchasedExpiryDate = currentSubscription!.expiresDate
                myPurchasedUsers = 5
                
            default:
                myPuchasedExpiryDate = Date()
                myPurchasedUsers = 1
                
                print("processSuccess - unknown product ID = \(currentSubscription!.productId)")
        }
 
        myPuchasedExpiryDate = Date().add(.day, amount: 7)
        updateSubscriptions(expiryDate: myPuchasedExpiryDate, numUsers: myPurchasedUsers)
    }
    
    func checkReceipt()
    {
        uploadReceipt { (success) in
            DispatchQueue.main.async
            {
                self.processSuccess()
            }
        }
    }
    
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil)
    {
        if let receiptData = loadReceipt()
        {
            upload(receipt: receiptData) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result
                {
                    case .success(let result):
                        strongSelf.currentSessionId = result.sessionId

                        strongSelf.currentSubscription = result.currentSubscription
                        completion?(true)
                    case .failure(let error):
                        print("🚫 Receipt Upload Failed: \(error)")
                        completion?(false)
                }
            }
        }
    }
    
    private func loadReceipt() -> Data?
    {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }

        do
        {
            let data = try Data(contentsOf: url)
            return data
        }
        catch
        {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Trade receipt for session id
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion)
    {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": sharedSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!   // chnage sandbox to buy when ready for prod
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error
            {
                completion(.failure(.other(error)))
            }
            else if let responseData = responseData
            {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                let session = Session(receiptData: data, parsedReceipt: json)
                
                self.sessions[session.id] = session
                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
                completion(.success(result))
            }
        }
        
        task.resume()
    }
}
