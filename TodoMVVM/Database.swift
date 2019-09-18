//
//  Database.swift
//  TodoMVVM
//
//  Created by KODAK on 9/18/19.
//  Copyright © 2019 KODAK. All rights reserved.
//

import Foundation
import RealmSwift

class Database {
    static let singleton = Database()
    
    private init() {}
    
    func createOrUpdate(todoItemValue: String) {
        let realm = try! Realm()
        
        var index = 1
        if let lastItem = realm.objects(TodoItem.self).last {
            index = lastItem.todoId + 1
        }
        
        let item = TodoItem()
        item.todoId = index
        item.todoValue = todoItemValue
        
        try! realm.write {
            realm.add(item, update: .all)
        }
    }
    
    func fetch() -> Results<TodoItem>{
        let realm = try! Realm()
        
        let results = realm.objects(TodoItem.self)
        return results
    }
    
    func softDelete(primaryKey: Int) {
        let realm = try! Realm()
        
        if let item = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                item.deletedAt = Date()
            }
        }
    }
    
    func delete(primaryKey: Int) {
        let realm = try! Realm()

        if let item = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(item)
            }
        }
    }
    
    func isDone(primaryKey: Int) {
        let realm = try! Realm()
        
        if let item = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                item.isDone = !item.isDone
            }
        }
    }
}
