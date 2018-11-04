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
	
	var deviceList: DeviceList!
}

extension DeviceListController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return deviceList.devices.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch deviceList.devices[indexPath.row] {
		case let device as LightDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as LightCell
			cell.setDevice(deviceList.light(device))
			return cell
		case let device:
			let cell = tableView.dequeueReusableCell(for: indexPath) as DefaultDeviceCell
			cell.setDevice(device)
			return cell
		}
	}
}
