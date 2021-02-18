//
//  ShoppingListViewController.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 30.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase


class ShoppingListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate,
UIPickerViewDataSource {
    var myIndex = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sumLabel: UILabel!
    
    @IBOutlet weak var scanButton: UIBarButtonItem!
    var barcodeScanner:BarcodeScannerViewController?
    
    
    let euroFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    let entries = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    
    private var goods:[GoodsViewModel] = []
    
    var filteredGoods : [GoodsViewModel] = [] {
        
        didSet {
            self.tableView.reloadData()
        }
    }
    //Sachen die gebraucht sind direkt von database
    var wantedGoodsEntity:[NSManagedObject] = []
    
    //Sachen die gebraucht sind in GoodsViewModelFormat
    var wantedGoods : [GoodsViewModel]
    {
        return goods.filter {
            $0.selected && !$0.inCart
        }
    }
    
    var foundGoods : [GoodsViewModel] {
        return goods.filter {
            $0.selected && $0.inCart
        }
    }
    
    var cartPrice : String {
        let price = foundGoods.map({$0.totalPrice}).reduce(0.0, +)
        return euroFormatter.string(from: NSNumber(floatLiteral: price))!
    }
    
    var totalPrice : String {
        let price = foundGoods.map({$0.totalPrice}).reduce(0.0, +)
            + wantedGoods.map({$0.totalPrice}).reduce(0.0, +)
        return euroFormatter.string(from: NSNumber(floatLiteral: price))!
    }
    
    var sumString : String {
        return "Summe: \(totalPrice) (davon im Wagen: \(cartPrice))"
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        // goods ist in  callFirebaseToFetchNewData weil die func asynchron ist und wenn es auserhalb der funktion ist ,ist array leer weil die func am Ende immer aufgerufen wird
        
        GoodsData.sharedInstance.callFirebaseToFetchNewData(){
            self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
            super.viewDidLoad()
            
        }
        // set observer for UIApplicationWillEnterForeground
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        
    }
    // my selector that was defined above
    @objc func willEnterForeground() {
        
    }
    func collection(for section: Int) -> [GoodsViewModel] {
        if (filteredGoods.count != goods.count) {
            return filteredGoods
        }
        var collection = wantedGoods
        switch section {
        case 0: break
        case 1: collection = foundGoods
            
        default: break
        }
        return collection
    }
    override func viewWillAppear(_ animated: Bool) {
        //
        GoodsData.sharedInstance.callFirebaseToFetchNewData(){
            
            self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
            self.getData()
            self.update()
            
        }
        //
    }
    
    // MARK: - Custom Functions
    
    func update() {
        //wenn es kein artikel ausgewählt ist soll die Hintergrund für leeres einkaufswagen gezeigt werden
        
        if ((self.wantedGoods.count + self.foundGoods.count) == 0 || wantedGoodsEntity.count == 0) {
            let emptyCartView = EmptyCartView().loadNib() as! EmptyCartView
            self.tableView.backgroundView = emptyCartView
        }
        self.tableView.reloadData()
        sumLabel.text = sumString
    }
    
    //die sachen aus CoreData database werden in ein JSONArray konvertiert
    func convertToJSONArray(moArray: [NSManagedObject]) -> [Any] {
        var jsonArray: [[String: Any]] = []
        
        for item in moArray {
            
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    func getData() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "GoodsEntity")
        
        //hier wird bestimmt ,dass die Artikel die in goods-Array sind selektiert werden und damit im "Offen" angezeigt sind und aber nich im Wagen
        do {
            
            wantedGoodsEntity = try context.fetch(request)
            for data in wantedGoodsEntity {
                for g in goods{
                    if (g.name == data.value(forKey: "name") as! String ){
                        g.selected = true
                    }
                    //die Artikel sind im Wagen
                    if(g.name == data.value(forKey: "name") as! String && data.value(forKey: "inCart") as! Bool == true){
                        g.inCart = true
                    }
                }
                //hier wird filtriert dass die sachen die gelöscht werden wirklich aus CoreData gelöscht werden und nicht später wieder angezeigt werden
                for g in goods{
                    if (g.selected == false  && g.name == data.value(forKey: "name") as! String ){
                        deleteEntity(item: data)
                    }}
                
                
            }
        }
        catch {
            print("Failed")
        }
    }
    func addLeftBarIcon(named:String) {
        
        let logoImage = UIImage.init(named: named)
        let logoImageView = UIImageView.init(image: logoImage)
        logoImageView.frame = CGRect(x:0.0,y:0.0, width:60,height:25.0)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: logoImageView)
        let widthConstraint = logoImageView.widthAnchor.constraint(equalToConstant: 60)
        let heightConstraint = logoImageView.heightAnchor.constraint(equalToConstant: 25)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        navigationItem.leftBarButtonItem =  imageItem
    }
    //entity in wagen stellen
    func entityInCart(item: GoodsViewModel){
        
        for data in wantedGoodsEntity as! [NSManagedObject] {
            
            if (item.name == data.value(forKey: "name") as! String ){
                data.setValue(true, forKey: "inCart")
            }
        }}
    
    func addEntity(item: GoodsViewModel){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "GoodsEntity", in: context)
        let newEntity = NSManagedObject(entity: entity!, insertInto: context)
        
        newEntity.setValue(item.priceRewe, forKey: "priceRewe")
        newEntity.setValue(item.priceEdeka, forKey: "priceEdeka")
        newEntity.setValue(item.name, forKey: "name")
        newEntity.setValue(item.image, forKey: "image")
        newEntity.setValue(item.priority, forKey: "priority")
        newEntity.setValue(item.synonyms, forKey: "synonyms")
        newEntity.setValue(false, forKey: "inCart")
        do {
            try context.save()
            
        } catch {
            
            print("Failed saving")
        }}
    
    func deleteEntity(item: NSManagedObject){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "GoodsEntity")
        //if let result = try? context.fetch(request) {
        if (try? context.fetch(request)) != nil {
            context.delete(item)
            do{
                try context.save()
                
            }
            catch
            {
                print(error)
                
            }}}
    //Die Menge bestimmen
    @objc func changeQuantity(sender: UIButton){
        
        let buttonTag = sender.tag
        let collection = (buttonTag > 0) ? wantedGoods : foundGoods
        let item = collection[abs(buttonTag)-1]
        let title = "Menge ändern"
        let message = "\n\n\n\n\n\n\n\n\n\n";
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let pickerFrame = CGRect(x: 0, y: 52, width: 270, height: 180)
        let picker = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
picker.selectRow(item.quantity-1, inComponent: 0, animated: false)
        
        alertView.view.addSubview(picker)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler:
        {_ in
            
            self.getData()
            if (self.itemCount(itemName: item.name)  <   picker.selectedRow(inComponent: 0) + 1){
                
                while (self.itemCount(itemName: item.name) < picker.selectedRow(inComponent: 0) + 1){
                    item.quantity = item.quantity + 1
                    self.addEntity(item: item)
                    
                    self.getData()
                }
            } else if (self.itemCount(itemName: item.name) >   picker.selectedRow(inComponent: 0) + 1){
                
                
                while (self.itemCount(itemName: item.name) > picker.selectedRow(inComponent: 0) + 1){
                    // roll the dice
                    //  self.deleteEntity(item: item)
                    
                    //  for schleife ist da weil bei deleteEntity Typ des Parameters bei deleteEntity von NSMenagedObject ist und nicht GoodsViewModel
                    for g in self.wantedGoodsEntity{
                        
                        if (item.name == g.value(forKey: "name") as! String ){
                            self.deleteEntity(item: g)
                            item.quantity = item.quantity-1
                            self.getData()
                            break
                        }
                        
                    }
                    
                }
                
            }
            self.update()
        })
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ((wantedGoods.count + foundGoods.count) == 0) {
            
            self.tableView.separatorStyle = .none
            return 0
        }
        self.tableView.backgroundView = nil
        self.tableView.separatorStyle = .singleLine
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Offen"
        case 1: return "Im Wagen"
        default: return ""
        }
    }
    func itemCount(itemName: String) -> Int {
        var count = 0
        for g in wantedGoodsEntity{
            
            // print("g value",g.value(forKey: "name") as! String)
            if(g.value(forKey: "name") != nil){
                if (itemName == g.value(forKey: "name") as! String ){
                    
                    count = count + 1
                    
                }
                
            }
            
        }
        self.getData()
        return count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? wantedGoods.count : foundGoods.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsCell", for: indexPath) as! ShoppingListTableViewCell
        
        // Configure the cell...
        let collection = (indexPath.section == 0) ? wantedGoods : foundGoods
        let item = collection[indexPath.row]
        cell.nameLabel.text = item.name
        let price = euroFormatter.string(
            from: NSNumber(floatLiteral: item.priceRewe))!
        cell.priceLabel.text = "\(price) / Stück"
        cell.goodsImage.image = UIImage(named: item.image)
        cell.quantityButton.setTitle("\( self.itemCount(itemName: item.name)) Stk.",for: .normal)
        //  cell.quantityButton.setTitle("\(item.quantity) Stk.",for: .normal)
        cell.quantityButton.tag = (indexPath.section == 0) ? indexPath.row + 1 : (indexPath.row + 1) * -1
        cell.quantityButton.addTarget(self, action: #selector(changeQuantity(sender:)), for: .touchUpInside)
        
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDetail",
            let nextScene = segue.destination as? ViewControllerSeque,
            let indexPath = self.tableView.indexPathForSelectedRow{
            let collection = (indexPath.section == 0) ? wantedGoods : foundGoods
            let selectRow = collection[indexPath.row]
            
            nextScene.detailedTitle = selectRow.name
            let RewePrice = euroFormatter.string(
                from: NSNumber(floatLiteral: selectRow.priceRewe))!
            let EdekaPrice = euroFormatter.string(
                from: NSNumber(floatLiteral: selectRow.priceEdeka))!
            
            nextScene.goods = self.goods
            nextScene.colectionItem = collection[indexPath.row]
            nextScene.detailedRewePrice = "\(RewePrice) / Stück"
            nextScene.detailedEdekaPrice = "\(EdekaPrice) / Stück"
            nextScene.detailedImage = UIImage(named:selectRow.image)!
        }
     }
    //Artikel im Wagen
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let toggleAction = self.contextualToggleCartAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [toggleAction])
        return swipeConfig
    }
    //Löschen das Artikel
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfig.performsFirstActionWithFullSwipe = false
        return swipeConfig
    }
    
    // MARK: - Contextual Actions
    //Artikel im wagen stellen
    func contextualToggleCartAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var collection = (indexPath.section == 0) ? wantedGoods : foundGoods
        let good = collection[indexPath.row]
        
        let action = UIContextualAction(style: .normal,
                                        title: "Im Wagen")
        { action, view, completionHandler in
            
            good.inCart = true
            
            for item in self.wantedGoodsEntity{
                
                if (good.name == item.value(forKey: "name") as! String ){
                    
                    self.entityInCart(item: good)
                }
                
            }
            self.update()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.purple
        
        return action
    }
    
    //Artikel aus Shoppinglist löschen
    // MARK: - IBActions
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var collection = (indexPath.section == 0) ? wantedGoods : foundGoods
        let good = collection[indexPath.row]
        
        
        let action = UIContextualAction(style: .normal,title: "Delete")
            
        { action, view, completionHandler in
            
            good.selected = false
            
            for item in self.wantedGoodsEntity{
                
                if (good.name == item.value(forKey: "name") as! String ){
                    
                    self.deleteEntity(item: item)
                    
                }
                
            }
            self.wantedGoodsEntity.remove(at: indexPath.row)
            
            self.update()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        
        return action
    }
    //ganze Liste nach dem Einkauf löschen
    @IBAction func deleteList(_ sender: UIBarButtonItem) {
        
        for good in wantedGoodsEntity{
            deleteEntity(item: good)
        }
        
        self.getData()
        self.viewWillAppear(true)
        self.update()
        
    }
    // MARK: - Navigation
    
    @IBAction func unwindToShoppingList(sender: UIStoryboardSegue) {
        
        
        if sender.source is GoodsViewController {
            self.update()            
        }
        if sender.source is QuantityViewController {
            // TODO
            self.update()
        }
            self.getData()
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return entries.count
        
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return entries[row]
    }
}
