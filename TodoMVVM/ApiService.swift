//
//  ApiService.swift
//  TodoMVVM
//
//  Created by KODAK on 9/23/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

protocol ApiServiceProtocol {
    associatedtype ResponseData
    func fetchAllTodos() -> Observable<ResponseData>
}

class ApiService: ApiServiceProtocol {
    static let sharedInstance = ApiService()
    
    private init() {}
    
    typealias ResponseData = JSON
    
    func fetchAllTodos() -> Observable<ResponseData> {
        let url = URL(string: "https://gist.githubusercontent.com/kodakvn/24920621fb47f26ad6249748e60f6f78/raw/fb62946e98caa402aab36ebb5ee9db23d4fc97c2/todos.json")
        return Observable.create { observer in
            let request = Alamofire.request(url!).responseJSON { (responseData) in
                switch responseData.result {
                case .success(let value):
                    if let statusCode = responseData.response?.statusCode, statusCode == 200 {
                        let responseJson = JSON(value)
                        observer.onNext(responseJson)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: String(format: "error with status code %d", responseData.response?.statusCode ?? -1), code: -1, userInfo: nil))
                    }
                case .failure(let error):
                    observer.onError(error)
                    print(error.localizedDescription)
                }
                
            }
            return Disposables.create {
                return request.cancel()
            }
        }
    }
}
