//
//  Midas.swift
//  CapTouch
//
//  Created by Ed Salisbury on 11/9/16.
//  Copyright © 2016 Ed Salisbury. All rights reserved.
//

import Foundation

public enum EventType
{
    case press
    case release
    case move
    case unknown
}

public struct Event
{
    public var timestamp: UInt64
    public var type: EventType
    public var id: NSCopying & NSObjectProtocol
    public var x: double_t
    public var y: double_t
    public var amplitude: double_t
    public var length: UInt64
    
    public init()
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

public class Midas
{
    var events: [Event]
    var frameEnable: Bool
    var frameSize: Int
    var upLength: Int
    var downLength: Int
    var pilotLength: Int
    var tolerance: Int
    
    public init(frameEnable: Bool = true, frameSize: Int = 8, upLength: Int = 50, downLength: Int = 50, pilotLength: Int = 100, tolerance: Int = 50)
    {
        self.events = [Event]()
        self.frameEnable = frameEnable
        self.frameSize = frameSize
        self.upLength = upLength
        self.downLength = downLength
        self.pilotLength = pilotLength
        self.tolerance = tolerance
    }
    
    public func InputEvent(_ event: Event)
    {
        events.append(event)
        //print(event)
    }
    
    public func PressEvents() -> [Event]
    {
        return events.filter{$0.type == EventType.press}
    }
    
    public func ReleaseEvents() -> [Event]
    {
        return events.filter{$0.type == EventType.release}
    }
    
    public func ProcessEvents(pressEvents: [Event], releaseEvents: [Event]) -> [Event]
    {
        var allEvents = [Event]()
        let now = UInt64(NSDate().timeIntervalSince1970 * 1000)
        
        if pressEvents.count < 2 || releaseEvents.count < 2
        {
            return allEvents
        }
        
        if releaseEvents.last!.timestamp < now - 5000
        {
            events.removeAll()
            return allEvents
        }
        
        for i in 0 ..< pressEvents.count - 1
        {
            // Add press event after setting elapsed time
            var event = pressEvents[i]
            if releaseEvents.count > i && releaseEvents[i].timestamp > pressEvents[i].timestamp
            {
                event.length = releaseEvents[i].timestamp - pressEvents[i].timestamp
                allEvents.append(event)
                
                // Split release events into separate events
                if pressEvents.count > i + 1 && pressEvents[i + 1].timestamp > releaseEvents[i].timestamp
                {
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
            }
        }
        return allEvents
    }
    
    public func DemodulateBinary(pressEvents: [Event], releaseEvents: [Event], direction: UInt8 = 1) -> String
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
    
    public func DemodulateAscii(pressEvents: [Event], releaseEvents: [Event], direction: UInt8 = 1, asciiLength: Int = 8) -> String
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
    
    public func Identification(target: String, checkStr: String) -> Bool
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
    
    /**
    Searches the haystack value for the needle, using XOR and logical shifts.
        Runs in O(n), where n is the length of the haystack.
    
    @param needle: The value to search for
    @param haystack: The value to search for the needle in
    @param bitmask: Bitmask for the needle (use GenerateBitmask() if needed)
    @return True if found, false if not.
    */
    public func IdentificationBinary(needle: UInt64, haystack: UInt64,  bitmask: UInt64) -> Bool
    {
        var haystack = haystack;
        while (haystack > 0)
        {
            if (haystack ^ needle) & bitmask == 0
            {
                // Matched
                return true;
            }
            // Shift by one for next comparison
            haystack >>= 1;
        }
    
        // No match
        return false;
    }
    
    /**
    Generate a bitmask for a specific value, to be used with binary
        identification.  Uses log2, which is slow, so it's better to
        pre-calculate the bitmask for many comparisons.
 
    @param value: The value to generate a bitmask for
    @return The bitmask for the specified value
    */
    public func GenerateBitmask(value: UInt64) -> UInt64
    {
        let numBits = UInt64(ceil(log2(Float(value))))
        return UInt64((1 << numBits) - 1)
    }
}
