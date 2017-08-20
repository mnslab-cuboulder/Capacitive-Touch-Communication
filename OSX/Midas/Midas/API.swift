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
    public var timestamp: Double
    public var type: EventType
    public var id: NSCopying & NSObjectProtocol
    public var x: CGFloat?
    public var y: CGFloat?
    public var amplitude: CGFloat?
    public var length: Double
    
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
    public init(timestamp: Double,type:  EventType, id:  NSCopying & NSObjectProtocol, x:  CGFloat?, y:  CGFloat?, amplitude:  CGFloat?, length:  Double)
    {
        self.timestamp = timestamp
        self.type = type
        self.id = id
        self.x = x
        self.y = y
        self.amplitude = amplitude
        self.length = length
    }
}

public class Midas
{
    var events: [Event]
    var frameEnable: Bool
    var frameSize: Int
    var upLength: Double
    var downLength: Double
    var pilotLength: Double
    var tolerance: Double
    var releaseTimer: Timer
    var timerRunning: Bool
    var releaseCallback: (Event) -> Void
    
    public init(frameEnable: Bool = true, frameSize: Int = 8, upLength: Double = 50, downLength: Double = 50, pilotLength: Double = 100, tolerance: Double = 50, completion: @escaping (_ releaseEvent: Event) -> Void = {releaseEvent in})
    {
        self.events = [Event]()
        self.frameEnable = frameEnable
        self.frameSize = frameSize
        self.upLength = upLength
        self.downLength = downLength
        self.pilotLength = pilotLength
        self.tolerance = tolerance
        self.releaseTimer = Timer.init()
        self.releaseCallback = completion
        self.timerRunning = false
    }
    
    public func InputEvent(_ event: Event)
    {
        events.append(event)
        //print(events.count, " events.")
    }
    
    @objc func releaseTimerExpired(_ t: Timer) -> Void {
        releaseCallback(events.last!)
        timerRunning = false
    }
    
    func setReleaseTimer()
    {
        releaseTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.releaseTimerExpired), userInfo: nil, repeats: false)
        timerRunning = true
    }
    
    func unsetReleaseTimer()
    {
        releaseTimer.invalidate()
        timerRunning = false
    }
    
    public func eventLooksLike() -> EventType
    {
        switch(events.last!.type)
        {
        case .press:
            if(timerRunning){
                unsetReleaseTimer()
                return EventType.move
            }
            else {
                unsetReleaseTimer()
                return EventType.press
            }
        case .release:
            setReleaseTimer()
            return EventType.move
        case .move:
            unsetReleaseTimer()
            return EventType.move
        default:
            return EventType.move
        }
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
        //print(pressEvents.count, "presses, ",releaseEvents.count," releases")
        var allEvents = [Event]()
        
        if pressEvents.count < 2 || releaseEvents.count < 2
        {
            return allEvents
        }
        
        //print(releaseEvents.last!.timestamp, " vs ", pressEvents.last!.timestamp - 0.5)
        if releaseEvents.last!.timestamp < pressEvents.last!.timestamp - 0.2
        {
            let lEvent = events.last!
            events.removeAll()
            events.append(lEvent)
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
                    let numUpEvents = Int(round(Double(elapsed*1000.0) / Double(self.upLength)))
                    if numUpEvents > 0
                    {
                        var upEvent = releaseEvents[i]
                        upEvent.length = Double(round(Double(elapsed*1000.0) / Double(numUpEvents)))
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
                //print("Reverse demodulation not implemented yet")
            }
            //print(firstEvent.type,":",firstEvent.length,"  ",secondEvent.type,":",secondEvent.length)
            if frameEnable &&
                firstEvent.type == EventType.press &&
                secondEvent.type == EventType.release &&
                pilotLength > Double(firstEvent.length) &&
                //pilotLength < Double(firstEvent.length) + tolerance &&
                upLength > Double(secondEvent.length)
                //upLength < Double(secondEvent.length) + tolerance
            {
                data.append("|")
                index += 2
            }
            else if firstEvent.type == EventType.press &&
                secondEvent.type == EventType.release &&
                downLength > Double(firstEvent.length) - tolerance &&
                downLength < Double(firstEvent.length) + tolerance &&
                upLength > Double(secondEvent.length) - tolerance &&
                upLength < Double(secondEvent.length) + tolerance
            {
                data.append("1")
                index += 2
            }
            else if firstEvent.type == EventType.release &&
                secondEvent.type == EventType.release &&
                upLength > Double(firstEvent.length) - tolerance &&
                upLength < Double(firstEvent.length) + tolerance &&
                upLength > Double(secondEvent.length) - tolerance &&
                upLength < Double(secondEvent.length) + tolerance
            {
                data.append("0")
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
        print("ident ", target, " vs ", checkStr)
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
                if checkStrBytes[i] == targetBytes[j]
                {
                    // Matches
                    j += 1
                }
            }
            
            // If we've reached the target size, we're done
            if j == targetBytes.count
            {
                //print("found ", targetBytes)
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
