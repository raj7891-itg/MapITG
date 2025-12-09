//
//  LoginVC.swift
//  ITG
//
//  Created by Rajpal Singh on 05/12/25.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var logoBgViewTop: UIView!
    @IBOutlet weak var logoBgViewSecondry: UIView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginWithOtpBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         initialSetup()
    }
    
    
    private func initialSetup() {
        setupUI()
    }
    
    private func setupUI() {
        logoBgViewTop.backgroundColor = UIColor(named: "Back_Theme")?.withAlphaComponent(0.5)
        logoBgViewTop.layer.cornerRadius = 10
        logoBgViewSecondry.layer.cornerRadius = 10
        loginBtn.layer.cornerRadius = 10
        loginWithOtpBtn.layer.cornerRadius = 10
        emailField.layer.cornerRadius = 10
        emailField.clipsToBounds = true
        passwordField.layer.cornerRadius = 10
        passwordField.clipsToBounds = true
        emailField.layer.borderWidth = 0.6
        passwordField.layer.borderWidth = 0.6
    }
    
//all btn action
    
    @IBAction func didTapLoginBtn(_ sender: UIButton) {
        openViewController()
        
    }
    

    @IBAction func didTapLoginWithOtp(_ sender: UIButton) {
        
    }
    
}


//MARK: - Open another controller function
extension LoginVC {
        private func openViewController() {
            let storyboard = UIStoryboard(name: "MapViewVC", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserDashboardVC") as! UserDashboardVC
            self.navigationController?.pushViewController(vc, animated: true)
        }

}
