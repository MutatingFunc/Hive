//
//  DeviceListController.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

class DeviceListController: UIViewController {
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.dataSource = self
			tableView.delegate = self
		}
	}
	
	var deviceList: DeviceList? {
		didSet {
			deviceList?.registerActivities()
			if self.isViewLoaded {
				tableView.reloadData()
			}
		}
	}
	
	var didRestore = false
	override func decodeRestorableState(with coder: NSCoder) {
		super.decodeRestorableState(with: coder)
		didRestore = true
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if self.didRestore {
			self.didRestore = false
			(UIApplication.shared.delegate as? AppDelegate)?.reauthenticate()
		}
	}
}

extension DeviceListController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return deviceList?.devices.count ?? 0
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let deviceList = self.deviceList!
		switch deviceList.devices[indexPath.row] {
		case let device as LightDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as LightCell
			cell.setDevice(deviceList.light(device))
			return cell
		case let device as ColourLightDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ColourLightCell
			cell.setDevice(deviceList.colourLight(device))
			return cell
		case let device as ActionDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ActionCell
			cell.setDevice(deviceList.action(device))
			return cell
		case let device:
			let cell = tableView.dequeueReusableCell(for: indexPath) as DefaultDeviceCell
			cell.setDevice(device)
			return cell
		}
	}
}
