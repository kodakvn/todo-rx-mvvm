//
//  TodoViewModel.swift
//  TodoMVVM
//
//  Created by KODAK on 9/14/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

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
    var isDone: Bool? = false {
        didSet {
            if let menu = menuItems?.first(where: { $0 is DoneMenuItemViewModel} ) as? DoneMenuItemViewModel {
                menu.isDone = isDone ?? false
            }
        }
    }
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewModel: TodoViewDelegate, isDone: Bool = false) {
        self.id = id
        self.textValue = textValue
        self.isDone = isDone
        self.parent = parentViewModel
        
        let remove = RemoveMenuItemViewModel(parentViewModel: self)
        remove.title = "Remove"
        remove.backgroundColor = "ff0000"
        
        let done = DoneMenuItemViewModel(parentViewModel: self)
        done.isDone = isDone
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
    var database: Database
    var notificationToken: NotificationToken? = nil
    
    init() {
        database = Database.singleton
        
        let results = database.fetch()
        notificationToken = results.observe({ [weak self] (changes: RealmCollectionChange) in
            guard let _self_ = self else { return }
            
            switch changes {
            case .initial:
                results.forEach({ item in
                    let newItem = TodoItemViewModel(id: "\(item.todoId)", textValue: item.todoValue, parentViewModel: _self_, isDone: item.isDone)
                    _self_.items.value.append(newItem)
                })
            case .update(_, let deletions, let insertions, let modifications):
                insertions.forEach({ index in
                    let item = results[index]
                    let newItem = TodoItemViewModel(id: "\(item.todoId)", textValue: item.todoValue, parentViewModel: _self_)
                    _self_.items.value.append(newItem)
                })
                
                deletions.forEach({ index in
                    
                })
                
                modifications.forEach({ index in
                    let item = results[index]
                    
                    guard let aIndex = _self_.items.value.firstIndex(where: { Int($0.id!) == item.todoId }) else {
                        return
                    }
                    
                    if item.deletedAt != nil {
                        _self_.items.value.remove(at: index)
                        _self_.database.delete(primaryKey: item.todoId)
                        return
                    }
                    
                    var todoItem = _self_.items.value[aIndex]
                    todoItem.isDone = item.isDone
                })
            case .error(let error): break
            }
            
            _self_.sort()
        })
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func sort() {
        items.value.sort(by: {
            if ($0.isDone)! ^^ ($1.isDone)! {
                return !($0.isDone)! && $1.isDone!
            } else {
                return $0.id! < $1.id!
            }
        })
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onAddTodoItem() {
        guard let value = newTodoItem else {
            return
        }
        database.createOrUpdate(todoItemValue: value)
        newTodoItem = nil
    }
    
    func onDeleteItem(todoId: String) {
        database.softDelete(primaryKey: Int(todoId)!)
    }
    
    func onDoneItem(todoId: String) {
        database.isDone(primaryKey: Int(todoId)!)
    }
    
}


