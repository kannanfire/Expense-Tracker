//
//  ThirdViewController.swift
//  finance_app
//
//  Created by AK on 9/28/18.
//  Copyright © 2018 AK. All rights reserved.
//

import UIKit

class ThirdViewController: ViewController {
   
    
    var totalArr: [ViewController.Info] = []
    
    var list = ["1","2","3"]
    
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var dropDown: UIPickerView!
    
    @IBAction func segueToMainView(_ sender: Any) {
        performSegue(withIdentifier: "viewThreeToOne", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewThreeToOne") {
            _ = segue.destination as! ViewController
            
        }
    }
    

    override func viewDidLoad() {
        //super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
