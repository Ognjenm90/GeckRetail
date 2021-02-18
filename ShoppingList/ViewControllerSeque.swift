//
//  ViewControllerSeque.swift
//  Geck Retail
//
//  Created by Ognjen Milovanovic on 26.09.19.
//  Copyright © 2019 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class ViewControllerSeque: UIViewController {
    
    var goods:[GoodsViewModel] = []
    
    var wantedGoods : [GoodsViewModel] {
        return goods.filter {
            $0.selected && !$0.inCart
        }
    }
    
    var foundGoods : [GoodsViewModel] {
        return goods.filter {
            $0.selected && $0.inCart
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var colectionItem : GoodsViewModel? = nil
    var detailedTitle :String = ""
    var detailedRewePrice :String = ""
    var detailedEdekaPrice :String = ""
    var detailedImage :UIImage? = nil
    var ID:String = ""
    
    var reweTextField: UITextField?
    var edekaTextField:  UITextField?
    
    let euroFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    override func viewDidLoad() {
        let ref = Database.database().reference().child("geckfood")
        ref.queryOrdered(byChild: "nameD").queryEqual(toValue: detailedTitle).observeSingleEvent(of: .childAdded, with: { (snapshot) in
           //Data die angezeigt werden soll(Bild,Name,Preise usw.) wenn mann unterschiedliche Preise sehen will
            self.titleLabel.lineBreakMode = .byWordWrapping
            self.titleLabel.numberOfLines = 0
            self.titleLabel.text = self.detailedTitle
            self.priceLabel.text = self.detailedRewePrice
            self.imageLabel.image = self.detailedImage
            self.ID = snapshot.key
            super.viewDidLoad()
            
        })
    }
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func setLabelText() {
        GoodsData.sharedInstance.callFirebaseToFetchNewData(){
            
            self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
            for g in self.goods{
                
                if (g.name == self.titleLabel.text!){
                    
                    let RewePrice = self.euroFormatter.string(
                        from: NSNumber(floatLiteral: g.priceRewe))!
                    self.detailedRewePrice = "\(RewePrice) / Stück"
                    
                    let EdekaPrice = self.euroFormatter.string(
                        from: NSNumber(floatLiteral: g.priceEdeka))!
                    self.detailedEdekaPrice = "\(EdekaPrice) / Stück"
                }}
            let index = self.segmentControl.selectedSegmentIndex
            
            switch (index) {
            case 0:
                
                self.priceLabel.text = self.detailedRewePrice
            case 1:
                self.priceLabel.text = self.detailedEdekaPrice
            default:
                self.priceLabel.text = self.detailedRewePrice
                
                
            }
            //  self.priceLabel.text = self.detailedRewePrice
            super.viewDidLoad()
        }
    }
    
    //AlertViewController damit man den Preis ändern kann
    @IBAction func displayAlertAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Preis andern", message: nil,preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.addTextField()
        alertController.textFields![0].placeholder = "Preis Rewe: \(detailedRewePrice)"
        
        
        alertController.textFields![1].placeholder = "Preis Edeka: \(detailedEdekaPrice)"
        
        
        let cancelAction = UIAlertAction(title: "Abrechen", style: .cancel, handler: nil)
        
        let OKAction = UIAlertAction(title: "Ok" , style: .default, handler: {(action) in
            
            if(alertController.textFields![0].text != ""){
                if(alertController.textFields![0].text!.contains(".")){
                    
                    
                    alertController.textFields![0].text =  alertController.textFields![0].text?.replacingOccurrences(of: ".", with: ",")
                    
                    
                }
                
                let rewePrice = NumberFormatter().number(from: alertController.textFields![0].text!)?.doubleValue
                
                if(rewePrice is Double){ Database.database().reference().child("geckfood/\(self.ID)/priceRewe").setValue(rewePrice)
                }
            }
            if(alertController.textFields![1].text != ""){
                if(alertController.textFields![1].text!.contains(".")){
                    
                    
                    alertController.textFields![1].text =  alertController.textFields![0].text?.replacingOccurrences(of: ".", with: ",")
                }
                let edekaPrice = NumberFormatter().number(from: alertController.textFields![1].text!)?.doubleValue
                
                if(edekaPrice is Double){ Database.database().reference().child("geckfood/\(self.ID)/priceEdeka").setValue(edekaPrice)
                }
            }
            self.setLabelText()
            
        })
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController ,animated: true)
        
    }
    
    func okHandler(alert: UIAlertAction)  {
        
        let preisVC = PreisViewController()
        preisVC.customInit(reweStr: (reweTextField?.text)!, edekaStr: (edekaTextField?.text)!)
    }
    
    @IBAction func segmentTapped(_ sender: Any) {
        let index = segmentControl.selectedSegmentIndex
        
        switch (index) {
        case 0:
            
            priceLabel.text = detailedRewePrice
        case 1:
            priceLabel.text = detailedEdekaPrice
        default:
            priceLabel.text = detailedRewePrice
            
            
        }
    }
    
}
