//
//  ConversionCalculator.swift
//  Currency Converter
//
//  Created by Chris Gray on 11/23/16.
//  Copyright © 2016 Chris Gray. All rights reserved.
//

import Foundation

class ConversionCalculator
{
    
    let acronyms = ["Euro": "EUR", "US Dollar": "USD", "Japanese Yen": "JPY", "Australian Dollar": "AUD",
                    "British Pound": "GBP", "Canadian Dollar": "CAD", "Swiss Franc": "CHF", "Chinese Yuan": "CNY",
                    "Swedish Krona": "SEK", "Mexican Peso": "MXN", "New Zealand Dollar": "NZD", "Singapore Dollar": "SGD"]
    
    func getExchangeRates(completion: @escaping (_ array: [String: Double]) -> Void) {
        var exchangeRates = [String: Double]()
        
        for firstCurrency in acronyms.values {
            for secondCurrency in acronyms.values {
                let exchangeName = firstCurrency + secondCurrency
                
                var dataArray = [String]()
                
                guard let url = URL(string: "http://download.finance.yahoo.com/d/quotes.csv?s=\(firstCurrency)\(secondCurrency)=X&f=nl1d1t1")
                    else {
                        print("cannot create url")
                        return
                }
                
                var currencyData: NSString = ""
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
                    currencyData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    dataArray = currencyData.components(separatedBy: ",")
                    exchangeRates[exchangeName] = Double(dataArray[1])
                    completion(exchangeRates)
                })
                task.resume()
            }
        }
    }
}
