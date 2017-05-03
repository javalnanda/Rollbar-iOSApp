//
//  RCProjectsTableViewController.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/21/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit
import KeychainAccess
import Alamofire
import AlamofireObjectMapper
import PMAlertController
import MBProgressHUD

class RCProjectsTableViewController: UITableViewController {

    var projects: [Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Projects"
        let keychain = Keychain(service: KeychainVar.service)
        let token = keychain[KeychainVar.accesstoken]

        if token == nil {
            presentLoginController()
        } else {
            getProjects(accessToken: token!)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func presentLoginController() {
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
    }

    @IBAction func logoutClicked(_ sender: Any) {

        let alertVC = PMAlertController(title: "Logout", description: "Do you wish to logout?", image: nil, style: .alert)
        alertVC.addAction(PMAlertAction(title: "No", style: .cancel, action: { () -> Void in

        }))
        alertVC.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            let keychain = Keychain(service: KeychainVar.service)
            keychain[KeychainVar.accesstoken] = nil
            self.presentLoginController()
        }))
        self.present(alertVC, animated: true, completion: nil)
    }

    func getProjects(accessToken: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.bezelView.color = UIColor.black
        hud.contentColor = UIColor.white

        Alamofire.request(apiBaseUrl+"projects?access_token=\(accessToken )").validate().responseArray(keyPath: "result") { (response: DataResponse<[Project]>) in

            MBProgressHUD.hide(for: self.view, animated: true)
            switch response.result {
            case .success:

                let tempArray = response.result.value ?? []
                if tempArray.count > 0 {
                    // to filter out projects with no name and status
                    for project in tempArray where (project.status) != nil {
                            self.projects.append(project)
                    }
                }

                self.tableView.reloadData()

            case .failure(let error):
                let alertVC = PMAlertController(title: "Invalid", description: error.localizedDescription, image:nil, style: .alert)

                alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in

                }))

                self.present(alertVC, animated: true, completion: nil)

                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCellIdentifier", for: indexPath)

        cell.textLabel?.text = projects[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let projectItemsVC = rcStoryBoard.instantiateViewController(withIdentifier: "RCProjectItemsViewController") as? RCProjectItemsViewController
        projectItemsVC?.selectedProject = projects[indexPath.row]

        self.navigationController?.pushViewController(projectItemsVC!, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RCProjectsTableViewController: LoginViewControllerDelegate {
    func didLogin(sender: [Project]) {
        let tempArray = sender
        if tempArray.count > 0 {
            // to filter out projects with no name and status
            for project in tempArray where (project.status) != nil {
                self.projects.append(project)
            }
        }
        self.tableView.reloadData()
    }
}
