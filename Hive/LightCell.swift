//
//  LightCell.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

class LightCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.loadingIndicator?.stopAnimating()
	}
	
	var light: Light! {
		didSet {
			nameLabel.text = light.device.name
			self.isUserInteractionEnabled = light.device.isOnline
			nameLabel.textColor = UIColor(named: light.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
			brightnessSlider.value = light.device.isOn ? Float(light.device.brightness) : 0
		}
	}
	
	func setDevice(_ light: Light) {
		self.light = light
	}
	
	@IBAction func brightnessSliderChanged() {
		let brightness = brightnessSlider.value.rounded()
		loadingIndicator.startAnimating()
		self.setHighlighted(true, animated: true)
		_ = self.light.setBrightness(brightness) {[weak self] in
			self?.setHighlighted(false, animated: true)
			self?.loadingIndicator.stopAnimating()
		}
	}
}
