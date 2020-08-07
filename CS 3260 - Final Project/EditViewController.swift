//
//  EditViewController.swift
//  CS 3260 - Final Project
//
//  Created by Garrett R Van Dyke on 8/6/20.
//  Copyright © 2020 Garrett R Van Dyke. All rights reserved.
//

import FSCalendar
import UIKit

protocol EditTaskProtocol {
    func editTask(_ item: Task)
}

class EditViewController: UIViewController, FSCalendarDelegate {
    
    var delegate:EditTaskProtocol?
    
    var dateString = ""
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var taskBox: UITextView!
    
    var currDate: String = ""
    var currTask: String = ""
    
    @objc func saveTask() {
        
        let task = Task(task: taskBox.text!, day: dateString)
        
        delegate?.editTask(task)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
        
        self.title = "Edit Item"
        
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        
        taskBox.text = currTask
        
        
        self.navigationItem.rightBarButtonItem = save
    }
    
    internal func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM/dd/YYYY"
        dateString = formatter.string(from: date)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
