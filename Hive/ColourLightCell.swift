//
//  ColourLightCell.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

class ColourLightCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var saturationLabel: UILabel!
	@IBOutlet var colourControl: UISegmentedControl!
	@IBOutlet var colourSlider: UISlider!
	@IBOutlet var saturationSlider: UISlider!
	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.loadingIndicator?.stopAnimating()
	}
	
	var light: ColourLight! {
		didSet {
			nameLabel.text = light.device.name
			self.isUserInteractionEnabled = light.device.isOnline
			[nameLabel, saturationLabel].forEach{
				$0.textColor = UIColor(named: light.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
			}
			switch light.device.state {
			case let .colour(hue: h, saturation: s, brightness: b):
				colourControl.selectedSegmentIndex = 0
				colourSlider.value = Float(h)
				saturationSlider.value = Float(s)
				saturationSlider.isEnabled = true
				brightnessSlider.value = light.device.isOn ? Float(b) : 0
			case let .white(h, b):
				colourControl.selectedSegmentIndex = 1
				colourSlider.value = Float(h)
				saturationSlider.value = saturationSlider.maximumValue
				saturationSlider.isEnabled = false
				brightnessSlider.value = light.device.isOn ? Float(b) : 0
			}
		}
	}
	
	func setDevice(_ light: ColourLight) {
		self.light = light
	}
	
	@IBAction func valueChanged() {
		let colour = colourSlider.value.rounded()
		let saturation = saturationSlider.value.rounded()
		let brightness = brightnessSlider.value.rounded()
		loadingIndicator.startAnimating()
		let state: ColourLightDevice.State =
			colourControl.selectedSegmentIndex == 0
				? .colour(hue: colour, saturation: saturation, brightness: brightness)
				: .white(temperature: colour, brightness: brightness)
		self.setHighlighted(true, animated: true)
		_ = self.light.setState(state) {[weak self] in
			self?.setHighlighted(false, animated: true)
			self?.loadingIndicator.stopAnimating()
		}
	}
}
