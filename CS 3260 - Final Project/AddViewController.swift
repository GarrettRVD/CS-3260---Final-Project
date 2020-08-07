//
//  AddViewController.swift
//  CS 3260 - Final Project
//
//  Created by Garrett R Van Dyke on 8/5/20.
//  Copyright © 2020 Garrett R Van Dyke. All rights reserved.
//

import FSCalendar
import UIKit

protocol AddTaskProtocol {
    func addTask(_ item: Task)
}

class AddViewController: UIViewController, FSCalendarDelegate {
    
    var delegate:AddTaskProtocol?
    
    var dateString = "";
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var petNameBox: UITextField!
    @IBOutlet weak var petTypeBox: UITextField!
    @IBOutlet weak var taskBox: UITextView!
    
    @objc func saveTask() {

        let newTask = Task(petName:  petNameBox.text!, petType: petTypeBox.text!, task: taskBox.text!, day: dateString)
        
        delegate!.addTask(newTask)
        
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
        
        self.title = "Add New Task"
        
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        
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
