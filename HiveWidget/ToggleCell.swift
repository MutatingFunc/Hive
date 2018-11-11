//
//  ToggleCell.swift
//  HiveWidget
//
//  Created by James Froggatt on 11.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

class ToggleCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var isOnSwitch: UISwitch!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	
	weak var delegate: DeviceCellDelegate?
	var toggle: Toggle! {
		didSet {
			nameLabel.text = toggle.device.name
			self.isUserInteractionEnabled = toggle.device.isOn
			nameLabel.textColor = UIColor(named: toggle.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
		}
	}
	
	func setDevice(_ toggle: Toggle, delegate: DeviceCellDelegate?) {
		self.toggle = toggle
		self.delegate = delegate
	}
	
	@objc func favourite() {
		toggle.device.setIsFavourite(true)
		delegate?.isFavouriteChanged(device: self.toggle.device)
	}
	@objc func unfavourite() {
		toggle.device.setIsFavourite(false)
		delegate?.isFavouriteChanged(device: self.toggle.device)
	}
	
	@IBAction func setOn() {
		isOnSwitch.isEnabled = false
		loadingIndicator.startAnimating()
		self.setHighlighted(true, animated: true)
		_ = toggle.setOn(isOnSwitch.isOn) {[weak self] in
			self?.setHighlighted(false, animated: true)
			self?.loadingIndicator.stopAnimating()
			self?.isOnSwitch.isEnabled = true
		}
	}
}
