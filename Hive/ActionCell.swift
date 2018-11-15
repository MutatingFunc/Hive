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
			nameLabel.textColor = UIColor(named: action.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
			self.isUserInteractionEnabled = action.device.isOnline
			actionButton.isEnabled = action.device.isOnline
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
		_ = action.quickAction {[weak self] response in
			switch response {
			case .success(_, _):
				self?.endPerform()
			case .error(let error, _):
				if error as? ErrorResponse == ErrorResponse.notAuthorized {
					ReauthenticationCoordinator.shared?.reauthenticate()
				}
				self?.nameLabel.flashError(error.localizedDescription) {[weak self] in
					self?.endPerform()
				}
			}
		}
	}
	private func endPerform() {
		self.setHighlighted(false, animated: true)
		self.loadingIndicator.stopAnimating()
		self.actionButton.isEnabled = true
	}
}
