//
//  Reuseable.swift
//  StandardAdditions
//
//  Created by James Froggatt on 11.06.2016.
//  Copyright © 2016 James Froggatt. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public protocol ReuseIdentifiable {
	static var reuseID: String {get}
}
public extension ReuseIdentifiable where Self: UITableViewCell {
	static var reuseID: String {return String(describing: self)}
}
public extension ReuseIdentifiable where Self: UICollectionViewCell {
	static var reuseID: String {return String(describing: self)}
}

public extension UITableView {
	func register(cell cellClass: (UITableViewCell & ReuseIdentifiable).Type) {
		self.register(cellClass, forCellReuseIdentifier: cellClass.reuseID)
	}
	func dequeueReusableCell<Identifiable: UITableViewCell & ReuseIdentifiable>(for indexPath: IndexPath) -> Identifiable! {
		return self.dequeueReusableCell(withIdentifier: Identifiable.reuseID, for: indexPath) as? Identifiable
	}
	
	func dequeueReusableHeaderFooterView<Identifiable: UITableViewHeaderFooterView & ReuseIdentifiable>() -> Identifiable! {
		return self.dequeueReusableHeaderFooterView(withIdentifier: Identifiable.reuseID) as? Identifiable
	}
}

public extension UICollectionView {
	func register(cell cellClass: (UICollectionViewCell & ReuseIdentifiable).Type) {
		self.register(cellClass, forCellWithReuseIdentifier: cellClass.reuseID)
	}
	func dequeueReusableCell<Identifiable: UICollectionViewCell & ReuseIdentifiable>(for indexPath: IndexPath) -> Identifiable! {
		return self.dequeueReusableCell(withReuseIdentifier: Identifiable.reuseID, for: indexPath) as? Identifiable
	}
	func dequeueReusableSupplementaryView<Identifiable: UICollectionReusableView & ReuseIdentifiable>(ofKind kind: String, for indexPath: IndexPath) -> Identifiable! {
		return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifiable.reuseID, for: indexPath) as? Identifiable
	}
}

@available(iOSApplicationExtension 11.0, *)
public extension UITableViewDropPlaceholder {
	public convenience init<Identifiable: UITableViewCell & ReuseIdentifiable>(insertionIndexPath: IndexPath, ofType: Identifiable.Type, rowHeight: CGFloat) {
		self.init(insertionIndexPath: insertionIndexPath, reuseIdentifier: Identifiable.reuseID, rowHeight: rowHeight)
	}
}
@available(iOSApplicationExtension 11.0, *)
public extension UICollectionViewDropPlaceholder {
	public convenience init<Identifiable: UICollectionViewCell & ReuseIdentifiable>(insertionIndexPath: IndexPath, ofType: Identifiable.Type) {
		self.init(insertionIndexPath: insertionIndexPath, reuseIdentifier: Identifiable.reuseID)
	}
}
#endif
