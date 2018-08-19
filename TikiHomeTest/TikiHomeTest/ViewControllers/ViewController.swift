//
//  ViewController.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, THTSearchCellDelegate {
    
    var itemStore: THTItemStore!
    var arrKeySearch : [THTItemObject] = []
    var arrHotKeyFromServerSearch : [THTItemObject] = []
    var recentSearchText : String = ""
    
    @IBOutlet weak var tbvContent: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
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
    }
    func getJsonFromServer()
    {
        let urlString = "https://tiki-mobile.s3-ap-southeast-1.amazonaws.com/ios/keywords.json"
        guard let url = URL(string: urlString) else { return }
        
        weak var weakSelf = self
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            
            //For test json respone
            //let dataAsString = String(data: data, encoding: .utf8)
            //print(dataAsString ?? "Ko co data")
            
            do {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                //print(jsonResult)
                
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
                print(jsonErr.localizedDescription)
            }
            
            }.resume()
    }
    
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
    
    //MARK -- SearchBar SearchButtonClicked
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
            
            itemStore = THTItemStore()
            itemStore.createItem(itemObject: itemObj)
            arrKeySearch = itemStore.allItems
            
            //error when save
//            let insertItemOk = itemStore.saveChanges() as Bool
//            if(insertItemOk){
//                print("insert item ok")
//            }
        }
    }
    func removeAllItemSuccess() {
        //reload section second when remove success
        self.tbvContent.reloadSections(IndexSet(integersIn: 1...1), with: .none)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

