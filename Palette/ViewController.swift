//
//  ViewController.swift
//  Palette
//
//  Created by L on 2018/12/15.
//  Copyright © 2018 L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let colorView = UIView()
    let palette = Palette()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let size = view.bounds.size
        let paletteSize = CGSize(width: size.width * 0.9, height: size.width * 0.9)
        
        let x = size.width / 2 - paletteSize.width / 2
        let y = size.height * 0.1
        
        palette.frame = CGRect(x: x, y: y, width: paletteSize.width, height: paletteSize.height)
        palette.delegate = self
        view.addSubview(palette)
        
        colorView.frame = CGRect(x: 0, y: size.height - 100, width: 100, height: 100)
        view.addSubview(colorView)
        
    }
    
    
}

/*
 slider 0~1
 palette.brightness = slider.value
 palette.updateImage
 colorView.backgroundColor = palette.currentColor
 */

extension ViewController: PaletteDelegate {
    
    func paletteDidChangeColor(color: UIColor) {
        colorView.backgroundColor = palette.currentColor
    }
    
}

