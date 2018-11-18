//
//  CommonAPI.swift
//  HiveShared
//
//  Created by James Froggatt on 18.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import Foundation

protocol ViewModel {
	associatedtype DeviceType
	var device: DeviceType {get set}
	var sessionID: SessionID {get}
	var api: APIManaging {get}
}

func vmSetIsOn<ViewModelType: ViewModel>(_ isOn: Bool, viewModel: inout ViewModelType, completion: @escaping (Response<()>) -> ()) -> Progress where ViewModelType.DeviceType == ToggleableDevice {
	viewModel.device.isOn = isOn
	donateIsOnIntent(viewModel.device)
	return viewModel.api.setOn(of: viewModel.device, sessionID: viewModel.sessionID, completion: completion)
}
func vmSetIsOn<ViewModelType: ViewModel>(_ isOn: Bool, viewModel: inout ViewModelType, completion: @escaping (Response<()>) -> ()) -> Progress where ViewModelType.DeviceType: ToggleableDevice {
	viewModel.device.isOn = isOn
	donateIsOnIntent(viewModel.device)
	return viewModel.api.setOn(of: viewModel.device, sessionID: viewModel.sessionID, completion: completion)
}

func vmSetBrightness<ViewModelType: ViewModel>(_ brightness: Float, viewModel: inout ViewModelType, completion: @escaping (Response<()>) -> ()) -> Progress where ViewModelType.DeviceType: AnyLightDevice {
	viewModel.device.isOn = brightness > 0
	donateIsOnIntent(viewModel.device)
	if brightness > 0 {
		viewModel.device.brightness = brightness
		donateBrightnessIntent(viewModel.device)
		return viewModel.api.updateBrightness(of: viewModel.device, sessionID: viewModel.sessionID, completion: completion)
	} else {
		return viewModel.api.setOn(of: viewModel.device, sessionID: viewModel.sessionID, completion: completion)
	}
}
