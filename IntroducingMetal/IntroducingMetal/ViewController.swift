//
//  ViewController.swift
//  IntroducingMetal
//
//  Created by mac126 on 2019/4/13.
//  Copyright © 2019 mac126. All rights reserved.
//

import Cocoa
/*
 Cocoa框架已为我们导入Metal和AppKit框架-可以使用NSViewController的类，所有不需要额外导入Metal
 */

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
         MTLCopyAllDevices() 仅适用OSX()
         MTLCreateSystemDefaultDevice()  iOS tvOS
         */
        MTLCreateSystemDefaultDevice()
        // 获取系统所有Metal设备
        let devices = MTLCopyAllDevices()
        
        
        guard let _ = devices.first else {
            fatalError("Your GPU does not support metal")
        }
        
        label.stringValue = "Your system has following GPUs:\n"
        for device in devices {
            /*
             MTLDevice
             device是GPU的抽象，可以交谈
             */
            label.stringValue += "\(device.name)\n"
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

