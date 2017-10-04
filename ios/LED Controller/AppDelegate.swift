//
//  AppDelegate.swift
//  LED Controller
//
//  Created by Alex Luke on 3/11/15.
//  Copyright (c) 2015 Alex Luke. All rights reserved.
//

import UIKit
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    var window: UIWindow?
    var btManager: CBCentralManager?
    var currentAlert: UIAlertView?
    var peripheral: CBPeripheral?
    var txCharacteristic: CBCharacteristic?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        btManager = CBCentralManager(delegate: self, queue: nil)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            currentAlert = UIAlertView(title: "Connecting...", message: nil, delegate: self, cancelButtonTitle: nil)
            currentAlert?.show()
            
            NSLog("Starting scan")
            central.scanForPeripherals(withServices: [CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: nil)
        } else {
            currentAlert = UIAlertView(title: "Bluetooth Unavailable", message: nil, delegate: self, cancelButtonTitle: "OK")
            currentAlert?.show()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("Discovered peripheral")
        central.stopScan()
        
        self.peripheral = peripheral
        central.connect(self.peripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("Connected!")
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")])
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("Error connecting: %@", error! as NSError)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("Discovered %d services", peripheral.services!.count)
        
        // Only interested in sending data at the moment
        peripheral.discoverCharacteristics([CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")], for: peripheral.services![0] as CBService)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        NSLog("Discovered %d characteristics", service.characteristics!.count)
        
        txCharacteristic = service.characteristics![0]
        
        // Finally done connecting
        currentAlert?.dismiss(withClickedButtonIndex: 0, animated: true)
    }
    
    func writeData(_ data: Data) {
        NSLog("Sending %d bytes", data.count)
        
        peripheral?.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
}

