//
//  APIClient.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/25.
//

import Alamofire
import RxSwift

class APIClient {
    func login(loginModel: LoginModel) -> Observable<APIResult?> {
        return Observable.create { observer in
            let url = "https://codetestapp.com/login"
            AF.request(url, method: .get, parameters: nil).responseJSON { response in
                switch response.result {
                case .success(_):
                    print("SUCCESS")
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        if let result = try? decoder.decode(APIResult.self, from: data) {
                            print(result)
                            observer.onNext(result)
                        }
                    }
                    observer.onCompleted()
                case .failure(let error):
                    print(error)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func getImage(imageUrl: String) -> Observable<UIImage?> {
        return Observable.create { observer in
            AF.download(imageUrl).responseData { response in
                switch response.result {
                case .success(_):
                    print("SUCCESS")
                    if let data = response.value {
                        let image = UIImage(data: data)
                        observer.onNext(image)
                    }
                    observer.onCompleted()
                case .failure(let error):
                    print(error)
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}


