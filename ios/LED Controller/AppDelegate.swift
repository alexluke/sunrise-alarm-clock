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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        btManager = CBCentralManager(delegate: self, queue: nil)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if (central.state == CBCentralManagerState.PoweredOn) {
            currentAlert = UIAlertView(title: "Connecting...", message: nil, delegate: self, cancelButtonTitle: nil)
            currentAlert?.show()
            
            NSLog("Starting scan")
            central.scanForPeripheralsWithServices([CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")], options: nil)
        } else {
            currentAlert = UIAlertView(title: "Bluetooth Unavailable", message: nil, delegate: self, cancelButtonTitle: nil)
            currentAlert?.show()
        }
    }

    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        NSLog("Discovered peripheral")
        central.stopScan()
        
        self.peripheral = peripheral
        central.connectPeripheral(self.peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        NSLog("Connected!")
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")])
        
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        NSLog("Error connecting: %s", error)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        NSLog("Discovered %d services", peripheral.services.count)
        
        // Only interested in sending data at the moment
        peripheral.discoverCharacteristics([CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")], forService: peripheral.services[0] as CBService)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        NSLog("Discovered %d characteristics", service.characteristics.count)
        
        txCharacteristic =  service.characteristics[0] as? CBCharacteristic
        
        // Finally done connecting
        currentAlert?.dismissWithClickedButtonIndex(0, animated: true)
    }
    
    func writeData(data: NSData) {
        NSLog("Sending %d bytes", data.length)
        
        peripheral?.writeValue(data, forCharacteristic: txCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
}

