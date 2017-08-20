//
//  TestMidas.swift
//  CapTouch
//
//  Created by Ed Salisbury on 11/10/16.
//  Copyright © 2016 Ed Salisbury. All rights reserved.
//

import XCTest

class TestMidas: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInputEvent()
    {
        midas = Midas()
        let val = midas.PressEvents()
        XCTAssertEqual(val.count, 0)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
