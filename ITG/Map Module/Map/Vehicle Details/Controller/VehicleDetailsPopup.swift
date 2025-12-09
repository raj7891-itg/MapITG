//
//  VehicleDetailsPopup.swift
//  ITG
//
//  Created by Rajpal Singh on 09/12/25.
//

import UIKit

class VehicleDetailsPopup: UIViewController {
    
    @IBOutlet var labeeTitleArray: [UILabel]!
    @IBOutlet weak var bgView: UIView!
    
    
    @IBOutlet weak var borderBgView: UIView!
    
    
    var details: DetailsModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUP()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stylePopupView()
    }
    
   



    private func stylePopupView() {
        
        bgView.layer.cornerRadius = 25
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        
        bgView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1).cgColor
        bgView.layer.shadowOpacity = 0.4
        bgView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgView.layer.masksToBounds = true
        
        borderBgView.layer.cornerRadius = 25
        borderBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        
        borderBgView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1).cgColor
        borderBgView.layer.shadowOpacity = 0.4
        borderBgView.layer.shadowOffset = CGSize(width: 0, height: 3)
        borderBgView.layer.masksToBounds = true
    }

    
    private func initialSetUP() {
        labeeTitleArray[0].text = details?.speed
        labeeTitleArray[1].text = details?.distance
    }
    
    
    @IBAction func didTapDismissBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
