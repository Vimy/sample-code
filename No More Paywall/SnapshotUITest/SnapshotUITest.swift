//
//  SnapshotUITest.swift
//  SnapshotUITest
//
//  Created by Matthias Vermeulen on 24/01/17.
//  Copyright © 2017 Matthias Vermeulen. All rights reserved.
//

import XCTest

class SnapshotUITest: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
                // Put setup code here. This method is called before the invocation of each test method in the class.
        
//        // In UI tests it is usually best to stop immediately when a failure occurs.
       continueAfterFailure = false
//        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
       
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        
//        
//        let element = app.otherElements.containing(.pageIndicator, identifier:"page 1 of 2").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
//        element.swipeLeft()
//        app.buttons["Continue"].tap()
        
        let tabBarsQuery = app.tabBars
        
        tabBarsQuery.buttons["About"].tap()
        snapshot("01about")
        tabBarsQuery.buttons["Reading List"].tap()
        snapshot("02ReadingList")
        let readingListNavigationBar = app.navigationBars["Reading List"]
//
//        readingListNavigationBar.buttons["Edit"].tap()
//        snapshot("03Edit")
//
       let app2 = app
//        app2.tables.staticTexts["Spending 10 Minutes a Day on Mindfulness Subtly Changes the Way You React to Everything"].tap()
//        readingListNavigationBar.buttons["Delete (1)"].tap()
//        app.sheets["Are you sure you want to remove this item?"].buttons["OK"].tap()
        //app2.icons["Safari"].tap()
//        
//        XCUIDevice.shared().press(.home)
//        XCUIDevice.shared().orientation = .portrait
//        
//      //  let app = XCUIApplication()
//        app.scrollViews.otherElements.icons["Safari"].tap()
//        app.toolbars.buttons["Share"].tap()
//        
//       
////        app.icons["Safari"].tap()
//        app.toolbars.buttons["Incognito"].tap()
        
  
        //app.collectionViews.cells.collectionViews.containing(.button, identifier:"Add to Reading List").buttons["More"].swipeLeft()
       // collectionViewsQuery.buttons["Incognito"].tap()
        
//        let readLaterButton = app.navigationBars.buttons["Read Later"]
//        readLaterButton.tap()
//        readLaterButton.tap()
        
        
//        snapshot("01about")
//        let tabBarsQuery = app.tabBars
//        tabBarsQuery.buttons["About"].tap()
//        snapshot("02ReadingList")
//        tabBarsQuery.buttons["Reading List"].tap()
//        snapshot("03Edit")
//        let readingListNavigationBar = app.navigationBars["Reading List"]
//        readingListNavigationBar.buttons["Edit"].tap()
//        app.tables.children(matching: .cell).element(boundBy: 1).staticTexts["With all of these new constraints, Auto Layout has probably thrown up a few warnings letting you know some of the frames are off. "].tap()
//        readingListNavigationBar.buttons["Delete (1)"].tap()
//        snapshot("03Edit2")
//        app.sheets["Are you sure you want to remove this item?"].buttons["OK"].tap()
//        readingListNavigationBar.buttons["search"].tap()
//        app.buttons["Cancel"].tap()
        
//        snapshot("04safari")
//        let app2 = app
//        app2.icons["Safari"].tap()
//        app.toolbars.buttons["Share"].tap()
////        app2.collectionViews.collectionViews.buttons["Add to Home Screen"].swipeLeft()
////        app2.collectionViews.cells.collectionViews.containing(.button, identifier:"Add to Reading List").buttons["More"].tap()
//        snapshot("05Extension")
//        let readLaterButton = app.navigationBars.buttons["Read Later"]
//        readLaterButton.tap()
//        readLaterButton.tap()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
