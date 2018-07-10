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
    
    @IBOutlet weak var keyTextField: UITextField!
    
    @IBOutlet weak var valueTextField: UITextField!
    
    @IBOutlet weak var currentValueLabel: UILabel!
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
        baseURLLabel.text = EnvironmentSwitch.business.boxedStringForKey(.mcsBaseURL).immutableBoxedStringForKey(.mcsURL).rawValue
        webURLLabel.text = EnvironmentSwitch.business.boxedStringForKey(.platformBaseURL).immutableBoxedStringForKey(.platformURL).rawValue
        print("showTestInfo:\((EnvironmentSwitch.business.valueForKey(.showTestInfo) as? Bool) ?? false)")
        print("usePgyUpdate:\((EnvironmentSwitch.business.valueForKey(.usePgyUpdate) as? Bool) ?? false)")
        print("repeatTime:\((EnvironmentSwitch.business.valueForKey(.repeatTime) as? Float) ?? 0.0)")
    }
    @IBAction func btnWriteTouched(_ sender: Any) {
        guard let key = self.keyTextField.text else { return }
        guard let value = self.valueTextField.text else {
            return
        }
        EnvironmentSwitch.business.setString(value, forEnvironment: EnvironmentSwitch.business.currentEnvironment, key: EnvironmentDataKey.init(key), needPersist: true)
//        EnvironmentSwitch.business.setImmutableString(value, key: EnvironmentDataKey.init(key), needPersist: true)
    }
    @IBAction func btnReadTouched(_ sender: Any) {
        guard let key = self.keyTextField.text else { return }
        self.currentValueLabel.text = EnvironmentSwitch.business.stringForKey(EnvironmentDataKey.init(key))
//        self.currentValueLabel.text = EnvironmentSwitch.business.immutableStringForKey(EnvironmentDataKey.init(key))
    }
    @IBAction func btnResetTouched(_ sender: Any) {
        EnvironmentSwitch.business.resetPersistentData()
    }
}

