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

extension UIViewController {
    func showGeofenceAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
