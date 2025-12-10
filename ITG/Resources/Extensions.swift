//
//  Extensions.swift
//  ITG
//
//  Created by Rajpal Singh on 04/12/25.
//



import Foundation
import UIKit

extension UICollectionView {
    
    func registerXIB(name:String) {
        self.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func emptyInfo(msg:String){
        
    }
}

extension UITableView {
    
    func registerXIB(name:String){
        self.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    func emptyInfo(msg:String){
       
    }
}

extension CALayer {
  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0)
  {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}

extension UIViewController {
    func showGeofenceAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
