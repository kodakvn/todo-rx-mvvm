//
//  TodoViewModel.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation

protocol TodoItemPresentable {
    
    var id: String? { get }
    var textValue: String? { get }
}

struct TodoItemViewModel: TodoItemPresentable {
    
    var id: String? = "0"
    var textValue: String? = nil
}

protocol TodoViewDelegate {
    
    func onTodoItemAdded()
}

struct TodoViewModel {
    
    var newTodoItem: String?
    var items: [TodoItemPresentable] = []
    
    init() {
        let item1 = TodoItemViewModel(id: "1", textValue: "Washing clothes")
        let item2 = TodoItemViewModel(id: "2", textValue: "Buy Groceries")
        let item3 = TodoItemViewModel(id: "3", textValue: "Wash car")
        items.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onTodoItemAdded() {
        
    }
    
    
}
