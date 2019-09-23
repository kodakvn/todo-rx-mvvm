//
//  ApiService.swift
//  TodoMVVM
//
//  Created by KODAK on 9/23/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation
import Alamofire

protocol ApiServiceProtocol {
    associatedtype ResponseData
    func fetchAllTodos(completion: @escaping (Data) -> Void)
}

class ApiService: ApiServiceProtocol {
    static let sharedInstance = ApiService()
    
    private init() {}
    
    typealias ResponseData = Data
    
    func fetchAllTodos(completion: @escaping (Data) -> Void) {
        if let url = URL(string: "https://gist.githubusercontent.com/kodakvn/24920621fb47f26ad6249748e60f6f78/raw/fb62946e98caa402aab36ebb5ee9db23d4fc97c2/todos.json") {
            Alamofire.request(url).responseJSON { (response) in
                if let data = response.data {
                    completion(data)
                }
            }
        }
    }
    
    
}
