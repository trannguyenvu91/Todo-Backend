//
//  MDItem.swift
//  CookRecipes
//
//  Created by VuVince on 2/7/18.
//

import Foundation
import MySQLStORM
import StORM
import PerfectLib

class MDTodoItem: MySQLStORM {
    var id: Int = 0
    var item: String = "Description"
    var due: String = "NULL"
    var completed: Int = 0
    var associatedUser: String = ""
    
    var dueDate: Date {
        get {
            return MDConstant.getDate(due) ?? MDConstant.getCurrentDate()
        }
        set {
            due = MDConstant.getString(date: newValue)
        }
    }
    
    var isCompleted: Bool {
        get {
            return completed == 1
        }
        set {
            completed = newValue ? 1 : 0
        }
    }
    
    func update(completed: Int?, due: String?, newName name: String?) {
        self.completed = completed ?? 0
        self.due = due ?? "NULL"
        self.item = name ?? "Description"
    }
    
    override func table() -> String {
        return "todo_items"
    }
    
    override func to(_ this: StORMRow) {
        id = Int(this.data["id"] as? Int32 ?? 0)
        item = this.data["item"] as? String ?? "Description"
        due = this.data["due"] as? String ?? ""
        completed = Int(this.data["completed"] as? Int32 ?? 0)
        associatedUser = this.data["associatedUser"] as? String ?? ""
    }
    
    func rows() -> [MDTodoItem] {
        let searchResults = self.results.rows
        return searchResults.map({ (row) -> MDTodoItem in
            let item = MDTodoItem()
            item.to(row)
            return item
        })
    }
    
    func asJSON() -> JSON {
        return ["id": id, "item": item, "due": due, "completed": completed, "associatedUser": associatedUser]
    }
    
}
