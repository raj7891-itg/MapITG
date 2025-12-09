//
//  UserDashboardVC.swift
//  ITG
//
//  Created by Rajpal Singh on 04/12/25.
//

import UIKit

class UserDashboardVC: UIViewController {
    

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUP()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    
    
  var dashBoardData: [VehicleDetailModel] = [
    VehicleDetailModel(totalVehicle: 4000, vehicleStatus: "Total", backColor: UIColor(named: "app_blue") ?? .appBlue.withAlphaComponent(0.2)),
    VehicleDetailModel(totalVehicle: 500, vehicleStatus: "Running", backColor: UIColor(named: "app_green") ?? .appGreen.withAlphaComponent(0.2)),
    VehicleDetailModel(totalVehicle: 100, vehicleStatus: "Idle", backColor: UIColor(named: "app_yellow") ?? .appYellow.withAlphaComponent(0.2)),
    VehicleDetailModel(totalVehicle: 500, vehicleStatus: "Repair Need", backColor: UIColor(named: "app_pink") ?? .appPink.withAlphaComponent(0.2))
  ]
    
   private func initialSetUP() {
    collectionView.dataSource = self
    collectionView.delegate = self
    initailUISetUp()
    collectionView.registerXIB(name: DashboardCell.identifier)
    collectionView.registerXIB(name: ButtonCell.identifier)
       
    }
    
    private func initailUISetUp() {
        imgBgView.layer.cornerRadius = imgView.frame.height/2
        imgBgView.clipsToBounds = true
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.clipsToBounds = true
        imgView.layer.masksToBounds = true
        imgBgView.layer.borderColor = UIColor.white.cgColor
        
        
    }
    
    
    
    //all Btn action
    
    @IBAction func didTapMapBtn(_ sender: UIButton) {
       // navigateToMap()
    }
    
    
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
}

//MARK: - collectionView Data Source & Delegate method
extension UserDashboardVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else if section == 1 {
            return 1
        }
        return 0
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:DashboardCell.identifier, for: indexPath) as? DashboardCell else {return UICollectionViewCell()}
            cell.totalVehicleLbl.text = "\(dashBoardData[indexPath.row].totalVehicle)"
            cell.vehicleNumLbl.text = "\(dashBoardData[indexPath.row].vehicleStatus)"
            cell.backGroundView.backgroundColor = dashBoardData[indexPath.row].backColor
            return cell
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:ButtonCell.identifier, for: indexPath) as? ButtonCell else {return UICollectionViewCell()}
            cell.btnBgViewArray.forEach { myView in
                myView.backgroundColor = dashBoardData[indexPath.row].backColor
            }
            
            // map button tap action
            cell.buttonTapped =  {[weak self] in
                guard let weakSelf = self else {return}
                weakSelf.navigateToMap()
                
            }
            return cell
        }
        return UICollectionViewCell()
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            lay.minimumInteritemSpacing = 0.5
            lay.minimumLineSpacing = 0.5
            let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing
            let heightPerItem = 100.0
            return CGSize(width:widthPerItem, height: heightPerItem)
        } else if indexPath.section == 1 {
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            lay.minimumInteritemSpacing = 0.5
            lay.minimumLineSpacing = 0.5
            let widthPerItem = collectionView.frame.width  - lay.minimumInteritemSpacing
            let heightPerItem = 150.0
            return CGSize(width:widthPerItem, height: heightPerItem)
        }
        return CGSize(width: 100, height: 100)
    }
    
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {//for apply
        cell.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            cell.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

//Mark: - Extension to move to another controller
extension UserDashboardVC {
    private func navigateToMap() {
        let vc = MapViewVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
