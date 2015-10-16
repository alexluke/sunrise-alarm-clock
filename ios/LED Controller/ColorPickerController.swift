//
//  ColorPickerController.swift
//  LED Controller
//
//  Created by Alex Luke on 3/11/15.
//  Copyright (c) 2015 Alex Luke. All rights reserved.
//

import UIKit

class ColorPickerController: UIViewController, RSColorPickerViewDelegate {
    
    @IBOutlet var colorPicker: RSColorPickerView!
    @IBOutlet var previewPatch: UIView!
    @IBOutlet var brightnessSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPicker.delegate = self
        
        let colorPreviewLayer = CALayer()
        previewPatch.layer.addSublayer(colorPreviewLayer)
    }
    
    override func viewDidLayoutSubviews() {
        let sublayer = previewPatch.layer.sublayers![0]
        sublayer.frame = CGRect(origin: CGPointZero, size: previewPatch.frame.size)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeColor() {
        self.updatePreview()
        
        var color = colorPicker.selectionColor
        let brightness = CGFloat(brightnessSlider.value)
        
        color = color.colorWithAlphaComponent(brightness)
        
        let components = CGColorGetComponents(color.CGColor)
        var bytes: [UInt8] = []
        bytes.append(0x43)
        
        for i in 0...3 {
            let f = Float(components[i] * 255)
            let a = UInt8(lroundf(f))
            bytes.append(a)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.writeData(NSData(bytes: bytes, length: bytes.count))
    }
    
    func updatePreview() {
        let color = colorPicker.selectionColor
        let brightness = brightnessSlider.value
        
        let sublayer = previewPatch.layer.sublayers![0]
        sublayer.backgroundColor = color.CGColor
        sublayer.opacity = brightness
    }
    
    func colorPickerDidChangeSelection(cp: RSColorPickerView!) {
        self.changeColor()
    }
    
    @IBAction func brightnessChanged(sender: UISlider) {
        self.changeColor()
    }
}