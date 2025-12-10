//
//  DashboardCell.swift
//  ITG
//
//  Created by Rajpal Singh on 04/12/25.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet var btnBgViewArray: [UIView]!
    
    var buttonTapped: (() -> Void)?
    static let identifier = String(describing: ButtonCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        btnBgViewArray.forEach { myView in
            myView.layer.cornerRadius = 10
            myView.layer.borderWidth = 0.5
            myView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    
    @IBAction func didTapmapBtn(_ sender: UIButton) {
        buttonTapped?()
    }
    
}
