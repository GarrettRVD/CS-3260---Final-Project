//
//  ViewController.swift
//  CS 3260 - Final Project
//
//  Created by Garrett R Van Dyke on 8/5/20.
//  Copyright © 2020 Garrett R Van Dyke. All rights reserved.
//

import UIKit
import UIKit
import SQLite3

struct Task {
    var petName: String = ""
    var petType: String = ""
    var task: String = ""
    var day: String = ""
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddTaskProtocol, EditTaskProtocol {
    
    var db: OpaquePointer?
    
    var tasks: [Task]! = []
    var taskIndex: Int!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        let selectedItem = tasks[indexPath.row]
        
        cell.textLabel?.text = selectedItem.task + " - " + selectedItem.petName
        cell.detailTextLabel?.text = selectedItem.day
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            let view = segue.destination as! AddViewController
            view.delegate = self
        } else if segue.identifier == "editSegue" {
            let view = segue.destination as! EditViewController
            view.delegate = self
            taskIndex = tableView.indexPathForSelectedRow?.row
            view.currDate = tasks[taskIndex].day
            view.currTask = tasks[taskIndex].task
        }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        print(task)
        print(tasks!)
        tableView.reloadData()
    }
    func editTask(_ task: Task) {
        tasks[taskIndex].task = task.task
        tasks[taskIndex].day = task.day
        tableView.reloadData()
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Pet Tasks"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveToDatabase(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("PetTasks.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
        
        let createTableQuery = "Create Table IF NOT EXISTS Tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, petName VARCHAR, petType VARCHAR, task VARCHAR, day VARCHAR)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
        }
        
        readValues()
    }

    func readValues() {
        
        let queryString = "SELECT petName, petType, task, day FROM Tasks"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let petName = String(cString: sqlite3_column_text(stmt, 0))
            let petType = String(cString: sqlite3_column_text(stmt, 1))
            let task = String(cString: sqlite3_column_text(stmt, 2))
            let day = String(cString: sqlite3_column_text(stmt, 3))
            
            tasks.append(Task(petName: String(describing: petName), petType: String(describing: petType), task: String(describing: task), day: String(describing: day)))
        }
        
        tableView.reloadData()
    }
    
    @objc func saveToDatabase(_ notification:Notification) {
        
        var stmt: OpaquePointer?
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("PetTasks.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        }
        
        let queryStringDelete = "DELETE FROM Tasks"
        
        let queryStringInsert = "INSERT INTO Tasks (petName, petType, task, day) VALUES (?,?,?,?)"
        
        if sqlite3_exec(db, queryStringDelete, nil, nil, nil) != SQLITE_OK {
            print("Error deleting items")
        }
        
        for task in tasks {
            
            let petName = task.petName
            let petType = task.petType
            let task = task.task
        
            if sqlite3_prepare(db, queryStringInsert, -1, &stmt, nil) !=    SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 1, (petName as  NSString).utf8String, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure binding petName: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, (petType as   NSString).utf8String, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure binding petType: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, (task as   NSString).utf8String, -1, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure binding task: \(errmsg)")
                return
            }
            

            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure inserting item: \(errmsg)")
                return
            }
            
        }
        
        sqlite3_close(db)
        
    }

}

