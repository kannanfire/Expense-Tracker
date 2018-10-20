//
//  SecondViewController.swift
//  finance_app
//
//  Created by AK on 7/27/18.
//  Copyright © 2018 AK. All rights reserved.
//

import UIKit
import Foundation

class SecondViewController: ViewController {
    
    @IBOutlet var secondTableView: UITableView! = UITableView()
    
    
    @IBAction func changeViews(_ sender: Any) {
        performSegue(withIdentifier: "viewTwoToViewOne", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewTwoToViewOne") {
            _ = segue.destination as! ViewController
            
        }
    }
    
    var totalArr: [ViewController.Info] = []
    
    override func viewDidLoad() {
        
        if(secondTableView != nil) {
            secondTableView.delegate = self
            secondTableView.dataSource = self
            secondTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
            secondTableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = self.secondTableView.dequeueReusableCell(withIdentifier: "cell2")
        cell?.textLabel?.text = self.totalArr[indexPath.row].totalStr
        return cell!
    }
}
