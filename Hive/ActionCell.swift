//
//  ActionCell.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

class ActionCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var actionButton: UIButton!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	
	var action: Action! {
		didSet {
			nameLabel.text = action.device.name
			self.isUserInteractionEnabled = action.device.isOnline
			nameLabel.textColor = UIColor(named: action.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
		}
	}
	
	weak var delegate: DeviceCellDelegate?
	
	func setDevice(_ action: Action, delegate: DeviceCellDelegate?) {
		self.action = action
		self.delegate = delegate
	}
	
	@objc func favourite() {
		action.device.setIsFavourite(true)
		delegate?.isFavouriteChanged(device: self.action.device)
	}
	@objc func unfavourite() {
		action.device.setIsFavourite(false)
		delegate?.isFavouriteChanged(device: self.action.device)
	}
	
	@IBAction func perform() {
		actionButton.isEnabled = false
		loadingIndicator.startAnimating()
		self.setHighlighted(true, animated: true)
		_ = action.quickAction {[weak self] in
			self?.setHighlighted(false, animated: true)
			self?.loadingIndicator.stopAnimating()
			self?.actionButton.isEnabled = true
		}
	}
}
