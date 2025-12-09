//
//  DashboardCell.swift
//  ITG
//
//  Created by Rajpal Singh on 04/12/25.
//

import UIKit

class DashboardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var totalVehicleLbl: UILabel!
    @IBOutlet weak var vehicleNumLbl: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    
    static let identifier = String(describing: DashboardCell.self)

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        backGroundView.layer.cornerRadius = 10
        backGroundView.layer.borderWidth = 0.5
        backGroundView.layer.borderColor = UIColor.gray.cgColor
        
    }

}
