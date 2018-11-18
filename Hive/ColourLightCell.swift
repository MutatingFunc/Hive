//
//  ColourLightCell.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

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
	
	weak var delegate: DeviceCellDelegate?
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
	
	func setDevice(_ light: ColourLight, delegate: DeviceCellDelegate?) {
		self.light = light
		self.delegate = delegate
	}
	
	@objc func favourite() {
		light.device.setIsFavourite(true)
		delegate?.isFavouriteChanged(device: self.light.device)
	}
	@objc func unfavourite() {
		light.device.setIsFavourite(false)
		delegate?.isFavouriteChanged(device: self.light.device)
	}
	
	@IBAction func valueChanged(sender: UISlider) {
		let colour = colourSlider.value.rounded()
		let saturation = saturationSlider.value.rounded()
		let brightness = brightnessSlider.value.rounded()
		loadingIndicator.startAnimating()
		let isColourValue = colourControl.selectedSegmentIndex == 0
		let state: ColourLightDevice.State =
			isColourValue
				? .colour(hue: colour, saturation: saturation, brightness: brightness)
				: .white(temperature: colour, brightness: brightness)
		self.setHighlighted(true, animated: true)
		let senderType: ColourLight.SetStateSender
		switch sender {
		case colourSlider:
			senderType = isColourValue ? .hue : .temperature
		case saturationSlider:
			senderType = .saturation
		case _:
			senderType = .brightness
		}
		_ = self.light.setState(state, sender: senderType) {[weak self] response in
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
	}
}
