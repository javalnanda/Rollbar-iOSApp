//
//  RCItemTableViewCell.swift
//  RollbarClient
//
//  Created by Javal Nanda on 4/24/17.
//  Copyright © 2017 Javal Nanda. All rights reserved.
//

import UIKit

class RCItemTableViewCell: UITableViewCell {

    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var status: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var occurences: UILabel!
    @IBOutlet weak var uniqueOccurences: UILabel!
    @IBOutlet weak var severity: UILabel!
    @IBOutlet weak var environment: UILabel!
    @IBOutlet weak var lastOccurenceDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setData(item: RollbarItem) {
        counter.text = " #"+String(describing: item.counter ?? 0)+" "
        status.setStatus(status: item.status!)
        title.text = item.title
        occurences.text = String(describing: item.totalOccurences ?? 0)

        if let occurence = item.uniqueOccurences {
           uniqueOccurences.text = String(describing: occurence)
        } else {
            uniqueOccurences.text = "-"
        }

        severity.setSeverity(severity: item.level!)
        environment.text = " "+item.environment!+" "
        lastOccurenceDate.text = "Last Occurence: "+getDateStr(unixTimeStamp: item.lastOccurenceTimeStamp!)
        status.tag = item.itemId!
    }

    func getDateStr(unixTimeStamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTimeStamp))
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
}

extension UILabel {
    func setSeverity(severity: String) {
        switch severity {
        case "info":
            self.text = "\u{E705}"
            self.textColor = UIColor.init(red: 73.0/255.0, green: 175.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            break
        case "debug":
            self.text = "\u{E704}"
            self.textColor = UIColor.init(red: 197.0/255.0, green: 197.0/255.0, blue: 197.0/255.0, alpha: 1.0)
            break
        case "warning":
            self.text = "\u{26A0}"
            self.textColor = UIColor.init(red: 250.0/255.0, green: 167.0/255.0, blue: 50.0/255.0, alpha: 1.0)
            break
        case "error":
            self.text = "\u{2716}"
            self.textColor = UIColor.init(red: 244.0/255.0, green: 98.0/255.0, blue: 43.0/255.0, alpha: 1.0)
            break
        case "critical":
            self.text = "\u{1F4A5}"
            self.textColor = UIColor.init(red: 237.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1.0)
            break
        default:
            break
        }
    }
}

extension UIButton {
    func setStatus(status: String) {
        self.setTitle(" "+status+" ", for: UIControlState.normal)
        switch status.lowercased() {
        case "resolved":
            self.backgroundColor = UIColor.init(red: 0.0, green: 255.0/255.0, blue: 0.0, alpha: 1.0)
            break
        case "active":
            self.backgroundColor = UIColor.init(red: 254.0/255.0, green: 194.0/255.0, blue: 10.0/255.0, alpha: 1.0)
            break
        case "muted":
            self.backgroundColor = UIColor.init(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            break
        default:
            break
        }
    }
}
