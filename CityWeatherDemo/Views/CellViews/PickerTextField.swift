//
//  PickerTextField.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class PickerTextField: UITextField, UIPickerViewDataSource, UIPickerViewDelegate {

    var dataList: [String]?
    var pickerView: UIPickerView?
    var selectionCallback: ((_ dataListIndex: Int)->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    @objc func didTapDone(sender: UIButton) {
        if (self.text == nil) || (self.text!.isEmpty) {
            self.text = self.dataList?.first
            self.selectionCallback?(0)
        }
        
        resignFirstResponder()
    }
    
    
    func configurePicker(defaultText: String, itemList: [String], complete: ((_ dataListIndex: Int)->Void)?) {
        self.text = defaultText
        self.dataList = itemList
        self.selectionCallback = complete
        
        guard self.pickerView == nil else {
            return
        }
        
        self.pickerView = UIPickerView()
        self.pickerView?.delegate = self
        self.inputView = pickerView
        self.inputAccessoryView = generateAccessoryView()
        self.pickerView?.selectRow(self.getDataListIndexByText(), inComponent: 0, animated: true)
    }

    fileprivate func getDataListIndexByText() -> Int {
        guard self.dataList != nil && self.dataList!.count > 0 && self.text != nil && !self.text!.isEmpty else {
            return 0
        }
        
        for (index, value) in self.dataList!.enumerated() {
            if value.compare(self.text!) == ComparisonResult.orderedSame {
                return index
            }
        }
        
        return 0
    }
    
    fileprivate func generateAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.frame.size.height/6, width: self.frame.size.width, height: 40.0))
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.systemBlue
        toolBar.backgroundColor = UIColor.systemGray
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickerTextField.didTapDone(sender:)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,flexSpace,flexSpace,flexSpace,doneButton], animated: true)
        
        return toolBar
    }

    //Mark: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataList?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataList?[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = self.dataList?[row]
        self.selectionCallback?(row)
    }
}

