//
//  QuantityViewController.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 01.02.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit

class QuantityViewController : UIViewController,  UIPickerViewDelegate,
UIPickerViewDataSource {
    
    // MARK: - Properties
    
    let units = ["Stück","Gramm","Kilogramm","Milliliter", "Liter"]
    let entries = [["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"],
                   ["25","50","75","100","125","150","175","200","250","300","350","400","450","500","600","700","800","900","1000"],
                   ["0.25","0.5","0.75","1","1.25","1.5","1.75","2","3","4","5","6","7","8","9","10"],
                   ["25","50","75","100","125","150","175","200","250","300","350","400","450","500","600","700","800","900","1000"],
                   ["0.25","0.5","0.75","1","1.25","1.5","1.75","2","3","4","5","6","7","8","9","10"]
    ]
    var currentUnit = 0
    
    // MARK: IBOutlets
    
    @IBOutlet weak var quantityPicker: UIPickerView!
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return (component == 0) ? entries[currentUnit].count : units.count
        
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return (component == 0) ? entries[currentUnit][row] : units[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return pickerView.bounds.width * 0.2
        case 1: return pickerView.bounds.width * 0.8
        default: return CGFloat(0)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component==1) {
            currentUnit = row
            pickerView.reloadComponent(0)
        }
    }
    
}
