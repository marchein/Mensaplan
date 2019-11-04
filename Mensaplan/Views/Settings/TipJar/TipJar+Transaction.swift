//
//  TipJar+Transaction.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension TipJarTableViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
                print(product)
            }
            productsArray = productsArray.reversed()
            
            hasData = true
            DispatchQueue.main.async {
                self.navigationController?.view.hideToastActivity()
                self.tableView.reloadData()
            }
        } else {
            print("There are no products.")
            DispatchQueue.main.async {
                self.navigationController?.view.hideToastActivity()
            }
            if response.invalidProductIdentifiers.count != 0 {
                print(response.invalidProductIdentifiers.description)
            }
        }
        
        
    }
    
    func startTransaction() {
        if transactionInProgress || productsArray.count < 1 {
            return
        }
        
        let payment = SKPayment(product: self.productsArray[self.selectedProductIndex]!)
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
        self.navigationController?.view.makeToastActivity(.center)
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                self.navigationController?.view.hideToastActivity()
                MensaplanApp.sharedDefaults.set(true, forKey: LocalKeys.hasTipped)
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                impact.impactOccurred()
                showMessage(title: "Erfolgreich Mensaplan unterstützt!", message: "Vielen Dank für Deine Unterstützung!", on: self)
            case SKPaymentTransactionState.failed:
                self.navigationController?.view.hideToastActivity()
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                showMessage(title: "Fehler", message: "Es ist ein Fehler beim Abschließen der Transaktion aufgetreten.", on: self)
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

