//
//  AppDelegate.swift
//  EnvironmentSwitch
//
//  Created by 季风 on 01/16/2018.
//  Copyright (c) 2018 季风. All rights reserved.
//

import UIKit
import EnvironmentSwitch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        EnvironmentSwitch.business.setString("https://api.baidu.com", forEnvironment: .product, key: .baseURL)
        EnvironmentSwitch.business.setString("https://test.api.baidu.com", forEnvironment: .test, key: .baseURL)
        EnvironmentSwitch.business.setImmutableString("/login", key: .loginURL)
        EnvironmentSwitch.business.setString("https://www.baidu.com", forEnvironment: .product, key: .webURL)
        EnvironmentSwitch.business.setString("https://test.baidu.com", forEnvironment: .test, key: .webURL)
        EnvironmentSwitch.business.setImmutableString("/whatsNew.html", key: .whatsNew)
        
        if let fn = Bundle.main.path(forResource: "testData", ofType: "json") {
            if EnvironmentSwitch.business.appendDataWithJSONFile(fn) != .success {
                print("testData.json加载失败")
            }
        } else {
            print("testData.json无法找到")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

