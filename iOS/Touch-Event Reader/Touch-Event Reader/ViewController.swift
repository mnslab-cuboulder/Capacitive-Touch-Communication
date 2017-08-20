//
//  ViewController.swift
//  Touch-Event Reader
//
//  Created by Brad on 9/23/16.
//  Copyright (c) 2016 Brad. All rights reserved.
//

import UIKit

var Timestamp: TimeInterval {
    return ProcessInfo.processInfo.systemUptime// NSDate().timeIntervalSinceReferenceDate
}

class ViewController: UIViewController {
    // MARK: Properties
    let STR_LENGTH = 4
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var YLabel: UILabel!
    @IBOutlet weak var XLabel: UILabel!
    @IBOutlet weak var TimestampLabel: UILabel!
    @IBOutlet weak var TypeLabel: UILabel!
    @IBOutlet weak var NumTouchesLabel: UILabel!
    @IBOutlet weak var AmplitudeLabel: UILabel!
    @IBOutlet weak var StreamLabel: UILabel!
    @IBOutlet weak var ArrayLabel: UILabel!
    @IBOutlet weak var CharLabel: UILabel!
    @IBOutlet weak var verifyLabel: UILabel!
    var touchCount=0
    var touched=false
    var downLength=30
    var upLength=50
    var releaseTime:TimeInterval = 0.0
    var pressTime:TimeInterval = 0.0
    var touchVals=[Int]()
    var charVals=[Character]()
    var screen = 1
    var chars = [Character]()
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if(StreamLabel==nil)
        {
            screen=0
        }
        else
        {
            screen=1
            for char in StreamLabel.text!.characters
            {
                chars.append(char)
            }
            for _ in 0 ... STR_LENGTH-1
            {
                charVals.append("_")
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        //saveBit(ch: "U", time: (touch?.timestamp.description)!)
        let location = touch?.location(in: self.view)
        //print(touch!.timestamp.description, ",0,", location!.x.description, ",",location!.y.description, ",")
        if(screen == 0)
        {
            XLabel.text = location?.x.description
            YLabel.text = location?.y.description
            TimestampLabel.text = touch?.timestamp.description
            TypeLabel.text = touch?.phase.rawValue.description
            touchCount-=touches.count
            NumTouchesLabel.text = touchCount.description
            AmplitudeLabel.text = touch?.majorRadius.description
        }
        else if(screen == 1)
        {
            if(pressTime != 0 && Int(((touch?.timestamp)!-pressTime)*1000.0) > Int(Double(downLength)*1.5))
            {
                writeBit(bit: "_")
                if(chars[chars.count-9]=="_")
                {
                    var intVal = 0;
                    for c in Int(chars.count-8)...Int(chars.count-2)
                    {
                        intVal*=2;
                        let tmpChar = chars[c];
                        var tmpInt = (Int(String(tmpChar)))
                        let tmpZero = Int("0")
                        if tmpInt == nil
                        {
                            tmpInt = Int("0")
                        }
                        let newtmp = tmpInt! - tmpZero!
                        intVal += newtmp
                        
                    }
                    let charVar = Character(UnicodeScalar(intVal)!)
                    for x in 0 ... 2
                    {
                        charVals[x] = charVals[x+1]
                    }
                    charVals[3] = charVar
                    CharLabel.text = String(charVals)
                    if(stringMatch(example: CharLabel.text!, data: "F@r7"))
                    {
                        let image: UIImage = UIImage(named: "brad.jpg")!
                        bgImage.image = image
                        verifyLabel.text = "Welcome, Brad."
                        verifyLabel.textColor = UIColor.green
                    }
                    else if(stringMatch(example: CharLabel.text!, data: "CAPN"))
                    {
                        let image: UIImage = UIImage(named: "other.jpg")!
                        bgImage.image = image
                        verifyLabel.text = "Welcome, Ed or Lily."
                        verifyLabel.textColor = UIColor.blue
                    }
                    else
                    {
                        let image: UIImage = UIImage()
                        bgImage.image = image
                        verifyLabel.text = "Invalid user!"
                        verifyLabel.textColor = UIColor.red
                    }
                }
            }
            else
            {
                writeBit(bit: "1")
            }
            releaseTime=(touch?.timestamp)!
            StreamLabel.text = String(chars)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        //saveBit(ch: "M", time: (touch?.timestamp.description)!)
        //NSLog("touch - M: %@ ", touch!.timestamp.description)
        if(screen==0){
        let location = touch?.location(in: self.view)
        XLabel.text = location?.x.description
        YLabel.text = location?.y.description
        TimestampLabel.text = touch?.timestamp.description
        TypeLabel.text = touch?.phase.rawValue.description
        AmplitudeLabel.text = touch?.majorRadius.description
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        //saveBit(ch: "D", time: (touch?.timestamp.description)!)
        let location = touch?.location(in: self.view)
        //print(touch!.timestamp.description, ",1,", location!.x.description, ",",location!.y.description, ",")
        touched=true
        if(screen==0){
        XLabel.text = location?.x.description
        YLabel.text = location?.y.description
        TimestampLabel.text = touch?.timestamp.description
        TypeLabel.text = touch?.phase.rawValue.description
        touchCount+=touches.count
        NumTouchesLabel.text = touchCount.description
        AmplitudeLabel.text = touch?.majorRadius.description
        }
        else if(screen == 1)
        {
            pressTime = (touch?.timestamp)!
            if(releaseTime != 0 && Int(((touch?.timestamp)!-releaseTime)*1000.0/(Double(upLength))) > 0)
            {
                for _ in 1...Int(((touch?.timestamp)!-releaseTime)*1000.0/(Double(upLength)))
                {
                    writeBit(bit: "0")
                }
                StreamLabel.text = String(chars)
                //StreamLabel.text = Int(((touch?.timestamp)!-releaseTime)*1000.0/(Double(upLength))).description
            }
        }
    }
    func writeBit(bit: Character)
    {
        for x in 0...chars.count-2
        {
            chars[x]=chars[x+1]
        }
        chars[chars.count-1]=bit
    }
    func saveBit(ch: Character, time: String)
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        var fileName = "\(documentsDirectory)/textFile.txt"
        let content = String(ch) + ": " + time + "\n"
        content.write(to: &fileName)
    }
    func stringMatch(example: String, data: String) -> Bool
    {
        for x in 0...STR_LENGTH
        {
            let str1 = example.substring(to: example.index(example.startIndex, offsetBy: x))
            let str2 = example.substring(from: example.index(example.startIndex, offsetBy: x))
            let str3 = str2 + str1
            if data == str3
            {
                return true
            }
        }
        return false
    }
}

