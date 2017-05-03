//
//  RCLoginViewController.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/21/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit
import Alamofire
import PMAlertController
import SwiftyJSON
import AlamofireObjectMapper
import KeychainAccess
import MBProgressHUD

protocol LoginViewControllerDelegate:class {
    func didLogin(sender: [Project])
}

class RCLoginViewController: UIViewController {

    @IBOutlet weak var accessToken: UITextField!
    weak var delegate: LoginViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginClicked(_ sender: Any) {

        guard let text = accessToken.text, !text.isEmpty else {
            let alertVC = PMAlertController(title: "Missing Info", description: "Please enter access token", image:nil, style: .alert)
            alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in
            }))
            self.present(alertVC, animated: true, completion: nil)

            return
        }

        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.bezelView.color = UIColor.black
        hud.contentColor = UIColor.white

        Alamofire.request(apiBaseUrl+"projects?access_token=\(accessToken.text ?? "")").validate().responseArray(keyPath: "result") { (response: DataResponse<[Project]>) in

            MBProgressHUD.hide(for: self.view, animated: true)
            switch response.result {
            case .success:

                let keychain = Keychain(service: KeychainVar.service)
                keychain[KeychainVar.accesstoken] = self.accessToken.text!
//                let projects = response.result.value
                self.performSegue(withIdentifier: "projectsViewSegue", sender: nil)

            case .failure(let error):
                let alertVC = PMAlertController(title: "Invalid", description: "Invalid access token", image:nil, style: .alert)

                alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in

                }))

                self.present(alertVC, animated: true, completion: nil)

                print(error)
            }
        }
    }
}
