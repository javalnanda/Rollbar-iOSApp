//
//	Result.swift
//
//	Create by Javal Nanda on 22/4/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import ObjectMapper

class Project: NSObject, Mappable {

	var projectId: Int!
    var accountId: Int!
	var dateCreated: Int!
	var dateModified: Int!
	var name: String!
	var status: String!

    override init() {
        super.init()
    }

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        projectId <- map["id"]
        accountId <- map["account_id"]
        dateCreated <- map["date_created"]
        dateModified <- map["date_modified"]
        name <- map["name"]
        status <- map["status"]
    }

}
