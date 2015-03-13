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
        
        var colorPreviewLayer = CALayer()
        previewPatch.layer.addSublayer(colorPreviewLayer)
    }
    
    override func viewDidLayoutSubviews() {
        var sublayer = previewPatch.layer.sublayers[0] as CALayer
        sublayer.frame = CGRect(origin: CGPointZero, size: previewPatch.frame.size)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeColor() {
        self.updatePreview()
        
        var color = colorPicker.selectionColor
        var brightness = CGFloat(brightnessSlider.value)
        
        color = color.colorWithAlphaComponent(brightness)
        
        let components = CGColorGetComponents(color.CGColor)
        var bytes: [Byte] = []
        bytes.append(0x43)
        
        for i in 0...3 {
            let f = Float(components[i] * 255)
            let a = Byte(lroundf(f))
            bytes.append(a)
        }
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.writeData(NSData(bytes: bytes, length: bytes.count))
    }
    
    func updatePreview() {
        var color = colorPicker.selectionColor
        var brightness = brightnessSlider.value
        
        var sublayer = previewPatch.layer.sublayers[0] as CALayer
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