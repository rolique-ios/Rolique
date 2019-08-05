//
//  RoliqueTests.swift
//  RoliqueTests
//
//  Created by Andrii on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import XCTest
import Networking

class RoliqueTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNetworking() {
      XCTAssert(Env.apiUrl != "no_api_url", "bad apiUrl")
      XCTAssert(Env.apiToken != "no_api_token", "bad apiToken")
      XCTAssert(Env.slackCliendId != "no_slack_client_id", "bad slackCliendId")
      XCTAssert(Env.slackClientSecret != "no_slack_client_secret", "bad slackClientSecret")
      XCTAssert(Env.slackRedirectUri != "https://no_slack_redirect_uri", "bad slackRedirectUri")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
