//
//  THTSearchCell.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit

protocol THTSearchCellDelegate: class {
    func tapDeleteAllItem()
    func tapItemCell(itemObj: THTItemObject)
}

class THTSearchCell: UITableViewCell,  UICollectionViewDelegate, UICollectionViewDataSource, THTDetailItemCollectionCellDelegate {
    
    weak var delegate: THTSearchCellDelegate?
    
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
        self.setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lblTitle.text = ""
        self.lblDescription.text = ""
    }
    func setupUI() {
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
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapResponse))
        tapGesture.numberOfTapsRequired = 1
        self.lblDescription.isUserInteractionEnabled =  true
        self.lblDescription.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapResponse(recognizer: UITapGestureRecognizer) {
        guard let method = self.delegate?.tapDeleteAllItem() else {
            // optional not implemented
            return
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
        cell.delegate = self
        cell.configCell(itemObj: arrItems[indexPath.item], colorBackground:colorString!)
        return cell
    }
    func tapItem(itemObj: THTItemObject) {
        guard let method = self.delegate?.tapItemCell(itemObj: itemObj) else {
            // optional not implemented
            return
        }
    }
    func configCell(arrayItems : [THTItemObject]){
        if(indexSection == 0){
            self.lblTitle.text = "Từ khoá hot"
            self.lblDescription.text = ""
        }
        else{
            if(arrayItems.count > 0)
            {
                self.lblDescription.isHidden = false
                self.ctnHeightCollectionView.constant = 60;
                self.lblTitle.text = "Lịch sử tìm kiếm"
                //self.lblDescription.text = "Xoá tất cả"
                
                let strokeTextAttributes = [
                    NSAttributedStringKey.foregroundColor : UIColor.blue,
                    NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)
                    ] as [NSAttributedStringKey : Any]
                
                self.lblDescription.attributedText = NSAttributedString(string: "Xoá tất cả", attributes: strokeTextAttributes)
            }
            else
            {
                self.lblTitle.text = ""
                self.lblDescription.text = ""
                self.lblDescription.isHidden = true
                self.vieSeparatorLine.backgroundColor = UIColor.white
            }
        }
        arrItems = arrayItems
        self.clvItem.reloadData()
        self.contentView.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }

}
