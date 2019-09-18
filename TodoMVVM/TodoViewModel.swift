//
//  TodoViewModel.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation
import RxSwift

protocol TodoMenuItemViewPresentable {
    
    var title: String? { get }
    var backgroundColor: String? { get }
}

protocol TodoMenuItemViewDelegate: class {
    
    func onMenuItemSelected()
    
}

class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    
    var title: String?
    var backgroundColor: String?
    weak var parent: TodoItemDelegate?
    
    init(parentViewModel: TodoItemDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        // base class
    }
    
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    var isDone: Bool = false {
        didSet {
            if isDone {
                title = "Undone"
            } else {
                title = "Done"
            }
        }
    }
    override func onMenuItemSelected() {
        parent?.onDoneSelected()
        isDone = !isDone
    }
}

protocol TodoItemDelegate: class {
    func onItemSelected()
    func onRemoveSelected()
    func onDoneSelected()
}

protocol TodoItemPresentable {
    
    var id: String? { get }
    var textValue: String? { get }
    var isDone: Bool? { get set }
    var menuItems: [TodoMenuItemViewPresentable]? { get }
}

class TodoItemViewModel: TodoItemPresentable {
    
    var id: String? = "0"
    var textValue: String? = nil
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewModel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.isDone = false
        self.parent = parentViewModel
        
        let remove = RemoveMenuItemViewModel(parentViewModel: self)
        remove.title = "Remove"
        remove.backgroundColor = "ff0000"
        
        let done = DoneMenuItemViewModel(parentViewModel: self)
        done.title = "Done"
        done.isDone = false
        done.backgroundColor = "008000"
        
        menuItems?.append(contentsOf: [remove, done])
    }
}

extension TodoItemViewModel: TodoItemDelegate {
    func onItemSelected() {
        print("select \(String(describing: id))")
    }
    
    func onRemoveSelected() {
        parent?.onDeleteItem(todoId: id!)
    }
    
    func onDoneSelected() {
        parent?.onDoneItem(todoId: id!)
    }
}

protocol TodoViewDelegate: class {
    
    func onAddTodoItem()
    func onDeleteItem(todoId: String)
    func onDoneItem(todoId: String)
}

protocol TodoViewPresentable {
    
    var newTodoItem: String? { get }
    
}

class TodoViewModel: TodoViewPresentable {
    
    var newTodoItem: String?
    var items: Variable<[TodoItemPresentable]> = Variable([])
    
    init() {
        let item1 = TodoItemViewModel(id: "1", textValue: "Washing clothes", parentViewModel: self)
        let item2 = TodoItemViewModel(id: "2", textValue: "Buy Groceries", parentViewModel: self)
        let item3 = TodoItemViewModel(id: "3", textValue: "Wash car", parentViewModel: self)
        items.value.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onAddTodoItem() {
        guard let value = newTodoItem else {
            return
        }
        let index = items.value.count + 1
        let newItem = TodoItemViewModel(id: "\(index)", textValue: value, parentViewModel: self)
        items.value.append(newItem)
        newTodoItem = nil
    }
    
    func onDeleteItem(todoId: String) {
        guard let index = items.value.firstIndex(where: { $0.id == todoId }) else {
            return
        }
        
        items.value.remove(at: index)
    }
    
    func onDoneItem(todoId: String) {
        guard let index = items.value.firstIndex(where: { $0.id == todoId }) else {
            return
        }
        
        var item = self.items.value[index]
        item.isDone = !(item.isDone)!
        self.items.value.sort(by: {
            if ($0.isDone)! ^^ ($1.isDone)! {
                return !($0.isDone)! && $1.isDone!
            } else {
                return $0.id! < $1.id!
            }
            
        })
    }
    
}


