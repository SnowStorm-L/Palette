//
//  ViewController.swift
//  Palette
//
//  Created by L on 2018/12/15.
//  Copyright © 2018 L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let size = view.bounds.size
        let paletteSize = CGSize(width: size.width * 0.9, height: size.width * 0.9)
        
        
       let palette = Palette(frame: CGRect(x: size.width / 2 - paletteSize.width / 2, y: size.height * 0.1, width: paletteSize.width, height: paletteSize.height))
        view.addSubview(palette)
        
    }


}

