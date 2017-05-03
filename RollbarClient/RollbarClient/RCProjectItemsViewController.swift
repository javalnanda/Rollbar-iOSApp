//
//  RCProjectItemsViewController.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/24/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit
import MBProgressHUD
import AlamofireObjectMapper
import Alamofire
import PMAlertController
import KeychainAccess
import SwiftyJSON
import JNDropDownMenu

class RCProjectItemsViewController: UIViewController {

    var selectedProject = Project()
    var tokens: [ProjectToken] = []
    var items: [RollbarItem] = []

    var currentPage = 1
    var totalItemCount = 1

    var token = ""
    var projectReadToken = ""
    var projectWriteToken = ""

    var severityArray = ["All", "Critical", "Error", "Warning", "Info", "Debug"]
    var statusArray = ["All", "Active", "Resolved", "Muted"]

    var selectedSeverity = "All"
    var selectedStatus = "All"
    var queryParam = ""

    var currentItemId = 0

    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedProject.name!
        let keychain = Keychain(service: KeychainVar.service)
        self.token = keychain[KeychainVar.accesstoken]!
        getProjectAccessTokens(accessToken: token)

        self.itemsTableView.rowHeight = UITableViewAutomaticDimension
        self.itemsTableView.estimatedRowHeight = 100
        let menu = JNDropDownMenu(origin: CGPoint(x: 0, y: 64), height: 40, width: self.view.frame.size.width)
        menu.datasource = self
        menu.delegate = self
        self.view.addSubview(menu)

//        if let font = UIFont(name: "Helvetica", size: 18.0) {
//            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
//        }
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getProjectAccessTokens(accessToken: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.bezelView.color = UIColor.black
        hud.contentColor = UIColor.white

        Alamofire.request(apiBaseUrl+"project/\(selectedProject.projectId!)/access_tokens?access_token=\(accessToken)").validate().responseArray(keyPath: "result") { (response: DataResponse<[ProjectToken]>) in

            MBProgressHUD.hide(for: self.view, animated: true)
            switch response.result {
            case .success:

                self.tokens = response.result.value ?? []

                for projectToken in self.tokens where projectToken.name == "read" {
                        self.projectReadToken = projectToken.accessToken
                        self.getItems(projectReadAccessToken: projectToken.accessToken, queryParams: nil)
                        break
                }

                for projectToken in self.tokens where projectToken.name == "write" {
                        self.projectWriteToken = projectToken.accessToken
                        break
                }

            case .failure(let error):
                let alertVC = PMAlertController(title: "Invalid", description: error.localizedDescription, image:nil, style: .alert)

                alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in

                }))

                self.present(alertVC, animated: true, completion: nil)

                print(error)
            }
        }
    }

    func getItems(projectReadAccessToken: String, queryParams: String?) {
        self.noDataLabel.isHidden = true
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.bezelView.color = UIColor.black
        hud.contentColor = UIColor.white
        var url = apiBaseUrl+"items?access_token=\(projectReadAccessToken)&page=\(currentPage)"
        if let params = queryParams {
            url += params
        }

        Alamofire.request(url).validate().responseArray(keyPath: "result.items") { (response: DataResponse<[RollbarItem]>) in

            MBProgressHUD.hide(for: self.view, animated: true)
            switch response.result {
            case .success:

                if self.currentPage == 1 {
                    self.items = response.result.value ?? []
                } else {
                    self.items += response.result.value ?? []
                }

                self.itemsTableView.reloadData()

            case .failure(let error):
                let alertVC = PMAlertController(title: "Invalid", description: error.localizedDescription, image:nil, style: .alert)

                alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in

                }))

                self.present(alertVC, animated: true, completion: nil)

                print(error)
            }
        }.response { defaultDataResponse in
            let json = JSON(data: defaultDataResponse.data!)
            if json != JSON.null {
                self.currentPage = json["result"]["page"].int!
                self.totalItemCount = json["result"]["total_count"].int!
            }
        }
    }

    func filterItem() {
        queryParam = ""
        currentPage = 1
        totalItemCount = 0
        if selectedSeverity == "All" && selectedStatus == "All" {
            getItems(projectReadAccessToken: projectReadToken, queryParams: nil)
        } else {
            if selectedSeverity != "All" {
                queryParam += "&level=\(selectedSeverity.lowercased())"
            }

            if selectedStatus != "All" {
                queryParam += "&status=\(selectedStatus.lowercased())"
            }
            getItems(projectReadAccessToken: projectReadToken, queryParams: queryParam)
        }
    }

    func showStatusChangeOption(_ sender: UIButton) {
        currentItemId = sender.tag
        var statusArray: [String] = []
        switch sender.title(for: UIControlState.normal)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        case "active":
            statusArray = ["resolved", "muted"]
            break
        case "resolved":
            statusArray = ["active", "muted"]
            break
        case "muted":
            statusArray = ["active", "resolved"]
            break
        default:
            break
        }

        let actionSheet = UIAlertController(title: "Change Status", message: nil, preferredStyle: .actionSheet)
        for status in statusArray {
            actionSheet.addAction(UIAlertAction(title: status, style: .default) { action in
                // perhaps use action.title here
                self.actionSheetClicked(status: action.title!)
            })
        }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in

        })
        self.present(actionSheet, animated: true) {

        }
    }

    func actionSheetClicked(status: String) {
        if status == "resolved" {
            let alertVC = PMAlertController(title: "Resolved Version", description: "Enter version number in which this item got resolved", image: nil, style: .alert)
            alertVC.addTextField { (textField) in
                textField?.placeholder = "Version X.x"
            }
            alertVC.addAction(PMAlertAction(title: "Ok", style: .default, action: { () in
                self.modifyItem(params: ["status": "resolved", "resolved_in_version": alertVC.textFields[0].text ?? " "])
            }))
            alertVC.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in

            }))
            self.present(alertVC, animated: true, completion: nil)
        } else {
            modifyItem(params: ["status": status])
        }
    }

    func modifyItem(params: Parameters) {
        Alamofire.request(apiBaseUrl+"item/\(currentItemId)?access_token=\(projectWriteToken)", method: .patch, parameters: params, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in

            MBProgressHUD.hide(for: self.view, animated: true)
            switch response.result {
            case .success:
                self.getItems(projectReadAccessToken: self.projectReadToken, queryParams: self.queryParam)
                break
            case .failure(let error):
                let alertVC = PMAlertController(title: "Error", description: error.localizedDescription, image:nil, style: .alert)

                alertVC.addAction(PMAlertAction(title: "OK", style: .cancel, action: { () -> Void in

                }))
                self.present(alertVC, animated: true, completion: nil)
                print(error)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension RCProjectItemsViewController: JNDropDownMenuDelegate, JNDropDownMenuDataSource {
    func numberOfColumns(in menu: JNDropDownMenu) -> NSInteger {
        return 2
    }

    func numberOfRows(in column: NSInteger, for menu: JNDropDownMenu) -> Int {
        switch column {
        case 0:
            return severityArray.count
        case 1:
            return statusArray.count
        default:
            return 0
        }
    }

    func titleForRow(at indexPath: JNIndexPath, for menu: JNDropDownMenu) -> String {
        switch indexPath.column {
        case 0:
            return severityArray[indexPath.row]
        case 1:
            return statusArray[indexPath.row]

        default:
            return ""
        }
    }

    func didSelectRow(at indexPath: JNIndexPath, for menu: JNDropDownMenu) {
        switch indexPath.column {
        case 0:
            selectedSeverity = severityArray[indexPath.row]
            break
        case 1:
            selectedStatus = statusArray[indexPath.row]
        default:
            break
        }
        filterItem()
    }
}

extension RCProjectItemsViewController: UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            noDataLabel.isHidden = true
        } else {
            noDataLabel.isHidden = false
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCItemTableViewCell", for: indexPath) as? RCItemTableViewCell

        let rollbarItem = items[indexPath.row]
        cell?.setData(item: rollbarItem)
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        cell?.status.addTarget(self, action: #selector(showStatusChangeOption(_:)), for: UIControlEvents.touchUpInside)
        if indexPath.row == self.items.count-1 && self.items.count < self.totalItemCount {
            currentPage += 1
            getItems(projectReadAccessToken: self.projectReadToken, queryParams: queryParam)
        }
        return cell!
    }

}

extension RCProjectItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
