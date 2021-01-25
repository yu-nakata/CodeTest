//
//  APIResult.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/25.
//

import Foundation

class APIResult: Codable {
    
    var resultCode = 0
    var message = ""
    
    convenience init(resultCode: Int, message: String) {
        self.init()
        self.resultCode = resultCode
        self.message = message
    }
}
