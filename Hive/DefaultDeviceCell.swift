//
//  DefaultDeviceCell.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

class DefaultDeviceCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var typeLabel: UILabel!
	
	func setDevice(_ device: Device) {
		nameLabel.text = device.name
		typeLabel.text = device.typeName
		[nameLabel, typeLabel].forEach {
			$0?.textColor = UIColor(named: device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
		}
	}
}
