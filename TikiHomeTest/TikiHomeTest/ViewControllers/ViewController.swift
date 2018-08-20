//
//  ViewController.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, THTSearchCellDelegate {
    
    var arrKeySearch : [THTItemObject] = []
    var arrHotKeyFromServerSearch : [THTItemObject] = []
    var recentSearchText : String = ""
    
    @IBOutlet weak var tbvContent: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var ctnBottomContainer: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
        self.getJsonFromServer()
    }
    func setupUI(){
        self.searchBar.delegate = self
        self.tbvContent.delegate = self
        self.tbvContent.dataSource = self
        self.tbvContent.register(UINib(nibName: "THTSearchCell", bundle: nil), forCellReuseIdentifier: "THTSearchCell");
        self.tbvContent.estimatedRowHeight =  100
        self.tbvContent.separatorStyle = .none
        self.getAllTHItemFromCoreData()
    }
    func getJsonFromServer()
    {
        let urlString = "https://tiki-mobile.s3-ap-southeast-1.amazonaws.com/ios/keywords.json"
        guard let url = URL(string: urlString) else { return }
        
        weak var weakSelf = self
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                weakSelf?.showAlertMessage(message: error!.localizedDescription)
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            do {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                
                if let result = jsonResult as? [String : Any], let arrItems = result["keywords"] as? [AnyObject] {
                    for itemDic in arrItems {
                        let itemObj = THTItemObject(itemDic: itemDic as! Dictionary<String, Any>)
                        self.arrHotKeyFromServerSearch.append(itemObj)
                    }
                    DispatchQueue.main.async {
                        weakSelf?.tbvContent.reloadData()
                    }
                }
            }
            catch let jsonErr {
                weakSelf?.showAlertMessage(message: jsonErr.localizedDescription)
            }
            
            }.resume()
    }
    
    //MARK: -- Setup TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "THTSearchCell", for: indexPath) as! THTSearchCell
        cell.indexSection = indexPath.section
        if(indexPath.section == 1)
        {
            cell.configCell(arrayItems: arrKeySearch)
            
        }
        else
        {
            cell.configCell(arrayItems: arrHotKeyFromServerSearch)
        }
        cell.delegate = self
        cell.frame = tableView.bounds;
        cell.layoutIfNeeded();

        cell.ctnHeightCollectionView.constant = cell.clvItem.collectionViewLayout.collectionViewContentSize.height;
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    //MARK: -- SearchBar SearchButtonClicked
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if(recentSearchText != "")
        {
            searchBar.text = recentSearchText
        }
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        recentSearchText = searchText!
        searchBar.placeholder = recentSearchText
        searchBar.text = ""
        let trimmedSearchText = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentDateTime = Date().timeIntervalSince1970
        
        if(!(trimmedSearchText?.isEmpty)!)
        {
            let itemObj = THTItemObject.init(keywordItemValue: trimmedSearchText!, iconItemValue: "", timeSearchValue: NSInteger(currentDateTime));
            self.remove(keyword: trimmedSearchText!)
            self.save(itemObject: itemObj)
        }
        else
        {
           self.showAlertMessage(message: "Please enter valid keyword")
        }
    }
    func tapItemCell(itemObj: THTItemObject)
    {
        self.searchBar.text = itemObj.keywordItem
        recentSearchText = itemObj.keywordItem
        self.searchBar.becomeFirstResponder()
    }
    func tapDeleteAllItem(){
        self.deleteAllSearchKeyHistory()
        self.tbvContent.reloadSections(IndexSet(integersIn: 1...1), with: .none)
    }
    
    //MARK: -- Query CoreDate
    func getAllTHItemFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "THTItem")
        
        let sort = NSSortDescriptor(key: "timeCreated", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do {
            let results = try managedContext.fetch(fetchRequest)
            let items = results as! [THTItem]
            
            for item in items {
                let itemObject = THTItemObject.init(keywordItemValue: item.keyword!, iconItemValue: item.icon!, timeSearchValue: NSInteger(item.timeCreated)) as THTItemObject
                arrKeySearch.append(itemObject)
            }
        } catch let error as NSError {
            self.showAlertMessage(message: "Could not save \(error), \(error.userInfo)")
            //print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    //Remove keyword if already exist
    func remove(keyword: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        
        //1. ManagedContext
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "THTItem")
        
//        fetchRequest.predicate = NSPredicate.init(format: "keyword==\(keyword)")
        fetchRequest.predicate = NSPredicate(format: "%K LIKE[c] %@", "keyword", keyword)
        do {
            let objects = try managedContext.fetch(fetchRequest)
            for object in objects {
                managedContext.delete(object as! NSManagedObject)
            }
            try managedContext.save()
            var index = 0
            for itemObject in arrKeySearch {
                if itemObject.keywordItem == keyword
                {
                    arrKeySearch.remove(at: index)
                    print("remove success \(keyword)")
                }
                index += 1
            }
        } catch let error as NSError  {
            self.showAlertMessage(message: "Could not save \(error), \(error.userInfo)")
        }
    
    }
    
    func save(itemObject: THTItemObject){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{ return }
        
        //1. ManagedContext
        let managedContext = appDelegate.persistentContainer.viewContext
        //2. Entity
        let entity = NSEntityDescription.entity(forEntityName: "THTItem", in: managedContext)
        //3. Managed object
        let itemObj = NSManagedObject(entity: entity!, insertInto: managedContext)
        //
        itemObj.setValue(itemObject.keywordItem, forKey: "keyword")
        itemObj.setValue(itemObject.iconItem, forKey: "icon")
        itemObj.setValue(itemObject.timeSearch , forKey: "timeCreated")
    
        //
        do {
            try managedContext.save()
            arrKeySearch.insert(itemObject, at: 0)
            //self.showAlertMessage(message: "Saved success keyword: \(itemObject.keywordItem) to history")
            weak var weakSelf = self
            DispatchQueue.main.async {
                weakSelf?.tbvContent.reloadData()
            }
        } catch let error as NSError{
            self.showAlertMessage(message: "could not save! \(error), \(error.userInfo)")
        }
        
    }
    func deleteAllSearchKeyHistory(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "THTItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            self.showAlertMessage(message: "Deleted all search key success")
            self.arrKeySearch.removeAll()
        } catch {
            print ("There was an error")
        }
    }
    //show message when save success
    func showAlertMessage(message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.ctnBottomContainer.constant = keyboardSize.height
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.ctnBottomContainer.constant = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

