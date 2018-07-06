//
//  EnvironmentSwitch+Business.swift
//  EnvironmentSwitch_Example
//
//  Created by 季风 on 2018/1/17.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import EnvironmentSwitch

extension EnvironmentDataKey {
    public static let webURL: EnvironmentDataKey = EnvironmentDataKey.init("webURL")
    public static let loginURL: EnvironmentDataKey = EnvironmentDataKey.init("loginURL")
    public static let whatsNew: EnvironmentDataKey = EnvironmentDataKey.init("whatsNew")
}

extension EnvironmentSwitch {
    static let business = switchWithIdentifier("business")
}
