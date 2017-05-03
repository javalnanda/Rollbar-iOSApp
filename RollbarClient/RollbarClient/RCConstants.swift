//
//  RCConstants.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/21/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import Foundation
import UIKit

let apiBaseUrl = "https://api.rollbar.com/api/1/"

let rcStoryBoard: UIStoryboard  = UIStoryboard(name: "Main", bundle: nil)

struct KeychainVar {
    static let service = "com.faodailtechnology.rollbar"
    static let accesstoken = "accesstoken"
}
