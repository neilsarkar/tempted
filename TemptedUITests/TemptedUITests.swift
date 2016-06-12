//
//  TemptedUITests.swift
//  TemptedUITests
//
//  Created by Neil Sarkar on 6/12/16.
//  Copyright © 2016 Neil Sarkar. All rights reserved.
//

import XCTest

class TemptedUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let app = XCUIApplication()
//        app.alerts["Allow “Tempted” to access your location while you use the app?"].collectionViews.buttons["Allow"].tap()

        snapshot("0mosquitto")
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.buttons["LiveMosquitto"].tap()
        snapshot("1buttonPressed")
    }
}
