//
//  InputModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

enum InputItemType {
    case Dropdown
    case Text
    case Int
    case Double
    case Date
    case Switch
    case TextArea
    case RadioSwitch
    case ViewField
    case RadioBoolean
    case Time
    case Stepper
    case Spacer
    case Title
}

enum InputItemWidthSize {
    case Full
    case Half
    case Third
    case Forth
    case Fill
}

struct InputValue {
    var boolean: Bool?
    var string: String?
    var date: Date?
    var int: Int?
    var double: Double?
    var itemId: String?
    var time: String?
    
    func get(type: InputItemType) -> Any? {
        switch type {
        case .Dropdown:
            return self.itemId
        case .Text:
            return self.string
        case .Int:
            return self.int
        case .Double:
            return self.double
        case .Date:
            return self.date
        case .Switch:
            return self.boolean
        case .TextArea:
            return self.string
        case .RadioSwitch:
            return self.boolean
        case .ViewField:
            return self.string
        case .RadioBoolean:
            return self.boolean
        case .Time:
            return self.time
        case .Stepper:
            return self.int
        case .Spacer:
            return nil
        case .Title:
            return self.string
        }
    }
    
    mutating func set(value: Any?, type: InputItemType) {
        switch type {
        case .Dropdown:
            self.itemId = value as? String
        case .Text:
            self.string = value as? String
        case .Int:
            self.int = value as? Int
        case .Double:
            self.double = value as? Double
        case .Date:
            self.date = value as? Date
        case .Switch:
            self.boolean = value as? Bool
        case .TextArea:
            self.string = value as? String
        case .RadioSwitch:
            self.boolean = value as? Bool
        case .ViewField:
            self.string = value as? String
        case .RadioBoolean:
            self.boolean = value as? Bool
        case .Time:
            self.time = value as? String
        case .Stepper:
            self.int = value as? Int
        case .Spacer:
            break
        case .Title:
            self.string = value as? String
        }
    }
}

struct InputDependency {
    public var item: InputItem
    private var _value: InputValue
    private var notNull: Bool = false
    
    
    /// Set the Input item and value to watch for. If not value is specified,
    /// it will watch for any value existing ( != ni l)
    /// - Parameter item: Input item to watch for.
    /// - Parameter value: Input item value to watch for.
    public init(to item: InputItem, equalTo value: Any? = nil) {
        self.item = item
        self._value = InputValue()
        self._value.set(value: value, type: item.type)
        if value == nil {
            self.notNull = true
        }
    }
    
    public func isSatisfied() -> Bool {
        if self.notNull {
            return item.value.get(type: item.type) != nil
        }
        switch item.type {
        case .Dropdown:
            return item.value.get(type: item.type) as? String == _value.get(type: item.type) as? String
        case .Text:
            return item.value.get(type: item.type) as? String == _value.get(type: item.type) as? String
        case .Int:
            return item.value.get(type: item.type) as? Int == _value.get(type: item.type) as? Int
        case .Double:
            return item.value.get(type: item.type) as? Double == _value.get(type: item.type) as? Double
        case .Date:
            return item.value.get(type: item.type) as? Date == _value.get(type: item.type) as? Date
        case .Switch:
            return item.value.get(type: item.type) as? Bool == _value.get(type: item.type) as? Bool
        case .TextArea:
            return item.value.get(type: item.type) as? String == _value.get(type: item.type) as? String
        case .RadioSwitch:
            return item.value.get(type: item.type) as? Bool == _value.get(type: item.type) as? Bool
        case .ViewField:
            return item.value.get(type: item.type) as? String == _value.get(type: item.type) as? String
        case .RadioBoolean:
            return item.value.get(type: item.type) as? Bool == _value.get(type: item.type) as? Bool
        case .Time:
            return item.value.get(type: item.type) as? TimeInterval == _value.get(type: item.type) as? TimeInterval
        case .Stepper:
            return item.value.get(type: item.type) as? Int == _value.get(type: item.type) as? Int
        case .Spacer:
            return false
        case .Title:
            return item.value.get(type: item.type) as? String == _value.get(type: item.type) as? String
        }
    }
}

enum ComputedFieldRule {
    case Multiply
    case Add
}

struct FieldComputation {
    var rule: ComputedFieldRule
    var dependees: [InputDependency]
    
    public init(fields: [InputItem], rule: ComputedFieldRule) {
        self.dependees = []
        for field in fields {
            self.dependees.append(InputDependency(to: field))
        }
        self.rule = rule
    }
}

protocol InputItem {
    var type: InputItemType { get set }
    var width: InputItemWidthSize { get set }
    var height: CGFloat { get set }
    var key: String { get set }
    var value: InputValue { get set }
    var header: String { get set }
    var editable: Bool { get set }
    var dependency: InputDependency? { get set }
}

protocol StringInputItem: InputItem {
    var value: String? {get set}
}

class ViewField: InputItem {
    var type: InputItemType = .ViewField
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String = ""
    var value: InputValue
    var header: String = ""
    var editable: Bool = false
    var dependency: InputDependency?
    var computation: FieldComputation?
    
    init(header: String, computation: FieldComputation? = nil, width: InputItemWidthSize? = .Full) {
        self.header = header
        self.computation = computation ?? nil
        self.width = width ?? .Full
        self.value = InputValue()
        self.value.set(value: "", type: type)
    }
    
    func getValue() -> String? {
        return self.value.get(type: self.type) as? String ?? nil
    }
    
    func setValue(value: String?) {
        self.value.set(value: value, type: self.type)
    }
}

class DropdownInput: InputItem {
    var dependency: InputDependency?
    var value: InputValue
    var type: InputItemType = .Dropdown
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var editable: Bool
    
    var dropdownItems: [DropdownModel] = []
    var header: String
    
    init(key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full, dropdownItems: [DropdownModel]? = []) {
        self.value = InputValue()
        self.value.set(value: value ?? "", type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
        self.dropdownItems = dropdownItems ?? []
    }
    
    func getValue() -> String? {
        return self.value.get(type: self.type) as? String ?? nil
    }
    
    func setValue(value: String?) {
        self.value.set(value: value, type: self.type)
    }
}

class TextInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Text
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var editable: Bool
    var header: String
    
    init(key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> String? {
        return self.value.get(type: self.type) as? String ?? nil
    }
    
    func setValue(value: String?) {
        self.value.set(value: value, type: self.type)
    }
}

class SwitchInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Switch
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Bool? = false, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value ?? false, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Bool? {
        return self.value.get(type: self.type) as? Bool ?? nil
    }
    
    func setValue(value: Bool?) {
        self.value.set(value: value, type: self.type)
    }
}

class DateInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Date
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Date? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Date? {
        return self.value.get(type: self.type) as? Date ?? nil
    }
    
    func setValue(value: Date?) {
        self.value.set(value: value, type: self.type)
    }
}

class TimeInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Time
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: String? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Time? {
        let stringValue: String = self.value.get(type: self.type) as? String ?? ""
        if stringValue == "" {return nil}
        return Time(string: stringValue)
    }
    
    func setValue(value: Time?) {
        self.value.set(value: value?.toString(), type: self.type)
    }
}

class TextAreaInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .TextArea
    var width: InputItemWidthSize
    var height: CGFloat = 200
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: String? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> String? {
        return self.value.get(type: self.type) as? String ?? nil
    }
    
    func setValue(value: String?) {
        self.value.set(value: value, type: self.type)
    }
}

class IntegerInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Int
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Int? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Int? {
        return self.value.get(type: self.type) as? Int ?? nil
    }
    
    func setValue(value: Int?) {
        self.value.set(value: value, type: self.type)
    }
}

class IntegerStepperInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Stepper
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Int? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Int? {
        return self.value.get(type: self.type) as? Int ?? nil
    }
    
    func setValue(value: Int?) {
        self.value.set(value: value, type: self.type)
    }
}

class DoubleInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Double
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Double? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Double? {
        return self.value.get(type: self.type) as? Double ?? nil
    }
    
    func setValue(value: Double?) {
        self.value.set(value: value, type: self.type)
    }
}

class RadioSwitchInput: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .RadioSwitch
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Bool? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Bool? {
        return self.value.get(type: self.type) as? Bool ?? nil
    }
    
    func setValue(value: Bool?) {
        self.value.set(value: value, type: self.type)
    }
}

class RadioBoolean: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .RadioBoolean
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Bool? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Bool? {
        return self.value.get(type: self.type) as? Bool ?? nil
    }
    
    func setValue(value: Bool?) {
        self.value.set(value: value, type: self.type)
    }
}

class InputSpacer: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Spacer
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(width: InputItemWidthSize? = .Fill, height: CGFloat? = 70) {
        self.key = UUID().uuidString
        self.value = InputValue()
        self.header = ""
        self.editable = false
        self.width = width ?? .Fill
        
    }
}

class InputTitle: InputItem {
    var dependency: InputDependency?
    var type: InputItemType = .Title
    var width: InputItemWidthSize
    var height: CGFloat = 30
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(title: String, width: InputItemWidthSize? = .Full, height: CGFloat? = 30) {
        self.key = UUID().uuidString
        self.value = InputValue()
        self.value.set(value: title, type: type)
        self.header = ""
        self.editable = false
        self.width = width ?? .Full
        
    }
}
