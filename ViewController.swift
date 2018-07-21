//
//  ViewController.swift
//  finance_app
//
//  Created by AK on 6/12/18.
//  Copyright © 2018 AK. All rights reserved.
//
import Foundation
import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    ///////////////////////////////////////////////////////
    // date, description, amount, balance WHAT MOM WANTS //
    ///////////////////////////////////////////////////////
    
    /*
     we already have balance and amount. now we need date and description
     
     the format in the list should be in the order she requested.
     
     We can make it change by date order later, latest date first.
     
     three arrays for date just to be safe, until we find a better solution
     
     */
    
    var total:Double = 0.00
    
    var totalArray: [Info] = []
    
    var db: OpaquePointer?
    
    
    
    struct Info {
        //var id: Int
        var date: String
        var description: String
        var amount: Double
        var totalStr: String
    }
    
    @IBOutlet weak var descriptionOutlet: UITextField!
    
    @IBOutlet weak var dateText_nonaction: UITextField!
    /* switches to the debit view controller */
    
    @IBAction func backToDebit(_ sender: UIButton) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    //DO THIS LATER YOU FUCK
    // String(format: "%.2f", var) //
    
    //keeps track of date | description | amount at transaction | and the total balance at the time
    
    
    @IBAction func dateTextField(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(ViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
        self.addDoneButtonOnKeyboard(view: sender)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateText_nonaction.text = dateFormatter.string(from: sender.date)
    }
    
    //this is just where you scroll through the table
    @IBOutlet weak var transaction_display: UIScrollView!
    
    //enter the amount, will be adding other stuff in the future
    @IBOutlet weak var enterAmount: UITextField!
    
    //this is the actual table which dynamically changes as you add more things to the
    @IBOutlet weak var tableView: UITableView!
    
    //the label that shows the total, there is a label above it with no outlet as it only shows "Total:"
    @IBOutlet weak var totalView: UILabel!
    
    //this is where the magic happens using the enter button.
    // more indepth later
    @IBAction func submitAmountToTotal(_ sender: UIButton) {
        var amount:Double, date: String, addToTotalArr: String
        var description: String
        let dateText = Date()
        let dateForm = DateFormatter.localizedString(from: dateText, dateStyle: .medium, timeStyle: .none)
        
        date = convertDateFormat(self.dateText_nonaction.text!)
        if date == "False" {
            self.dateText_nonaction.text = "Invalid Date"
            return
        } else {
            date = self.convertDateTo_MM_DD_YYYY(date: date)
        }
        
        if(enterAmount.text!.doubleValue != nil) {
            amount = enterAmount.text!.doubleValue!
            total += amount
        } else if(enterAmount.text!.integerValue != nil) {
            amount = Double(enterAmount.text!.integerValue!)
            total += amount
        } else {
            enterAmount.text = "Invalid Value"
            self.dateText_nonaction.text = dateForm
            return
        }
        
        description = self.descriptionOutlet.text!
        
        let amountStr:String = String(format: "%.2f", amount)
        
        addToTotalArr = "\(date) \(description) \(amountStr)"
        
        totalView.text = "\(String(format: "%.2f", total))"
        tableView.reloadData()
        enterAmount.text = " "
        
        self.dateText_nonaction.text = dateForm
        
        valueCreation(date, description, amount, addToTotalArr)
        total = readValues()
        self.totalView.text! = String(format: "%.2f", total)
        self.setUILabelColorToRedOrGreen()
    }
    
    func readValues() -> Double {
        totalArray.removeAll()
        
        let queryString = "SELECT * FROM Information"
        var stmt: OpaquePointer?, total: Double = 0
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return -1
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let date = String(cString: sqlite3_column_text(stmt, 0))
            let description = String(cString: sqlite3_column_text(stmt, 1))
            let amount = sqlite3_column_double(stmt, 2)
            let finalStr = String(cString: sqlite3_column_text(stmt, 3))
            
            //adding values to list
            totalArray.insert(Info(date: date, description: description, amount: amount, totalStr: finalStr), at: 0)
            total += amount
        }
        
        
        self.tableView.reloadData()
        self.setUILabelColorToRedOrGreen()
        return total;
    }
    
    func valueCreation(_ date: String, _ description: String, _ amount: Double, _ totalStr: String) {
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Information(date, description, amount, totalStr) VALUES(?,?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 1, date, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, description, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 3, amount) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 4, totalStr, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        print("Saved successfully!")
    }
    
    
    //checks to see if the date is actually the date, otherwise it returns False which is used for a check
    func convertDateFormat(_ date: String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd, yyyy"
        let someDate = date
        
        if dateFormatterGet.date(from: someDate) != nil {
            return date
        } else {
            return "False"
        }
    }
    func checkDateFormat(_ date: String) -> Int{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy"
        let someDate = date
        
        if dateFormatterGet.date(from: someDate) != nil {
            return 0
        } else {
            return -1
        }
    }
    
    //converts the date
    func convertDateTo_MM_DD_YYYY(date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM dd, yyyy"
        let showDate = inputFormatter.date(from: date)
        inputFormatter.dateFormat = "MM-dd-yyyy"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("MothersRecords.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Information (date TEXT, description TEXT, amount REAL,  totalStr TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        
        let date = Date()
        let dateForm = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        self.dateText_nonaction.text = dateForm
        
        self.addDoneButtonOnKeyboard(view: self.descriptionOutlet)
        self.addDoneButtonOnKeyboard(view: self.enterAmount)
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.total += self.readValues()
        
        self.totalView.text = String(format: "%.2f", total)
        
        self.totalView.font = UIFont.boldSystemFont(ofSize: 20.0)
        self.setUILabelColorToRedOrGreen()
    }
    
    func setUILabelColorToRedOrGreen() {
        if(self.total < 0) {
            self.totalView.textColor = UIColor.red
        } else {
            self.totalView.textColor = UIColor.green
        }
        self.totalView.text! = String(format: "%.2f", total)
    }
    
    func addDoneButtonOnKeyboard(view: UIView?) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:50))
        doneToolbar.barStyle = UIBarStyle.blackOpaque
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: view, action: #selector(UIResponder.resignFirstResponder))
        var items = [AnyObject]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = (items as! [UIBarButtonItem])
        doneToolbar.sizeToFit()
        if let accessorizedView = view as? UITextView {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        } else if let accessorizedView = view as? UITextField {
            accessorizedView.inputAccessoryView = doneToolbar
            accessorizedView.inputAccessoryView = doneToolbar
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.minimumScaleFactor = 0.1
        
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 11.0)
        
        cell?.textLabel?.text = self.totalArray[indexPath.row].totalStr
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let int = indexPath.row + 1
        let info = self.totalArray[indexPath.row]
        print("You selected cell #\(int)! && totalStr from table is \"\(info.totalStr)\"")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(self.totalArray[indexPath.row]);
            self.totalArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            self.total = self.readValues()
            self.totalView.text = String(self.total)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func delete(_ info: Info) {
        let queryString = "DELETE FROM Information WHERE totalStr = \"\(info.totalStr)\""
        var stmt: OpaquePointer?
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) == SQLITE_OK {
            if(sqlite3_step(stmt) == SQLITE_DONE) {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing delete: \(errmsg)")
        }
        sqlite3_finalize(stmt)
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var updateStr:String = "", date:String = "", amount:Double = 0, description:String = ""
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit list item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = self.totalArray[indexPath.row].totalStr
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                
                updateStr = alert.textFields!.first!.text!
                
                date = self.getDate(updateStr)
                if(self.checkDateFormat(date) == -1) {
                    alert.textFields!.first!.text = "Invalid Date"
                    return
                }
                
                description = self.getDescription(updateStr)
                amount = self.getAmount(updateStr)
                
                
                self.delete(self.totalArray[indexPath.row])
                self.totalArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
                
                
                self.valueCreation(date, description, amount, updateStr)
                
                
                self.total = self.readValues()
                self.totalView.text = String(format: "%.2f", self.total)
                self.setUILabelColorToRedOrGreen()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.delete(self.totalArray[indexPath.row]);
            self.totalArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            self.total = self.readValues()
            self.totalView.text = String(self.total)
            self.setUILabelColorToRedOrGreen()
        })
        
        return [deleteAction, editAction]
    }
    //This is a comment to test it out
    //MM-dd-yyyy size: 10 so 0-9 is length of all strings
    func getDate(_ str: String) -> String {
        return String(str.prefix(10));
    }
    
    func getDescription(_ str: String) -> String {
        let start = str.index(str.startIndex, offsetBy: 11)
        let end = str.index(str.endIndex, offsetBy: (-1 * getLastIndexForDescription(str))-1)
        let range = start..<end
        let sub = String(str[range])
        return sub;
    }
    
    func getAmount(_ str: String) -> Double {
        let size = getLastIndexForDescription(str)
        let amount:Double = Double(String(str.suffix(size)))!
        return amount;
    }
    
    func getLastIndexForDescription(_ str: String) -> Int{
        var count:Int = 0
        for i in 0...str.count-1 {
            
            let index2 = str.index(str.startIndex, offsetBy: str.count-1-i) //will call succ 2 times
            let lastChar: Character = str[index2] //now we can index!
            print(lastChar)
            
            if lastChar == " " {
                break;
            }
            count += 1
        }
        return count;
    }
}

extension String {
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return NumFormatter.instance.number(from: self)?.doubleValue
    }
    
    var integerValue: Int? {
        return NumFormatter.instance.number(from: self)?.intValue
    }
}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
