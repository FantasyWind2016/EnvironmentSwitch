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

public protocol EnvironmentSwitchChainable {
    func boxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString
    func immutableBoxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString
}

public class BoxedString: EnvironmentSwitchChainable {
    public var rawValue = ""
    var environmentSwitch: EnvironmentSwitch = EnvironmentSwitch()
    init(_ value: String) {
        rawValue = value
    }
    public func boxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString {
        let string = BoxedString(self.rawValue + environmentSwitch.stringForKey(key))
        string.environmentSwitch = self.environmentSwitch
        return string
    }
    
    public func immutableBoxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString {
        let string = BoxedString(self.rawValue + environmentSwitch.immutableStringForKey(key))
        string.environmentSwitch = self.environmentSwitch
        return string
    }
}

public class EnvironmentSwitch: NSObject, EnvironmentSwitchChainable {
    
    //MARK: - public
    
    public static let share = switchWithIdentifier(kDefaultSwitchIdentifier)
    
    public var identifier = kDefaultSwitchIdentifier
    public var currentEnvironment = EnvironmentType.product
    
    /// 获取当前业务私有的实例，保证数据隔离
    ///
    /// - Parameter identifier: 实例标识符，必须保证唯一
    /// - Returns: 实例
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
    
    /// 切换当前环境到指定类型
    ///
    /// - Parameter environment: 环境类型
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
    
    //MARK: - 写数据
    
    /// 设置对应环境的对应值
    ///
    /// - Parameters:
    ///   - string: 值
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    public func setString(_ string: String, forEnvironment environment: EnvironmentType, key: EnvironmentDataKey) {
        saveString(string, for: keyStringForEnvironment(environment, key: key))
    }
    
    /// 设置不可变值（即不同环境中该值不会变化）
    ///
    /// - Parameters:
    ///   - immutableString: 不可变值
    ///   - key: 指定键值名
    public func setImmutableString(_ immutableString: String, key: EnvironmentDataKey) {
        saveImmutableString(immutableString, for: keyStringForImmutableParam(key: key))
    }
    
    /// 加载字典中的数据
    ///
    /// - Parameter dict: 字典
    /// - Returns: 是否成功
    public func loadDataWithJSONFile(_ fn: String) -> Bool {
        if !FileManager.default.fileExists(atPath: fn) {
            return false
        }
        guard let url = URL.init(string: fn) else { return false }
        do {
            guard let data = NSData.init(contentsOfFile: fn) as Data? else {
                return false
            }
            
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                return false
            }
            return self.loadDataWithDict(dict)
        } catch {
            return false
        }
    }
    
    /// 加载字典中的数据
    ///
    /// - Parameter dict: 字典
    /// - Returns: 是否成功
    public func loadDataWithDict(_ dict: Dictionary<String, Any>) -> Bool {
        if let dataDict = dict["data"] as? Dictionary<String, Any> {
            if !self.loadMutableData(dataDict) {
                return false
            }
        }
        if let immutableDataDict = dict["immutableData"] as? Dictionary<String, Any> {
            if !self.loadImmutableData(immutableDataDict) {
                return false
            }
        }
        return true
    }
    
    //MARK: - 读数据
    
    /// 获取当前环境下指定键值名的封包字符串值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 类型：BoxedString，封包后的字符串值，使用时需要解包
    public func boxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString {
        let resut = BoxedString(stringForKey(key))
        resut.environmentSwitch = self
        return resut
    }
    
    /// 获取指定键值名的不可变封包字符串值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 类型：BoxedString，封包后的字符串值，使用时需要解包
    public func immutableBoxedStringForKey(_ key: EnvironmentDataKey) -> BoxedString {
        let resut = BoxedString(immutableStringForKey(key))
        resut.environmentSwitch = self
        return resut
    }
    
    /// 获取当前环境下指定键值名的普通字符串值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 类型：String，字符串值
    public func stringForKey(_ key: EnvironmentDataKey) -> String {
        return stringForEnvironment(currentEnvironment, key: key)
    }
    
    /// 获取指定键值名的不可变普通字符串值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 类型：String，字符串值
    public func immutableStringForKey(_ key: EnvironmentDataKey) -> String {
        var result = immutableDataList[keyStringForImmutableParam(key: key)]
        if result == nil {
            result = ""
        }
        return result!
    }
    
    /// 获取指定环境指定键值名的普通字符串值
    ///
    /// - Parameters:
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    /// - Returns: 普通字符串值
    public func stringForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> String {
        var result = dataList[keyStringForEnvironment(environment, key: key)]
        if result == nil {
            result = ""
        }
        return result!
    }
    
    //MARK: - private
    
    static var switchPool : Dictionary<String, EnvironmentSwitch> = [:]
    lazy var switchDefault = UserDefaults.init(suiteName: "EnvironmentSwitch")
    
    var dataList : Dictionary<String, String> = [:]
    var immutableDataList : Dictionary<String, String> = [:]
    
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
    
    func saveString(_ string: String, for identifier: String) {
        dataList[identifier] = string
    }
    
    func saveImmutableString(_ immutableString: String, for identifier: String) {
        immutableDataList[identifier] = immutableString
    }
    
    func loadMutableData(_ dict: Dictionary<String, Any>) -> Bool {
        if let list = dict["list"] as? Array<Dictionary<String, Any>> {
            for item in list {
                if !self.loadMutableItem(item) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func loadMutableItem(_ dict: Dictionary<String, Any>) -> Bool {
        guard let keyName = dict["key"] as? String else { return false }
        guard let values = dict["values"] as? Dictionary<String, Any> else { return false }
        for envName in values.keys {
            if let value = values[envName] as? String {
                saveString(value, for: keyStringForEnvironmentName(envName, keyName: keyName))
            }
        }
        return true
    }
    
    func loadImmutableData(_ dict: Dictionary<String, Any>) -> Bool {
        if let list = dict["list"] as? Array<Dictionary<String, Any>> {
            for item in list {
                if !self.loadImmutableItem(item) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func loadImmutableItem(_ dict: Dictionary<String, Any>) -> Bool {
        guard let keyName = dict["key"] as? String else { return false }
        guard let value = dict["value"] as? String else { return false }
        saveImmutableString(value, for: keyName)
        return true
    }
    
    func keyStringForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> String {
        return keyStringForEnvironmentName(environment.rawValue, keyName: key.rawValue)
    }
    
    func keyStringForEnvironmentName(_ environmentName: String, keyName: String) -> String {
        return environmentName + keyName
    }
    
    func keyStringForImmutableParam(key: EnvironmentDataKey) -> String {
        return key.rawValue
    }
}
