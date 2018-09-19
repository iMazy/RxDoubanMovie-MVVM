//
//  UIView+IBLayer.swift
//  GSAE
//
//  Created by Mazy on 2018/5/30.
//  Copyright © 2018年 GSAE. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 切圆角
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    
    /// 加边框
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    
    /// 边框颜色
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
}
