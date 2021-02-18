//
//  PreisViewController.swift
//  Geck Retail
//
//  Created by Ognjen Milovanovic on 30.10.19.
//  Copyright © 2019 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit

class PreisViewController: UIViewController {

    @IBOutlet weak var reweLabel: UILabel!
    @IBOutlet weak var edekaLabel: UILabel!
    
    
    var reweString: String?
    var edekaString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        reweLabel.text = reweString
        edekaLabel.text = edekaString
        // Do any additional setup after loading the view.
    }
    func customInit(reweStr: String, edekaStr: String){
        self.reweString = reweStr
        self.edekaString = edekaStr
    }



}
