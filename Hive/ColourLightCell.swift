//
//  ColourLightCell.swift
//  Hive
//
//  Created by James Froggatt on 05.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared
import HueKit

class ColourLightCell: UITableViewCell, ReuseIdentifiable {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var saturationLabel: UILabel!
	@IBOutlet var sliderLabels: [UILabel]!
	@IBOutlet var colourControl: UISegmentedControl!
	@IBOutlet var colourSlider: UISlider!
	@IBOutlet var colourStepper: UIStepper!
	@IBOutlet var colourBar: ColorBarPicker!
	@IBOutlet var saturationSlider: UISlider!
	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet var colourViews: [UIView]!
	@IBOutlet var whiteViews: [UIView]!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.loadingIndicator?.stopAnimating()
	}
	
	weak var delegate: DeviceCellDelegate?
	var light: ColourLight! {
		didSet {
			nameLabel.text = light.device.name
			self.isUserInteractionEnabled = light.device.isOnline
			([nameLabel] + sliderLabels).forEach{
				$0.textColor = UIColor(named: light.device.isOnline ? Color.textColor.rawValue : Color.disabledTextColor.rawValue)
			}
			switch light.device.state {
			case let .colour(hue: h, saturation: s, brightness: b):
				whiteViews.forEach{$0.isHidden = true}
				colourViews.forEach{$0.isHidden = false}
				colourControl.selectedSegmentIndex = 0
				colourSlider.value = Float(h)
				colourStepper.value = Double(h)
				colourBar.hue = CGFloat(h) / 100
				saturationSlider.value = Float(s)
				saturationSlider.isEnabled = true
				brightnessSlider.value = light.device.isOn ? Float(b) : 0
			case let .white(h, b):
				whiteViews.forEach{$0.isHidden = false}
				colourViews.forEach{$0.isHidden = true}
				colourControl.selectedSegmentIndex = 1
				colourSlider.value = Float(h)
				colourStepper.value = Double(h)
				colourBar.hue = CGFloat(h) / 100
				saturationSlider.value = saturationSlider.maximumValue
				saturationSlider.isEnabled = false
				saturationLabel.textColor = UIColor(named: Color.disabledTextColor.rawValue)
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
	
	func intentType(for view: UIView, isColourValue: Bool) -> ColourLight.SetStateIntentType? {
		switch view {
		case colourBar, colourControl, colourSlider, colourStepper:
			return isColourValue ? .hue : .temperature
		case saturationSlider:
			return .saturation
		case brightnessSlider:
			return .brightness
		case _:
			return nil
		}
	}
	
	func updateColourControls(sender: UIView, isColourValue: Bool) {
		switch sender {
		case colourSlider:
			colourStepper.value = Double(colourSlider.value.rounded())
			colourBar.hue = CGFloat(colourSlider.value.rounded() / 100)
		case colourStepper:
			colourSlider.value = Float(colourStepper.value.rounded())
			colourBar.hue = CGFloat(colourStepper.value.rounded() / 100)
		case colourBar:
			colourStepper.value = Double(colourBar.hue * 100)
			colourSlider.value = Float(colourBar.hue * 100)
		case colourControl:
			whiteViews.forEach{$0.isHidden = isColourValue == true}
			colourViews.forEach{$0.isHidden = isColourValue == false}
		case _: break
		}
	}
	
	@IBAction func valueChanged(sender: UIView) {
		let isColourValue = colourControl.selectedSegmentIndex == 0
		updateColourControls(sender: sender, isColourValue: isColourValue)
		
		let colour = colourSlider.value.rounded()
		let saturation = saturationSlider.value.rounded()
		let brightness = brightnessSlider.value.rounded()
		
		let state: ColourLightDevice.State =
			isColourValue
				? .colour(hue: colour, saturation: saturation, brightness: brightness)
				: .white(temperature: colour, brightness: brightness)
		let intentType = self.intentType(for: sender, isColourValue: isColourValue)
		
		loadingIndicator.startAnimating()
		self.setHighlighted(true, animated: true)
		_ = self.light.setState(state, intentType: intentType) {[weak self] response in
			switch response {
			case .success(_, _):
				self?.endPerform()
			case .error(let error, _):
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
