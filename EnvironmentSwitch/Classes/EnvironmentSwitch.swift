//
//  EnvironmentSwitch.swift
//  EnvironmentSwitch
//
//  Created by 季风 on 2018/1/17.
//

import Foundation

let kDefaultSwitchIdentifier = "share"
let kKeyCurrentEnvironment = "currentEnvironment"
let kKeyPersistentData = "PersistentData"
let kKeyPersistentImmutableData = "PersistentImmutableData"


public enum EnvironmentType: String {
    case develop = "develop"
    case test = "test"
    case beta = "beta"
    case uat = "uat"
    case product = "product"
}

extension NSNotification {
    /// 环境切换后触发，参数中包含preEnvironment和currentEnvironment
    static let environmentSwitched = NSNotification.Name("EnvironmentSwitched")
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

public enum LoadDataResult {
    case success
    case fileNotExist
    case fileReadError
    case JSONParseError
    case JSONNil
    case saveMutableDataError
    case saveImmutableDataError
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
        let oldValue = currentEnvironment
        currentEnvironment = environment
        switchDefault?.set(currentEnvironment.rawValue, forKey: saveKey(forKey: kKeyCurrentEnvironment))
        switchDefault?.synchronize()
        NotificationCenter.default.post(name: NSNotification.environmentSwitched, object: self, userInfo: ["preEnvironment": oldValue.rawValue,"currentEnvironment": currentEnvironment.rawValue])
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
    
    /// 设置对应环境的对应字符串
    ///
    /// - Parameters:
    ///   - string: 字符串
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    public func setString(_ string: String, forEnvironment environment: EnvironmentType, key: EnvironmentDataKey, needPersist: Bool = false) {
        saveString(string, for: keyStringForEnvironment(environment, key: key), needPersist: needPersist)
    }
    
    /// 设置不可变字符串（即不同环境中该字符串不会变化）
    ///
    /// - Parameters:
    ///   - immutableString: 不可变字符串
    ///   - key: 指定键值名
    public func setImmutableString(_ immutableString: String, key: EnvironmentDataKey, needPersist: Bool = false) {
        saveImmutableString(immutableString, for: keyStringForImmutableParam(key: key), needPersist: needPersist)
    }
    
    /// 设置对应环境的对应值
    ///
    /// - Parameters:
    ///   - value: 值，可选类型，nil时会清除原值
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    public func setValue(_ value: Any?, forEnvironment environment: EnvironmentType, key: EnvironmentDataKey, needPersist: Bool = false) {
        saveValue(value, for: keyStringForEnvironment(environment, key: key), needPersist: needPersist)
    }
    
    /// 设置不可变值（即不同环境中该值不会变化）
    ///
    /// - Parameters:
    ///   - immutableString: 不可变值，nil时会清除原值
    ///   - key: 指定键值名
    public func setImmutableValue(_ immutableValue: Any?, key: EnvironmentDataKey, needPersist: Bool = false) {
        saveImmutableValue(immutableValue, for: keyStringForImmutableParam(key: key), needPersist: needPersist)
    }
    
    /// 清除所有可变与不可变数据
    public func clearAllData() {
        clearMutableData()
        clearImmutableData()
    }
    
    /// 清除所有可变数据
    public func clearMutableData() {
        dataList.removeAll()
    }
    
    /// 清除所有不可变数据
    public func clearImmutableData() {
        immutableDataList.removeAll()
    }
    
    /// 清除所有的缓存数据
    public func resetPersistentData() {
        persistentDataList.removeAll()
        persistentImmutableDataList.removeAll()
        switchDefault?.removeObject(forKey: saveKey(forKey: kKeyPersistentData))
        switchDefault?.removeObject(forKey: saveKey(forKey: kKeyPersistentImmutableData))
        switchDefault?.synchronize()
    }
    
    /// 添加JSON文件中的数据，不会清空原数据
    ///
    /// - Parameter fn: 文件路径
    /// - Returns: 是否成功
    public func appendDataWithJSONFile(_ fn: String) -> LoadDataResult {
        if !FileManager.default.fileExists(atPath: fn) {
            return .fileNotExist
        }
        guard let data = NSData.init(contentsOfFile: fn) as Data? else {
            return .fileReadError
        }
        do {
            guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                return .JSONNil
            }
            return self.appendDataWithDict(dict)
        } catch {
            switch error {
            default:
                print(error.localizedDescription)
            }
            return .JSONParseError
        }
    }
    
    /// 添加字典中的数据，不会清空原数据
    ///
    /// - Parameter dict: 字典
    /// - Returns: 是否成功
    public func appendDataWithDict(_ dict: Dictionary<String, Any>) -> LoadDataResult {
        if let dataDict = dict["data"] as? Dictionary<String, Any> {
            if !self.loadMutableData(dataDict) {
                return .saveMutableDataError
            }
        }
        if let immutableDataDict = dict["immutableData"] as? Dictionary<String, Any> {
            if !self.loadImmutableData(immutableDataDict) {
                return .saveImmutableDataError
            }
        }
        return .success
    }
    
    /// 加载JSON文件中的数据，会清空原数据
    ///
    /// - Parameter fn: 文件路径
    /// - Returns: 是否成功
    public func loadDataWithJSONFile(_ fn: String) -> LoadDataResult {
        clearAllData()
        return appendDataWithJSONFile(fn)
    }
    
    /// 加载字典中的数据，会清空原数据
    ///
    /// - Parameter dict: 字典
    /// - Returns: 是否成功
    public func loadDataWithDict(_ dict: Dictionary<String, Any>) -> LoadDataResult {
        clearAllData()
        return appendDataWithDict(dict)
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
    
    /// 获取当前环境下指定键值名的值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 值
    public func valueForKey(_ key: EnvironmentDataKey) -> Any? {
        return valueForEnvironment(currentEnvironment, key: key)
    }
    
    /// 获取指定键值名的不可变普通字符串值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 类型：String，字符串值
    public func immutableStringForKey(_ key: EnvironmentDataKey) -> String {
        var result = immutableValueForKey(key) as? String
        if let _ = result {
            
        } else {
            result = ""
        }
        return result!
    }
    
    /// 获取指定键值名的不可变值
    ///
    /// - Parameter key: 指定键值名
    /// - Returns: 值
    public func immutableValueForKey(_ key: EnvironmentDataKey) -> Any? {
        if let result = persistentImmutableDataList[keyStringForImmutableParam(key: key)] {
            return result
        }
        return immutableDataList[keyStringForImmutableParam(key: key)]
    }
    
    /// 获取指定环境指定键值名的普通字符串值
    ///
    /// - Parameters:
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    /// - Returns: 普通字符串值
    public func stringForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> String {
        var result = valueForEnvironment(environment, key: key) as? String
        if let _ = result {
            
        } else {
            result = ""
        }
        return result!
    }
    
    /// 获取指定环境指定键值名的值
    ///
    /// - Parameters:
    ///   - environment: 指定环境类型
    ///   - key: 指定键值名
    /// - Returns: 值
    public func valueForEnvironment(_ environment: EnvironmentType, key: EnvironmentDataKey) -> Any? {
        if let result = persistentDataList[keyStringForEnvironment(environment, key: key)] {
            return result
        }
        return dataList[keyStringForEnvironment(environment, key: key)]
    }
    
    //MARK: - private
    
    static var switchPool : Dictionary<String, EnvironmentSwitch> = [:]
    lazy var switchDefault = UserDefaults.init(suiteName: "EnvironmentSwitch")
    
    var dataList : Dictionary<String, Any> = [:]
    var immutableDataList : Dictionary<String, Any> = [:]
    var persistentDataList : Dictionary<String, Any> = [:]
    var persistentImmutableDataList : Dictionary<String, Any> = [:]
    
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
    
    func saveString(_ string: String, for identifier: String, needPersist: Bool = false) {
        saveValue(string, for: identifier, needPersist: needPersist)
    }
    
    func saveValue(_ value: Any?, for identifier: String, needPersist: Bool = false) {
        // 需要持久化的数据分开存储以保留原始数据
        guard let value = value else {
            if needPersist {
                persistentDataList.removeValue(forKey: identifier)
                switchDefault?.setValue(persistentDataList, forKey: saveKey(forKey: kKeyPersistentData))
                switchDefault?.synchronize()
            } else {
                dataList.removeValue(forKey: identifier)
            }
            return
        }
        if needPersist {
            persistentDataList[identifier] = value
            switchDefault?.setValue(persistentDataList, forKey: saveKey(forKey: kKeyPersistentData))
            switchDefault?.synchronize()
        } else {
            dataList[identifier] = value
        }
    }
    
    func saveImmutableString(_ immutableString: String, for identifier: String, needPersist: Bool = false) {
        saveImmutableValue(immutableString, for: identifier, needPersist: needPersist)
    }
    
    func saveImmutableValue(_ immutableValue: Any?, for identifier: String, needPersist: Bool = false) {
        guard let immutableValue = immutableValue else {
            if needPersist {
                persistentImmutableDataList.removeValue(forKey: identifier)
                switchDefault?.setValue(persistentDataList, forKey: saveKey(forKey: kKeyPersistentImmutableData))
                switchDefault?.synchronize()
            } else {
                immutableDataList.removeValue(forKey: identifier)
            }
            return
        }
        if needPersist {
            persistentImmutableDataList[identifier] = immutableValue
            switchDefault?.setValue(persistentImmutableDataList, forKey: saveKey(forKey: kKeyPersistentImmutableData))
            switchDefault?.synchronize()
        } else {
            immutableDataList[identifier] = immutableValue
        }
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
            let value = values[envName]
            saveValue(value, for: keyStringForEnvironmentName(envName, keyName: keyName))
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
        let value = dict["value"]
        saveImmutableValue(value, for: keyName)
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
