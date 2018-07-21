//
//  SecondViewController.swift
//  finance_app
//
//  Created by AK on 6/12/18.
//  Copyright © 2018 AK. All rights reserved.
//
import Foundation
import UIKit

class SecondViewController: UIViewController {
   // var int = 0
    
    @IBAction func backtoCash(_ sender: UIButton) {
        let viewController:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("view loaded")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
