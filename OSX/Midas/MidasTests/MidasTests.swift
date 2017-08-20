//
//  MidasTests.swift
//  MidasTests
//
//  Created by Ed Salisbury on 1/31/17.
//  Copyright © 2017 Ed Salisbury. All rights reserved.
//

import XCTest
import Midas

class MidasTests: XCTestCase {
    
    var midas: Midas!

    override func setUp() {
        super.setUp()
        midas = Midas()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }

    func addTouchEvent(type: EventType)
    {
        var event = Event()
        event.timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
        event.type = type
        event.x = double_t(0)
        event.y = double_t(0)
        event.id = 0 as NSCopying & NSObjectProtocol
        midas.InputEvent(event)
    }
    
    func testIdentificationBinary()
    {
        var bitmask = midas.GenerateBitmask(value: 0x5)
        XCTAssertTrue(midas.IdentificationBinary(needle: 0x5, haystack: 0x1B504D, bitmask: bitmask))
        
        bitmask = midas.GenerateBitmask(value: 0x519a)
        XCTAssertFalse(midas.IdentificationBinary(needle: 0x519a, haystack: 0x1B504D, bitmask: bitmask))
    }
    
    func testGenerateBitmask()
    {
        XCTAssertEqual(midas.GenerateBitmask(value: 0b101), 0b111)
        XCTAssertEqual(midas.GenerateBitmask(value: 0b10101010), 0b11111111)
    }

}
