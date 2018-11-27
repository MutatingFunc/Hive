//
//  DeviceListController.swift
//  Hive
//
//  Created by James Froggatt on 04.11.2018.
//  Copyright © 2018 James Froggatt. All rights reserved.
//

import UIKit

import HiveShared

class DeviceListController: UIViewController {
	@IBOutlet var deviceTableView: UITableView! {
		didSet {
			deviceTableView.dataSource = self
			deviceTableView.delegate = self
		}
	}
	@IBOutlet var actionTableView: UITableView! {
		didSet {
			actionTableView.dataSource = self
			actionTableView.delegate = self
		}
	}
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var pageControl: UIPageControl!
	
	let refreshControl = UIRefreshControl()
	
	var deviceList: DeviceList? {
		didSet {
			if self.isViewLoaded {
				deviceTableView.reloadData()
				actionTableView.reloadData()
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.updateNumberOfPages()
		
		self.deviceTableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
		
		UIMenuController.shared.menuItems = [UIMenuItem(title: "Favourite", action: #selector(DefaultDeviceCell.favourite)), UIMenuItem(title: "Unfavourite", action: #selector(DefaultDeviceCell.unfavourite))]
	}
	
	@objc func reload() {
		_ = self.deviceList?.reload {[weak self] deviceList in
			if let deviceList = deviceList {
				self?.deviceList = deviceList
				self?.refreshControl.endRefreshing()
			}
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: nil) {[weak self] _ in
			self?.updateNumberOfPages()
		}
	}
	
	func updateNumberOfPages() {
		self.pageControl.numberOfPages = Int(self.scrollView.contentSize.width / self.scrollView.visibleSize.width)
	}
	
	@IBAction func pageChanged() {
		let offset = self.scrollView.visibleSize.width * CGFloat(self.pageControl.currentPage)
		UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
			self.scrollView.contentOffset.x = offset
		}, completion: nil)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		scrollView.scrollIndicatorInsets = view.safeAreaInsets
		let insets = UIEdgeInsets(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
		deviceTableView.scrollIndicatorInsets = insets
		actionTableView.scrollIndicatorInsets = insets
		
		deviceTableView.layoutMargins = tableMargins(sharedSide: \.right)
		actionTableView.layoutMargins = tableMargins(sharedSide: \.left)
		
		deviceTableView.separatorInset = separatorInset(edgeSide: \.left)
		actionTableView.separatorInset = separatorInset(edgeSide: \.right)
	}
	override func viewLayoutMarginsDidChange() {
		super.viewLayoutMarginsDidChange()
		
		deviceTableView.layoutMargins = tableMargins(sharedSide: \.right)
		actionTableView.layoutMargins = tableMargins(sharedSide: \.left)
		
		deviceTableView.separatorInset = separatorInset(edgeSide: \.left)
		actionTableView.separatorInset = separatorInset(edgeSide: \.right)
	}
	func tableMargins(sharedSide: WritableKeyPath<UIEdgeInsets, CGFloat>) -> UIEdgeInsets {
		var margins = view.layoutMargins
		if self.traitCollection.horizontalSizeClass != .compact {
			margins[keyPath: sharedSide] -= view.safeAreaInsets[keyPath: sharedSide]
		}
		return margins
	}
	func separatorInset(edgeSide: WritableKeyPath<UIEdgeInsets, CGFloat>) -> UIEdgeInsets {
		var insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
		if self.traitCollection.horizontalSizeClass != .compact {
			insets[keyPath: edgeSide] += view.safeAreaInsets[keyPath: edgeSide]
		}
		return insets
	}
}

extension DeviceListController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch tableView {
		case actionTableView: return deviceList?.actions.count ?? 0
		case deviceTableView: return deviceList?.devices.count ?? 0
		case _: return 0
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let deviceList = self.deviceList!
		let devices: [Device]
		switch tableView {
		case actionTableView: devices = deviceList.actions
		case deviceTableView: devices = deviceList.devices
		case _: devices = []
		}
		switch devices[indexPath.row] {
		case let device as LightDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as LightCell
			cell.setDevice(deviceList.light(device), delegate: self)
			return cell
		case let device as ColourLightDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ColourLightCell
			cell.setDevice(deviceList.colourLight(device), delegate: self)
			return cell
		case let device as ActionDevice:
			let cell = tableView.dequeueReusableCell(for: indexPath) as ActionCell
			cell.setDevice(deviceList.action(device), delegate: self)
			return cell
		case let device:
			let cell = tableView.dequeueReusableCell(for: indexPath) as DefaultDeviceCell
			cell.setDevice(device, delegate: self)
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		let deviceList = self.deviceList!
		let device: Device
		switch tableView {
		case deviceTableView: device = deviceList.devices[indexPath.row]
		case actionTableView: device = deviceList.actions[indexPath.row]
		case _: return false
		}
		return device.isFavourite()
			? action == #selector(DefaultDeviceCell.unfavourite)
			: action == #selector(DefaultDeviceCell.favourite)
	}
	func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
	}
}

extension DeviceListController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView === self.scrollView else {
			return
		}
		let index = Int((scrollView.contentOffset.x + (scrollView.visibleSize.width / 2)) / scrollView.visibleSize.width)
		let limitedIndex = min(max(index, 0), self.pageControl.numberOfPages)
		self.pageControl.currentPage = limitedIndex
	}
}

extension DeviceListController: DeviceCellDelegate {
	func isFavouriteChanged(device: Device) {
		if device is ActionDevice {
			self.deviceList?.sortActions()
		} else {
			self.deviceList?.sortDevices()
		}
	}
}
