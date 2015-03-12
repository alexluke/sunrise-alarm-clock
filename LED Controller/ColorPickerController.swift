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
    
    func updatePreview() {
        var color = colorPicker.selectionColor
        var brightness = brightnessSlider.value
        
        var sublayer = previewPatch.layer.sublayers[0] as CALayer
        sublayer.backgroundColor = color.CGColor
        sublayer.opacity = brightness
    }
    
    func colorPickerDidChangeSelection(cp: RSColorPickerView!) {
        self.updatePreview()
    }
    
    @IBAction func brightnessChanged(sender: UISlider) {
        self.updatePreview()
    }
}