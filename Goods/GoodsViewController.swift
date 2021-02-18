//
//  GoodsViewController.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase

class GoodsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CollapsibleTableViewHeaderDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var goods:[GoodsViewModel] = []
    
    
    var filteredGoods : [GoodsViewModel] = [] {
        
        didSet {
            self.tableView.reloadData()            
        }
    }
    
    var sectionA: [GoodsViewModel] {
        return goods.filter {
            $0.name.lowercased().hasPrefix("a")
        }
    }
    
    var sectionB: [GoodsViewModel] {
        return goods.filter {
            $0.name.lowercased().hasPrefix("b")
        }
    }
    
    var sectionC: [GoodsViewModel] {
        return goods.filter {
            $0.name.lowercased().hasPrefix("c")
        }
    }
    
    var sectionD: [GoodsViewModel] {
        return goods.filter {
            ((!$0.name.lowercased().hasPrefix("a")) &&
                (!$0.name.lowercased().hasPrefix("b")) &&
                (!$0.name.lowercased().hasPrefix("c")))
        }
    }
    
    var collapsedSections = [true,true,true,true]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isToolbarHidden = false
        
        // set observer for UIApplicationWillEnterForeground
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    
    @objc func willEnterForeground() {
        self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
        self.filteredGoods = goods
        self.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.goods = GoodsDataSingleton.sharedInstance.sharedGoods
        self.filteredGoods = goods
        self.update()
    }
    
    // MARK: - Functions
    
    func collection(for section: Int) -> [GoodsViewModel] {
        if (filteredGoods.count != goods.count) {
            return filteredGoods
        }
        var collection = sectionA
        switch section {
        case 0: break
        case 1: collection = sectionB
        case 2: collection = sectionC
        case 3: collection = sectionD
        default: break
        }
        return collection
    }
    
    func update() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (filteredGoods.count != goods.count) ? 1 : 4
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if (filteredGoods.count != goods.count) {
            return nil
        }
        switch section {
        case 0: return "A (Beispielgruppe)"
        case 1: return "B (Beispielgruppe)"
        case 2: return "C (Beispielgruppe)"
        case 3: return "D-Z (Beispielgruppe)"
        default: return "Sonstiges"
        }
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (filteredGoods.count != goods.count) {
            return filteredGoods.count
        }
        if collapsedSections[section] {
            return 0
        }
        return collection(for: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoodsCell", for: indexPath)
        
        // Configure the cell...
        var collection = self.collection(for: indexPath.section)
        cell.textLabel?.text = collection[indexPath.row].name
        if (collection[indexPath.row].selected) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (filteredGoods.count != goods.count) {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? GoodsCollapsibleTableViewHeader ?? GoodsCollapsibleTableViewHeader(reuseIdentifier: "header")
        header.section = section
        header.arrowLabel.text = ">"
        header.delegate = self
        return header
    }
    
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        var collection = self.collection(for: indexPath.section)
        let item = collection[row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if (cell?.accessoryType == .checkmark) {
            cell?.accessoryType = .none
            deleteEntity(item: item)
            item.selected = false
            item.inCart = true
        } else {
            cell?.accessoryType = .checkmark
            saveEntity(item: item)
            item.selected = true
            item.inCart = false
        }
    }
    //Artikel aus Coredata entfernen (in nächste 2 functionen)
    func deleteEntity(item: NSManagedObject){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "GoodsEntity")
        
        if let result = try? context.fetch(request) {
            context.delete(item)
            do{
                try context.save()
                
            }
            catch
            {
                print(error)
            }}}
    func deleteEntity(item: GoodsViewModel){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "GoodsEntity")
        
        if let result = try? context.fetch(request) {
            do {
                let wantedGoodsEntity = try context.fetch(request)
                
                for g in wantedGoodsEntity{
                    if (item.name == g.value(forKey: "name") as! String ){
                        context.delete(g)
                        try context.save()
                        item.selected = false
                        item.inCart = true
                        
                    }
                }
            } catch {
                print("Failed")
            }}}
   
    func saveEntity(item: GoodsViewModel){
        
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
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredGoods = goods
        } else {
            filteredGoods = goods
                .filter({$0.similarity(term: searchText)>0})
                .sorted(by: {$0.similarity(term: searchText) > $1.similarity(term: searchText)})
            
        }
    }
    
    // MARK: - CollapsibleTableViewHeaderDelegate
    
    func toggleSection(_ section: Int) {
        let collapsed = !collapsedSections[section]
        collapsedSections[section] = collapsed        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    
}
