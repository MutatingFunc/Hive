//
//  DefaultDeviceCell.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

protocol DeviceCellDelegate: AnyObject {
	func isFavouriteChanged(device: Device)
}

class DefaultDeviceCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var typeLabel: UILabel!
	
	weak var delegate: DeviceCellDelegate?
	var device: Device! {
		didSet {
			nameLabel.text = device.name
			typeLabel.text = device.typeName
			[nameLabel, typeLabel].forEach {
				$0?.textColor = UIColor(named: device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
			}
		}
	}
	
	func setDevice(_ device: Device, delegate: DeviceCellDelegate?) {
		self.device = device
		self.delegate = delegate
	}
	
	@objc func favourite() {
		device.setIsFavourite(true)
		delegate?.isFavouriteChanged(device: self.device)
	}
	@objc func unfavourite() {
		device.setIsFavourite(false)
		delegate?.isFavouriteChanged(device: self.device)
	}
}
