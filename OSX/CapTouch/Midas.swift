//
//  Midas.swift
//  CapTouch
//
//  Created by Ed Salisbury on 11/9/16.
//  Copyright © 2016 Ed Salisbury. All rights reserved.
//

import Foundation

enum EventType
{
    case press
    case release
    case move
    case unknown
}

struct Event
{
    var timestamp: UInt64
    var type: EventType
    var id: NSCopying & NSObjectProtocol
    var x: double_t
    var y: double_t
    var amplitude: double_t
    var length: UInt64
    
    init()
    {
        timestamp = 0
        type = EventType.unknown
        id = 0 as NSCopying & NSObjectProtocol
        x = 0
        y = 0
        amplitude = 0
        length = 0
    }
}

class Midas
{
    var events: [Event]
    var frameEnable: Bool
    var frameSize: Int
    var upLength: Int
    var downLength: Int
    var pilotLength: Int
    var tolerance: Int
    
    init(frameEnable: Bool = true, frameSize: Int = 8, upLength: Int = 50, downLength: Int = 50, pilotLength: Int = 100, tolerance: Int = 50)
    {
        self.events = [Event]()
        self.frameEnable = frameEnable
        self.frameSize = frameSize
        self.upLength = upLength
        self.downLength = downLength
        self.pilotLength = pilotLength
        self.tolerance = tolerance
    }
    
    func InputEvent(_ event: Event)
    {
        events.append(event)
        print(event)
    }

    func PressEvents() -> [Event]
    {
        return events.filter{$0.type == EventType.press}
    }
    
    func ReleaseEvents() -> [Event]
    {
        return events.filter{$0.type == EventType.release}
    }
    
    func ProcessEvents(pressEvents: [Event], releaseEvents: [Event]) -> [Event]
    {
        var allEvents = [Event]()
        
        if pressEvents.count < 2
        {
            return allEvents
        }
        
        for i in 0 ..< pressEvents.count - 1
        {
            // Add press event after setting elapsed time
            var event = pressEvents[i]
            
            event.length = releaseEvents[i].timestamp - pressEvents[i].timestamp
            allEvents.append(event)
            
            // Split release events into separate events
            // TODO: Handle multitouch events - multitouch breaks this if elapsed goes negative
            let elapsed = pressEvents[i + 1].timestamp - releaseEvents[i].timestamp
            let numUpEvents = Int(round(Double(elapsed) / Double(self.upLength)))
            if numUpEvents > 0
            {
                var upEvent = releaseEvents[i]
                upEvent.length = UInt64(round(Double(elapsed) / Double(numUpEvents)))
                for _ in 1 ... numUpEvents
                {
                    allEvents.append(upEvent)
                }
            }
        }
        return allEvents
    }
    
    func DemodulateBinary(pressEvents: [Event], releaseEvents: [Event], direction: UInt8 = 1) -> String
    {
        let processedEvents = ProcessEvents(pressEvents: pressEvents, releaseEvents: releaseEvents)
        
        var data = ""
        var index = 0
        
        while index < processedEvents.count - 1
        {
            var firstEvent = Event()
            var secondEvent = Event()
            
            if direction == 1
            {
                firstEvent = processedEvents[index]
                secondEvent = processedEvents[index + 1]
            }
            else
            {
                // TODO
                print("Reverse demodulation not implemented yet")
            }
                
            if frameEnable &&
                firstEvent.type == EventType.press &&
                secondEvent.type == EventType.release &&
                pilotLength > Int(firstEvent.length) - tolerance &&
                pilotLength < Int(firstEvent.length) + tolerance &&
                upLength > Int(secondEvent.length) - tolerance &&
                upLength < Int(secondEvent.length) + tolerance
            {
                data += "|"
                index += 2
            }
            else if firstEvent.type == EventType.press &&
                secondEvent.type == EventType.release &&
                downLength > Int(firstEvent.length) - tolerance &&
                downLength < Int(firstEvent.length) + tolerance &&
                upLength > Int(secondEvent.length) - tolerance &&
                upLength < Int(secondEvent.length) + tolerance
            {
                data += "1"
                index += 2
            }
            else if firstEvent.type == EventType.release &&
                secondEvent.type == EventType.release &&
                upLength > Int(firstEvent.length) - tolerance &&
                upLength < Int(firstEvent.length) + tolerance &&
                upLength > Int(secondEvent.length) - tolerance &&
                upLength < Int(secondEvent.length) + tolerance
            {
                data += "0"
                index += 2
            }
            else
            {
                index += 1
            }
        }
        return data
    }
    
    func DemodulateAscii(pressEvents: [Event], releaseEvents: [Event], direction: UInt8 = 1, asciiLength: Int = 8) -> String
    {
        let binary = DemodulateBinary(pressEvents: pressEvents, releaseEvents: releaseEvents, direction: direction)

        let mark_char:Character = "|"
        var asciiStr = ""
        var binDigit = ""
        
        for char in binary.characters
        {
            if char != mark_char
            {
                binDigit += String(char)
            }
            else
            {
                if binDigit.characters.count == asciiLength
                {
                    let intNumber = Int(binDigit, radix: 2)!
                    let asciiChar = String(UnicodeScalar(intNumber)!)
                    asciiStr += asciiChar
                }
                binDigit = ""
            }
        }
        return asciiStr
    }
    
    func Identification(target: String, checkStr: String) -> Bool
    {
        var j = 0
        let targetBytes = [UInt8](target.utf8)
        let checkStrBytes = [UInt8](checkStr.utf8)
        
        for i in 0 ..< checkStrBytes.count
        {
            // Check to see if the character matches
            if checkStrBytes[i] == targetBytes[j]
            {
                // Matches
                j += 1
            }
            else
            {
                // No match
                j = 0
            }
            
            // If we've reached the target size, we're done
            if j == targetBytes.count
            {
                return true
            }
        }
        // No match found
        return false
    }
    
    
    
    
    
    

    // From Phuc's doc
    func MIDAS_datacollection(event: Event, frame_enable: Bool, frame_size: UInt8, pilot_length: UInt64) -> (UInt32, [Event], [Event])
    {
        InputEvent(event)
        let press_events = PressEvents()
        let release_events = ReleaseEvents()
        
        let total_events = UInt32(press_events.count + release_events.count)
        
        return (total_events, press_events, release_events)
    }
    
    func MIDAS_dec_bin(pressEvents: [Event], releaseEvents: [Event], direction: UInt8) -> String
    {
        return DemodulateBinary(pressEvents: pressEvents, releaseEvents: releaseEvents, direction: direction)
    }
    
    func MIDAS_dec_ascii(pressEvents: [Event], releaseEvents: [Event], direction: UInt8, asci_length: UInt8) -> String
    {
        return DemodulateAscii(pressEvents: pressEvents, releaseEvents: releaseEvents, direction: direction, asciiLength: Int(asci_length))
    }
    
    func MIDAS_identification_bin(target_bin: String, decoded_bin: String) -> Bool
    {
        return Identification(target: target_bin, checkStr: decoded_bin)
    }
    
    func MIDAS_identification_ascii(target_ascii: String, decoded_ascii: String) -> Bool
    {
        return Identification(target: target_ascii, checkStr: decoded_ascii)
    }
}
