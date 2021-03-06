//
//  THTItemObject.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit

class THTItemObject: NSObject {
    var keywordItem: String
    var iconItem: String?
    var timeSearch: NSInteger
    
    init(itemDic : [String:Any] ){
        keywordItem = itemDic["keyword"] as? String ?? ""
        iconItem = itemDic["icon"] as? String ?? ""
        timeSearch = 0
    }
    
    init(keywordItemValue: String, iconItemValue: String, timeSearchValue: NSInteger) {
        keywordItem = keywordItemValue
        iconItem = iconItemValue
        timeSearch = timeSearchValue
    }
}
