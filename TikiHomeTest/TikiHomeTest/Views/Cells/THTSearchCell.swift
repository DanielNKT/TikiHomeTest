//
//  THTSearchCell.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit

class THTSearchCell: UITableViewCell,  UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var clvItem: UICollectionView!
    @IBOutlet weak var ctnHeightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var vieSeparatorLine: UIView!
    
    var indexSection : NSInteger!
    
    var arrColor : [String] = ["#16702e", "#005a51", "#996c00", "#5c0a6b", "#006d90", "#974e06", "#99272e", "#89221f", "#00345d"]
    var arrItems : [THTItemObject] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUITest()
    }
    
    func setupUITest() {
        self.selectionStyle = .none
        self.vieSeparatorLine.backgroundColor = UIColor.groupTableViewBackground
        self.clvItem.delegate = self
        self.clvItem.dataSource = self
        self.clvItem.register(UINib(nibName: "THTDetailItemCollectionCell", bundle: nil), forCellWithReuseIdentifier: "THTDetailItemCollectionCell")
        if let collectionViewFlowLayout = self.clvItem?.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.estimatedItemSize = CGSize(width: 50, height: 50)
            collectionViewFlowLayout.scrollDirection = .horizontal
            // Use collectionViewFlowLayout
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrItems.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "THTDetailItemCollectionCell", for: indexPath) as! THTDetailItemCollectionCell
        var colorString : String?
        if(indexPath.item >= arrColor.count)
        {
            colorString = arrColor[indexPath.item - arrColor.count]
        }
        else
        {
            colorString = arrColor[indexPath.item]
        }
        cell.configCell(itemObj: arrItems[indexPath.item], colorBackground:colorString!)
        return cell
    }
    
    func configCell(arrayItems : [THTItemObject]){
        if(indexSection == 0){
            self.lblTitle.text = "Từ khoá hot"
            self.lblDescription.text = ""
        }
        else{
            self.lblTitle.text = "Lịch sử tìm kiếm"
            self.lblDescription.text = "Xoá tất cả"
        }
        arrItems = arrayItems
        self.clvItem.reloadData()
        self.contentView.layoutIfNeeded()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    //    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    //        // With autolayout enabled on collection view's cells we need to force a collection view relayout with the shown size (width)
    //        self.clvItem.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: CGFloat(MAXFLOAT));
    //        self.clvItem.layoutIfNeeded();
    //        return self.clvItem.collectionViewLayout.collectionViewContentSize
    //    }
    
    func reuseIdentifier() -> String {
        return NSStringFromClass(THTItemObject.self)
    }
}
