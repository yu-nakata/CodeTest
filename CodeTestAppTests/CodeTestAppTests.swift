//
//  CodeTestAppTests.swift
//  CodeTestAppTests
//
//  Created by 中田祐稀 on 2021/01/19.
//

import XCTest
import RxSwift
import RxCocoa
import OHHTTPStubs
@testable import CodeTestApp

class CodeTestAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let disposeBag = DisposeBag()
        let loginViewModel = LoginViewModel()
        let loginModel = LoginModel()
        // This is an example of a functional test case.
        stub(condition: isHost("codetestapp.com")) { _ in
            // IDとパスワードでエラー振り分ける
            var jsonName = "0.json"
            if loginModel.mail != loginViewModel.SUCCESS_MAIL && loginModel.password != loginViewModel.SUCCESS_PASSWORD {
                jsonName = "1.json"
            } else {
                if loginModel.mail != loginViewModel.SUCCESS_MAIL {
                    jsonName = "2.json"
                } else if loginModel.password != loginViewModel.SUCCESS_PASSWORD {
                    jsonName = "3.json"
                }
            }
            
            let stubPath = OHPathForFile(jsonName, type(of: self))
            return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"]).requestTime(TimeInterval(0), responseTime: TimeInterval(1.5))
        }
        
        // 正常系
        loginModel.mail = "test@gmail.com"
        loginModel.password = "test"
        APIClient().login(loginModel: loginModel)
            .subscribe(onNext: { (result) in
                XCTAssertEqual(result?.resultCode, 0)
            }).disposed(by : disposeBag)

        
        // アドレスミス
        loginModel.mail = "test"
        loginModel.password = "test"
        APIClient().login(loginModel: loginModel)
            .subscribe(onNext: { (result) in
                XCTAssertEqual(result?.resultCode, -2)
            }).disposed(by : disposeBag)
        
        // パスワードミス
        loginModel.mail = "test@gmail.com"
        loginModel.password = "t"
        APIClient().login(loginModel: loginModel)
            .subscribe(onNext: { (result) in
                XCTAssertEqual(result?.resultCode, -3)
            }).disposed(by : disposeBag)
        
        // どちらも不正
        loginModel.mail = "test"
        loginModel.password = "t"
        APIClient().login(loginModel: loginModel)
            .subscribe(onNext: { (result) in
                XCTAssertEqual(result?.resultCode, -1)
            }).disposed(by : disposeBag)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
