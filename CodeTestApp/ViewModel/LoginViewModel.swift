//
//  LoginViewModel.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/25.
//

import Foundation
import RxSwift
import RxCocoa
import OHHTTPStubs

class LoginViewModel {
    // 成功パターン定義
    let SUCCESS_MAIL = "test@test.com"
    let SUCCESS_PASSWORD = "test"
    
    
    let loginModel = LoginModel()
    let mail = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    
    // API
    let isSuccessRelay = BehaviorRelay<Bool>(value: false)
    private(set) lazy var isSuccess = isSuccessRelay.asDriver()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private(set) lazy var isLoading = isLoadingRelay.asDriver()
    let errMsgRelay = BehaviorRelay<String>(value: "")
    private(set) lazy var errMsg = errMsgRelay.asDriver()
    
    func login(disposeBag: DisposeBag){
        loginModel.mail = mail.value
        loginModel.password = password.value

        isLoadingRelay.accept(true)
        
        stub(condition: isHost("codetestapp.com")) { _ in
            // IDとパスワードでエラー振り分ける
            var jsonName = "0.json"
            if self.mail.value != self.SUCCESS_MAIL && self.password.value != self.SUCCESS_PASSWORD {
                jsonName = "1.json"
            } else {
                if self.mail.value != self.SUCCESS_MAIL {
                    jsonName = "2.json"
                } else if self.password.value != self.SUCCESS_PASSWORD {
                    jsonName = "3.json"
                }
            }
            
            let stubPath = OHPathForFile(jsonName, type(of: self))
            return fixture(filePath: stubPath!, status: 200, headers: ["Content-Type":"application/json"]).requestTime(TimeInterval(0), responseTime: TimeInterval(1.5))
        }
        
        APIClient().login(loginModel: loginModel)
            .subscribe(onNext : {response in
                self.isLoadingRelay.accept(false)
                if response?.resultCode == 0 {
                    self.isSuccessRelay.accept(true)
                } else {
                    self.errMsgRelay.accept(response?.message ?? "")
                    self.isSuccessRelay.accept(false)
                }
            }, onError : { error in
                self.isLoadingRelay.accept(false)
                self.errMsgRelay.accept(error.localizedDescription)
            }).disposed(by : disposeBag)
    }
}
