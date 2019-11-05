//
//  FormEntryViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class FormEntryViewController: BaseViewController {
    
    @IBOutlet weak var container: UIView!
    // MARK: Variables
    var inputItems: [InputItem] = []
    
    // MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(hidden: false, style: UIBarStyle.default)
        addTestData()
        let inputGroup: InputGroupView = InputGroupView()
        inputGroup.initialize(with: self.inputItems, delegate: self, in: container)
        
    }
    
    // MARK: Outlet actions
    @IBAction func testAction(_ sender: UIButton) {
        Banner.show(message: "hello!!!")
        for item in self.inputItems {
            print(item.value.get(type: item.type) ?? "Not Set")
        }
    }
    
    // MARK: Temporary
    private func addTestData() {
        self.inputItems = []
        var options: [DropdownModel] = []
        
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        
        /// Dropdowns
        let drodownItem1 = DropdownInput(key: "drodownItem1", header: "Test drop", editable: true, dropdownItems: options)
        
        let drodownItem2 = DropdownInput(key: "drodownItem2", header: "Test drop 2", editable: true, width: .Half, dropdownItems: options)
        let drodownItem3 = DropdownInput(key: "drodownItem3", header: "Test drop 3", editable: true, width: .Half, dropdownItems: options)
        
        let drodownItem4 = DropdownInput(key: "drodownItem4", header: "Test drop 4", editable: true, width: .Third, dropdownItems: options)
        let drodownItem5 = DropdownInput(key: "drodownItem5", header: "Test drop 5", editable: true, width: .Third, dropdownItems: options)
        let drodownItem6 = DropdownInput(key: "drodownItem6", header: "Test drop 6", editable: true, width: .Third, dropdownItems: options)
        let drodownItem7 = DropdownInput(key: "drodownItem7", header: "Test drop 7", editable: true, width: .Half, dropdownItems: options)
        let drodownItem8 = DropdownInput(key: "drodownItem8", header: "Test drop 8", editable: true, width: .Forth, dropdownItems: options)
        
        /// Datepicker
        let dateItem1 = DateInput(key: "dateItem1", header: "Some Date", editable: true, width: .Forth)
        
        /// Text Input
        let textInput1 = TextInput(key: "input1", header: "input 1", editable: true, width: .Half)
        let textInput2 = TextInput(key: "input2", header: "input 2", editable: true, width: .Half)
        
        let textInput3 = TextInput(key: "input3", header: "input 3", editable: true, width: .Third)
        let textInput4 = TextInput(key: "input4", header: "input 4", editable: true, width: .Third)
        let textInput5 = TextInput(key: "input5", header: "input 5", editable: true, width: .Third)
        
        /// Switch
        let switch1 =  SwitchInput(key: "switch1", header: "Switch 1", editable: true, value: true, width: .Forth)
        let switch2 =  SwitchInput(key: "switch2", header: "Switch 2", editable: true, width: .Forth)
        let switch3 =  SwitchInput(key: "switch3", header: "Switch 3", editable: true, width: .Forth)
        let switch4 =  SwitchInput(key: "switch4", header: "Switch 4", editable: true, width: .Forth)
        
        self.inputItems.append(drodownItem1)
        self.inputItems.append(drodownItem2)
        self.inputItems.append(drodownItem3)
        self.inputItems.append(drodownItem4)
        self.inputItems.append(drodownItem5)
        self.inputItems.append(drodownItem6)
        self.inputItems.append(drodownItem7)
        self.inputItems.append(drodownItem8)
        self.inputItems.append(dateItem1)
        
        self.inputItems.append(textInput5)
        self.inputItems.append(textInput4)
        self.inputItems.append(textInput3)
        self.inputItems.append(textInput2)
        self.inputItems.append(textInput1)
        
        self.inputItems.append(switch1)
        self.inputItems.append(switch2)
        self.inputItems.append(switch3)
        self.inputItems.append(switch4)
    }
    
}