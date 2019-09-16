//
//  TodoViewModel.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation

protocol TodoItemDelegate: class {
    func onItemSelected()
}

protocol TodoItemPresentable {
    
    var id: String? { get }
    var textValue: String? { get }
}

class TodoItemViewModel: TodoItemPresentable {
    
    var id: String? = "0"
    var textValue: String? = nil
    
    init(id: String, textValue: String) {
        self.id = id
        self.textValue = textValue
    }
}

extension TodoItemViewModel: TodoItemDelegate {
    func onItemSelected() {
        print("select \(id)")
    }
}

protocol TodoViewDelegate {
    
    func onAddTodoItem()
}

protocol TodoViewPresentable {
    
    var newTodoItem: String? { get }
    
}

class TodoViewModel: TodoViewPresentable {
    
    weak var view: TodoView?
    var newTodoItem: String?
    var items: [TodoItemPresentable] = []
    
    init(view: TodoView) {
        self.view = view
        let item1 = TodoItemViewModel(id: "1", textValue: "Washing clothes")
        let item2 = TodoItemViewModel(id: "2", textValue: "Buy Groceries")
        let item3 = TodoItemViewModel(id: "3", textValue: "Wash car")
        items.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onAddTodoItem() {
        guard let value = newTodoItem else {
            return
        }
        let index = items.count + 1
        let newItem = TodoItemViewModel(id: "\(index)", textValue: value)
        items.append(newItem)
        newTodoItem = nil
        view?.insertTodoItem()
    }
    
    
}
