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
    public static let mcsBaseURL: EnvironmentDataKey = EnvironmentDataKey.init("mcsBaseURL")
    public static let platformBaseURL: EnvironmentDataKey = EnvironmentDataKey.init("platformBaseURL")
    public static let mcsURL: EnvironmentDataKey = EnvironmentDataKey.init("mcsURL")
    public static let platformURL: EnvironmentDataKey = EnvironmentDataKey.init("platformURL")
    public static let showTestInfo: EnvironmentDataKey = EnvironmentDataKey.init("showTestInfo")
    public static let usePgyUpdate: EnvironmentDataKey = EnvironmentDataKey.init("usePgyUpdate")
    public static let repeatTime: EnvironmentDataKey = EnvironmentDataKey.init("repeatTime")
}

extension EnvironmentSwitch {
    static let business = switchWithIdentifier("business")
}
