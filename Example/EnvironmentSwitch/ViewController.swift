//
//  ViewController.swift
//  EnvironmentSwitch
//
//  Created by 季风 on 01/16/2018.
//  Copyright (c) 2018 季风. All rights reserved.
//

import UIKit
import EnvironmentSwitch

class ViewController: UIViewController {
    @IBOutlet weak var environmentLabel: UILabel!
    
    @IBOutlet weak var baseURLLabel: UILabel!
    
    @IBOutlet weak var webURLLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchEnvironment(_ sender: Any) {
        if EnvironmentSwitch.business.currentEnvironment == .product {
            EnvironmentSwitch.business.switchTo(.test)
        } else {
            EnvironmentSwitch.business.switchTo(.product)
        }
        
    }
    
    @IBAction func refreshData(_ sender: Any) {
        environmentLabel.text = EnvironmentSwitch.business.currentEnvironment == .product ? "生产" : "测试"
        baseURLLabel.text = EnvironmentSwitch.business.boxedStringForKey(.baseURL).boxedStringForKey(.loginURL).rawValue
        webURLLabel.text = EnvironmentSwitch.business.boxedStringForKey(.webURL).boxedStringForKey(.whatsNew).rawValue
    }
}

