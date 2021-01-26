//
//  LoginModel.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/25.
//

import Foundation

class LoginModel {
    
    var mail = ""
    var password = ""
    
    convenience init(mail: String, password: String) {
        self.init()
        self.mail = mail
        self.password = password
    }
}
