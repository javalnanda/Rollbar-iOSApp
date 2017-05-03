//
//  ProjectToken.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/24/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit
import ObjectMapper

class ProjectToken: NSObject, Mappable {

    var projectId: Int!
    var accessToken: String!
    var name: String!
    var status: String!
    var dateCreated: Int!
    var dateModified: Int!
    var scopes: [String]!

    override init() {
        super.init()
    }

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        projectId <- map["project_id"]
        accessToken <- map["access_token"]
        dateCreated <- map["date_created"]
        dateModified <- map["date_modified"]
        name <- map["name"]
        status <- map["status"]
        scopes <- map["scopes"]
    }

}
