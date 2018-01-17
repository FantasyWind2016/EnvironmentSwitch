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
}

extension EnvironmentSwitch {
    static let business = switchWithIdentifier("business")
}
