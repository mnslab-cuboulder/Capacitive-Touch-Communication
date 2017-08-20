//
//  ViewController.swift
//  CapRPG
//
//  Created by Ed Salisbury on 11/17/16.
//  Copyright © 2016 Ed Salisbury. All rights reserved.
//

import Cocoa
import Midas

extension String {
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - self.characters.count
        guard padCount > 0 else { return self }
        
        return String(repeating: character, count: padCount) + self
    }
}


class ViewController: NSViewController {
    @IBOutlet weak var bgImage: NSImageView!

    var midas: Midas = Midas()
    var timer = Timer()
    var binData = ""
    var asciiData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.acceptsTouchEvents = true
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: 50, downLength: 50, pilotLength: 100, tolerance: 25)
        
        self.bgImage.image = NSImage(named: "welcome.jpg")
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target:self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func update()
    {
        //let num = midas.DemodulateBinary()
        //let str = String(num, radix: 2).pad(with: "0", toLength: 64)
        //print(str)
        let old_bindata = binData
        binData = midas.DemodulateBinary(pressEvents: midas.PressEvents(), releaseEvents: midas.ReleaseEvents())
        let old_ascii = asciiData
        asciiData = midas.DemodulateAscii(pressEvents: midas.PressEvents(), releaseEvents: midas.ReleaseEvents(), asciiLength: 7)
        
        if old_ascii != asciiData || old_bindata != binData
        {
            print("\(binData) -> \(asciiData)")
        }
        
        if asciiData.contains("CAPN")
        {
            self.bgImage.image = NSImage(named: "lab.jpg")
        }
        else if asciiData.contains("IRON")
        {
            self.bgImage.image = NSImage(named: "interior.jpg")
        }
        else
        {
            self.bgImage.image = NSImage(named: "welcome.jpg")
        }
    }

    override func touchesBegan(with event: NSEvent) {
        let touches = event.touches(matching:.began, in: nil)
        for touch in touches {
            var event = Event()
            event.timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
            event.type = EventType.press
            event.x = double_t(touch.normalizedPosition.x)
            event.y = double_t(touch.normalizedPosition.y)
            event.id = touch.identity
            midas.InputEvent(event)
        }
    }
    
    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching:.ended, in: nil)
        for touch in touches {
            var event = Event()
            event.timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
            event.type = EventType.release
            event.x = double_t(touch.normalizedPosition.x)
            event.y = double_t(touch.normalizedPosition.y)
            event.id = touch.identity
            midas.InputEvent(event)
        }
    }
}

