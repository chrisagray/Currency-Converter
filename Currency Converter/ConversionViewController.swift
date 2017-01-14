//
//  ViewController.swift
//  Currency Converter
//
//  Created by Chris Gray on 11/20/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    @IBOutlet weak var userDisplay: UILabel!
    @IBOutlet weak var conversionDisplay: UILabel!
    
    @IBOutlet weak var firstPickerView: UIPickerView!
    @IBOutlet weak var secondPickerView: UIPickerView!
    
    
    private var conversion = ConversionCalculator()
    
    private var pickerData: [String] {
        get {
            return conversion.acronyms.keys.sorted()
        }
    }
    
    private var exchangeRates = [String: Double]()
    
    override func viewDidLoad() {
        self.firstPickerView.delegate = self
        self.firstPickerView.dataSource = self
        self.secondPickerView.delegate = self
        self.secondPickerView.dataSource = self
        
        conversion.getExchangeRates(completion:) { exchangeArray in
            DispatchQueue.main.async {
                self.exchangeRates = exchangeArray
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        convertCurrencies()
    }
    
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var pickerLabel = view as? UILabel
            if pickerLabel == nil {
                pickerLabel = UILabel()
            }
            pickerLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
            pickerLabel?.textAlignment = NSTextAlignment.center
            pickerLabel?.adjustsFontSizeToFitWidth = true
            pickerLabel?.minimumScaleFactor = 0.5
            pickerLabel?.text = pickerData[row]
            return pickerLabel!
        }
    
    
    var userIsInTheMiddleOfTyping = false
    

    private var userDisplayValue: Double {
        get {
            return Double(userDisplay.text!)!
        }
        set {
            if newValue == 0 {
                userDisplay.text = "0"
                conversionDisplay.text = "0"
            }
            let newIntValue = Int(newValue)
            if newValue == Double(newIntValue) {
                userDisplay.text = String(newIntValue)
            } else {
                userDisplay.text = String(newValue)
            }
        }
    }
    
    private var convertedDisplayValue: Double {
        get {
            return Double(conversionDisplay.text!)!
        }
        set {
            let newIntValue = Int(newValue)
            if newValue == Double(newIntValue) {
                conversionDisplay.text = String(newIntValue)
            } else {
                conversionDisplay.text = String(newValue)
            }
        }
    }
    
    private func getExchangeRate(firstCurrency: String, secondCurrency: String) -> Double? {
        if firstCurrency == secondCurrency {
            return 1.0
        }
        let firstAcronym = conversion.acronyms[firstCurrency]!
        let secondAcronym = conversion.acronyms[secondCurrency]!
        
        let currency = firstAcronym + secondAcronym
        let exchangeRate = exchangeRates[currency]
        
        return exchangeRate
    }
    
    private func convertCurrencies() {
        if userDisplayValue == 0 {
            convertedDisplayValue = 0
        }
        let userCurrency = pickerView(firstPickerView, titleForRow: firstPickerView.selectedRow(inComponent: 0), forComponent: 0)!
        let conversionCurrency = pickerView(secondPickerView, titleForRow: secondPickerView.selectedRow(inComponent: 0), forComponent: 0)!
        
        if let exchangeRate = getExchangeRate(firstCurrency: userCurrency, secondCurrency: conversionCurrency) {
            let convertedNumber = userDisplayValue * exchangeRate
            convertedDisplayValue = convertedNumber
        }
        else {
            print("cannot get exchange rate")
        }
    }
    
    @IBAction func undo(_ sender: UIButton) {
        
        if (userDisplay.text?.characters.count)! > 1 {
            userDisplay.text!.remove(at: userDisplay.text!.index(before: userDisplay.text!.endIndex))
            convertCurrencies()
        }
        else {
            userDisplayValue = 0
            userIsInTheMiddleOfTyping = false
        }

    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        userDisplayValue = 0
        userIsInTheMiddleOfTyping = false
    }
    
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if !(digit == "." && userDisplay.text?.range(of: ".") != nil) {
                userDisplay.text! += digit
            }
        } else {
            userDisplay.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
        convertCurrencies()
    }
    
    @IBAction func switchCurrencies(_ sender: UIButton) {
        let leftRow = firstPickerView.selectedRow(inComponent: 0)
        let rightRow = secondPickerView.selectedRow(inComponent: 0)
        
        
        firstPickerView.selectRow(rightRow, inComponent: 0, animated: true)
        secondPickerView.selectRow(leftRow, inComponent: 0, animated: true)
        
        convertCurrencies()
    }
    
    
    
    
    
    
    
    
    
    
}
