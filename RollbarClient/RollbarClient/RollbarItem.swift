//
//  RollbarItem.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/24/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit
import ObjectMapper

class RollbarItem: NSObject, Mappable {

    var lastActivatedTimeStamp: Int?
    var assignedUserId: Int?
    var uniqueOccurences: Int?
    var itemId: Int?
    var environment: String?
    var title: String?
    var lastOccurenceId: Int?
    var lastOccurenceTimeStamp: Int?
    var platform: String?
    var lastMutedTimeStamp: Int?
    var projectId: Int?
    var resolvedInVersion: Int?
    var firstOccurenceTimeStamp: Int?
    var status: String?
    var hashStr: String?
    var framework: String?
    var totalOccurences: Int?
    var level: String?
    var counter: Int?
    var lastModifiedBy: Int?
    var firstOccurenceId: Int?
    var activatingOccurenceId: Int?
    var lastResolvedTimeStamp: Int?

    override init() {
        super.init()
    }

    convenience required init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        lastActivatedTimeStamp <- map["last_activated_timestamp"]
        assignedUserId <- map["assigned_user_id"]
        uniqueOccurences <- map["unique_occurrences"]
        itemId <- map["id"]
        environment <- map["environment"]
        title <- map["title"]
        lastOccurenceId <- map["last_occurrence_id"]
        lastOccurenceTimeStamp <- map["last_occurrence_timestamp"]
        platform <- map["platform"]
        lastMutedTimeStamp <- map["last_muted_timestamp"]
        projectId <- map["project_id"]
        resolvedInVersion <- map["resolved_in_version"]
        firstOccurenceTimeStamp <- map["first_occurrence_timestamp"]
        status <- map["status"]
        hashStr <- map["hash"]
        framework <- map["framework"]
        totalOccurences <- map["total_occurrences"]
        level <- map["level"]
        counter <- map["counter"]
        lastModifiedBy <- map["last_modified_by"]
        firstOccurenceId <- map["first_occurrence_id"]
        activatingOccurenceId <- map["activating_occurrence_id"]
        lastResolvedTimeStamp <- map["last_resolved_timestamp"]
    }
}
