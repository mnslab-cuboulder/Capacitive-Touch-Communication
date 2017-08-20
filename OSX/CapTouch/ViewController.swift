//
//  ViewController.swift
//  CapTouch
//
//  Created by Ed Salisbury on 9/28/16.
//  Copyright © 2016 Ed Salisbury. All rights reserved.
//

import Cocoa
import Foundation

//extension String {
//    subscript(range: ClosedRange<Int>) -> String {
//        let lowerIndex = index(startIndex,
//                               offsetBy: max(0,range.lowerBound),
//                               limitedBy: endIndex) ?? endIndex
//        return substring(
//            with: lowerIndex..<(index(lowerIndex,
//                                      offsetBy: range.upperBound - range.lowerBound + 1,
//                                      limitedBy: endIndex) ?? endIndex))
//    }
//}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var eventDetails: NSTextField!
    @IBOutlet weak var dataStream: NSTextField!
    @IBOutlet weak var upTime: NSTextField!
    @IBOutlet weak var downTime: NSTextField!
    @IBOutlet weak var markerDownTime: NSTextField!
    @IBOutlet weak var tolerance: NSTextField!
    @IBOutlet weak var asciiCode: NSTextField!
    @IBOutlet weak var accessStatus: NSTextField!
    
    @IBAction func upTimeChanged(_ sender: NSTextField) {
        bitup = Int(upTime.stringValue)!
        dataStream.stringValue = ""
        asciiCode.stringValue = ""
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: bitup, downLength: bitdown, pilotLength: marker, tolerance: tol)

    }

    @IBAction func downTimeChanged(_ sender: NSTextField) {
        bitdown = Int(downTime.stringValue)!
        dataStream.stringValue = ""
        asciiCode.stringValue = ""
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: bitup, downLength: bitdown, pilotLength: marker, tolerance: tol)

    }
    
    @IBAction func toleranceChanged(_ sender: NSTextField) {
        tol = Int(tolerance.stringValue)!
        dataStream.stringValue = ""
        asciiCode.stringValue = ""
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: bitup, downLength: bitdown, pilotLength: marker, tolerance: tol)

    }
    
    @IBAction func markerDownTimeChanged(_ sender: NSTextField) {
        marker = Int(markerDownTime.stringValue)!
        dataStream.stringValue = ""
        asciiCode.stringValue = ""
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: bitup, downLength: bitdown, pilotLength: marker, tolerance: tol)

    }
    
    var midas: Midas = Midas()
    
    var objects: NSMutableArray! = NSMutableArray()
    var timer = Timer()
    var events: NSMutableArray! = NSMutableArray()
    var timeSinceLastEvent = NSDate().timeIntervalSince1970 * 1000
    
    var bitdown = 0
    var bitup = 0
    var tol = 0
    var lastEventCount = 0
    var marker = 0

    let fd = open("/tmp/captouch.log", O_WRONLY|O_CREAT|O_APPEND, 0o666)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.acceptsTouchEvents = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
                //timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)

        upTime.stringValue = "50"
        downTime.stringValue = "50"
        tolerance.stringValue = "50"
        markerDownTime.stringValue = "100"
        
        bitup = Int(upTime.stringValue)!
        bitdown = Int(downTime.stringValue)!
        tol = Int(tolerance.stringValue)!
        marker = Int(markerDownTime.stringValue)!
        timeSinceLastEvent = NSDate().timeIntervalSince1970 * 1000
        
        midas = Midas(frameEnable: true, frameSize: 8, upLength: bitup, downLength: bitdown, pilotLength: marker, tolerance: tol)
    }
    
    func update()
    {
        dataStream.stringValue = midas.DemodulateBinary(pressEvents: midas.PressEvents(), releaseEvents: midas.ReleaseEvents())
        asciiCode.stringValue = midas.DemodulateAscii(pressEvents: midas.PressEvents(), releaseEvents: midas.ReleaseEvents(), asciiLength: 7)
        if midas.Identification(target: "CAP", checkStr: asciiCode.stringValue)
        {
            accessStatus.stringValue = "Access Granted"
        }
        else
        {
            accessStatus.stringValue = "Access Denied"
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
    
//    override func touchesMoved(with event: NSEvent) {
//        let touches = event.touches(matching:.moved, in: nil)
//        for touch in touches {
//            var event = Event()
//            event.timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
//            event.type = EventType.move
//            event.x = double_t(touch.normalizedPosition.x)
//            event.y = double_t(touch.normalizedPosition.y)
//            event.id = touch.identity
//            midas.InputEvent(event)
//        }
//    }
}

