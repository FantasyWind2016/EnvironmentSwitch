//
//  EnvironmentSwitch.swift
//  EnvironmentSwitch
//
//  Created by 季风 on 2018/1/17.
//

import Foundation

let kDefaultSwitchIdentifier = "share"
let kKeyCurrentEnvironment = "currentEnvironment"


public enum EnvironmentType: String {
    case develop = "develop"
    case test = "test"
    case beta = "beta"
    case uat = "uat"
    case product = "product"
}

public struct EnvironmentDataKey : RawRepresentable, Equatable, Hashable {
    public var rawValue: String
    
    public var hashValue: Int
    
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
        self.hashValue = rawValue.hashValue
    }
    
    public init(rawValue: String) {
        self.rawValue = rawValue
        self.hashValue = rawValue.hashValue
    }
}

extension EnvironmentDataKey {
    public static let baseURL: EnvironmentDataKey = EnvironmentDataKey.init("baseURL")
}

public class EnvironmentSwitch: NSObject {
    static var switchPool : Dictionary<String, EnvironmentSwitch> = [:]
    public static let share = switchWithIdentifier(kDefaultSwitchIdentifier)
    public class func switchWithIdentifier(_ identifier: String) -> EnvironmentSwitch {
        if let tmpSwitch = switchPool[identifier] {
            return tmpSwitch
        }
        let newSwitch = EnvironmentSwitch()
        newSwitch.identifier = identifier
        newSwitch.loadData()
        switchPool[identifier] = newSwitch
        return newSwitch
    }
    
    public var identifier = kDefaultSwitchIdentifier
    public var currentEnvironment = EnvironmentType.product
    lazy var switchDefault = UserDefaults.init(suiteName: "EnvironmentSwitch")
    public func switchTo(_ environment: EnvironmentType) {
        currentEnvironment = environment
        switchDefault?.set(currentEnvironment.rawValue, forKey: saveKey(forKey: kKeyCurrentEnvironment))
        switchDefault?.synchronize()
    }
    
    /// 是否手动切换过环境
    ///
    /// - Returns: 是否
    public func hadSwitched() -> Bool {
        if let raw = switchDefault?.string(forKey: saveKey(forKey: kKeyCurrentEnvironment)) {
            if let _ = EnvironmentType.init(rawValue: raw) {
                return true
            }
        }
        return false
    }
    
    func loadData() {
        if let raw = switchDefault?.string(forKey: saveKey(forKey: kKeyCurrentEnvironment)) {
            if let current = EnvironmentType.init(rawValue: raw) {
                switchTo(current)
            }
        }
    }
    
    func saveKey(forKey key: String) -> String {
        return "kUserDefault_" + identifier + "_" + key
    }
    
    var dataList : Dictionary<String, String> = [:]
    public func setString(_ string: String, forEnvironment environment: EnvironmentType, key: EnvironmentDataKey) {
        dataList[keyStringForEnvironment(environment, key: key)] = string
    }
    public func stringForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> String? {
        return dataList[keyStringForEnvironment(environment, key: key)]
    }
    public func stringForKey(_ key: EnvironmentDataKey) -> String? {
        return stringForEnvironment(currentEnvironment, key: key)
    }
    func keyStringForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> String {
        return environment.rawValue + key.rawValue
    }
}
