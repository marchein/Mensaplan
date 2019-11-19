//
//  MainTableViewController+NFC.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.11.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import Foundation
import CoreNFC
import UIKit

@available(iOS 13.0, *)
extension MainTableViewController: NFCTagReaderSessionDelegate {
    @IBAction func onClick(_ sender: Any) {
      guard NFCTagReaderSession.readingAvailable else {
           let alertController = UIAlertController(
               title: NSLocalizedString("NFC Not Supported", comment: ""),
               message: NSLocalizedString("This device doesn't support NFC tag scanning.", comment: ""),
               preferredStyle: .alert
           )
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alertController, animated: true, completion: nil)
           return
       }
       
        let session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
       session?.alertMessage = NSLocalizedString("Please hold your Mensa card near the NFC sensor.", comment: "")
       session?.begin()
   }
    
   func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if(tags.count != 1) {
            print("MULTIPLE TAGS! ABORT.")
            return
        }
        
        if case let NFCTag.miFare(tag) = tags.first! {
            
            session.connect(to: tags.first!) { (error: Error?) in
                if(error != nil) {
                    print("CONNECTION ERROR : " + error!.localizedDescription)
                    return
                }
                
                var idData = tag.identifier
                if(idData.count == 7) {
                    idData.append(UInt8(0))
                }
                let idInt = idData.withUnsafeBytes {
                    $0.load(as: Int.self)
                }
                
                print("CONNECTED TO CARD")
                print("CARD-TYPE:"+String(tag.mifareFamily.rawValue))
                print("CARD-ID hex:"+idData.hexEncodedString())
                
                var appIdBuff : [Int] = [];
                appIdBuff.append ((MainTableViewController.APP_ID & 0xFF0000) >> 16)
                appIdBuff.append ((MainTableViewController.APP_ID & 0xFF00) >> 8)
                appIdBuff.append  (MainTableViewController.APP_ID & 0xFF)
                
                // 1st command : select app
                self.send(
                    tag: tag,
                    data: Data(_: self.wrap(
                        command: 0x5a, // command : select app
                        parameter: [UInt8(appIdBuff[0]), UInt8(appIdBuff[1]), UInt8(appIdBuff[2])] // appId as byte array
                    )),
                    completion: { (data1) -> () in
                        
                        // 2nd command : read value (balance)
                        self.send(
                            tag: tag,
                            data: Data(_: self.wrap(
                                command: 0x6c, // command : read value
                                parameter: [MainTableViewController.FILE_ID] // file id : 1
                            )),
                            completion: { (data2) -> () in
                                
                                // parse balance response
                                var trimmedData = data2
                                trimmedData.removeLast()
                                trimmedData.removeLast()
                                trimmedData.reverse()
                                let currentBalanceRaw = self.byteArrayToInt(
                                    buf: [UInt8](trimmedData)
                                )
                                let currentBalanceValue : Double = self.intToEuro(value:currentBalanceRaw)
                                
                                // 3rd command : read last trans
                                self.send(
                                    tag: tag,
                                    data: Data(_: self.wrap(
                                        command: 0xf5, // command : get file settings
                                        parameter: [MainTableViewController.FILE_ID] // file id : 1
                                    )),
                                    completion: { (data3) -> () in
                                        
                                        // parse last transaction response
                                        var lastTransactionValue : Double = 0
                                        let buf = [UInt8](data3)
                                        if(buf.count > 13) {
                                            let lastTransactionRaw = self.byteArrayToInt(
                                                buf:[ buf[13], buf[12] ]
                                            )
                                            lastTransactionValue = self.intToEuro(value:lastTransactionRaw)
                                        }
                                        
                                        // insert into history
                                        self.db.insertRecord(
                                            balance: currentBalanceValue,
                                            lastTransaction: lastTransactionValue,
                                            date: self.getCurrentDate(),
                                            cardID: String(idInt)
                                        )
                                        
                                        // dismiss iOS NFC window
                                        session.invalidate()
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                )
                                
                            }
                        )
                        
                    }
                )
                
            }
        } else {
            print("INVALID CARD")
        }
    }
    
    func byteArrayToInt(buf:[UInt8]) -> Int {
        var rawValue : Int = 0
        for byte in buf {
            rawValue = rawValue << 8
            rawValue = rawValue | Int(byte)
        }
        return rawValue
    }
    
    func intToEuro(value:Int) -> Double {
        return (Double(value)/1000).rounded(toPlaces: 2)
    }
    
    func wrap(command: UInt8, parameter: [UInt8]?) -> [UInt8] {
        var buff : [UInt8] = []
        buff.append(0x90)
        buff.append(command)
        buff.append(0x00)
        buff.append(0x00)
        if(parameter != nil) {
            buff.append(UInt8(parameter!.count))
            for p in parameter! {
                buff.append(p)
            }
        }
        buff.append(0x00)
        return buff
    }
    
    func send(tag: NFCMiFareTag, data: Data, completion: @escaping (_ data: Data)->()) {
        print("COMMAND TO CARD => " + data.hexEncodedString())
        tag.sendMiFareCommand(commandPacket: data, completionHandler: { (data: Data, error: Error?) in
            if(error != nil) {
                print("COMMAND ERROR : " + error!.localizedDescription)
                return
            }
            print("CARD RESPONSE <= " + data.hexEncodedString())
            completion(data)
        })
    }
}
