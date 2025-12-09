//
//  VehicleDetailsPopup.swift
//  ITG
//
//  Created by Rajpal Singh on 09/12/25.
//

import UIKit

class VehicleDetailsPopup: UIViewController {
    
    @IBOutlet var labeeTitleArray: [UILabel]!
    
    var details: DetailsModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUP()
    }
    
    private func initialSetUP() {
        labeeTitleArray[0].text = details?.speed
        labeeTitleArray[1].text = details?.distance
    }
    
    
    @IBAction func didTapDismissBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
