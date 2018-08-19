//
//  THTDetailItemCollectionCell.swift
//  TikiHomeTest
//
//  Created by Nguyen Toan on 8/18/18.
//  Copyright © 2018 Nguyen Toan. All rights reserved.
//

import UIKit
import SDWebImage

class THTDetailItemCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblKeyword: THTCustomLable!
    @IBOutlet weak var ctnHeightLabel: NSLayoutConstraint!
    @IBOutlet weak var ctnHeightCell: NSLayoutConstraint!
    @IBOutlet weak var vieContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //self.imgIcon.image = nil;
    }
    func setupUI(){
        self.backgroundColor = UIColor.yellow
        self.imgIcon.backgroundColor = UIColor.groupTableViewBackground
    }
    func configCell(itemObj: THTItemObject, colorBackground:String) {
        self.imgIcon.sd_setImage(with: URL(string: itemObj.iconItem!), completed: nil)
        self.lblKeyword.text = itemObj.keywordItem
        self.lblKeyword.backgroundColor = self.hexStringToUIColor(hex: colorBackground)
        self.lblKeyword.sizeToFit()
        self.contentView.setNeedsLayout()
        self.contentView.updateConstraints()
        self.contentView.layoutIfNeeded()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func reuseIdentifier() -> String {
        return NSStringFromClass(THTItemObject.self)
    }
}
