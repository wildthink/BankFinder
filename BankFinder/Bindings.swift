//
//  Presenter.swift
//  ATMFinder_SQLite
//
//  Created by Jobe, Jason on 3/10/20.
//  Copyright © 2020 Jobe, Jason. All rights reserved.
//

import UIKit

/*
@objc public protocol UIPresenter: NSObjectProtocol {
    func refresh(from model: BaseViewModel)
}

extension UIViewController: UIPresenter {
    @objc public func refresh(from model: BaseViewModel) {}
}


// MARK: - Default SearchBarDelegate 
extension UIViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let key = searchBar.presented ?? "search"
//        print (#line, key, searchText)
        BaseViewModel.shared?.set(key, to: searchText)
    }
}
*/

public extension UIViewController {
    func visit(visibleOnly: Bool = true, _ call: (UIViewController) -> Void) {
        call(self)
        let kids = visibleOnly ? self.visibleViewControllers : self.children
        for kid in kids {
            kid.visit(visibleOnly: visibleOnly, call)
        }
    }
}

public extension UIView {
    func visit(_ call: (UIView) -> Void) {
        call(self)
        for kid in subviews {
            kid.visit(call)
        }
    }
}


@dynamicMemberLookup
public class Bindings: NSObject {

    var values: [String: String] = [:]

    public var isEmpty: Bool { return values.count == 0 }

    subscript(dynamicMember key: String) -> String? {
        get { return values[key] }
        set { values[key] = newValue }
    }
}


private var _bindings_key = "bindings_key"

/**
 This extension adds qKey and qname to all UIResponders. The qKey is exposed
 as Inspectable in Interface Builder and can also be set in code. The qname is
 read-only and derived from the qKeys are runtime.
 */
extension UIView {

    /** The namespace is a relative name/key that should be unique
     within the hierarchy in which it is instantiated.
     */
    @IBInspectable
    public var namespace: String? {
        get { return ib.namespace }
        set { ib.namespace = newValue }
    }

//    @IBInspectable
//    public var entityId: String? {
//        get { return ib.entityId }
//        set { ib.entityId = newValue }
//    }

    @IBInspectable
    public var modelId: String? {
        get { return ib.modelId }
        set { ib.modelId = newValue }
    }
/*
    @IBInspectable
    public var presented: String? {
        get { return ib.presented }
        set { ib.presented = newValue }
    }

    @IBInspectable
    public var ibEnabled: String? {
        get { return ib.enabled }
        set { ib.enabled = newValue }
    }

    @IBInspectable
    public var ibVisible: String? {
        get { return ib.visible }
        set { ib.visible = newValue }
    }
 */
}

/*
extension UISearchBar {

    @IBInspectable
    public var searchTable: String? {
        get { return ib.searchTable }
        set { ib.searchTable = newValue }
    }

    @IBInspectable
    public var searchCols: String? {
        get { return ib.searchCols }
        set { ib.searchCols = newValue }
    }

}
*/

extension UIViewController {

    /** The namespace is a relative name/key that should be unique
     within the hierarchy in which it is instantiated.
     */
    @IBInspectable
    public var namespace: String? {
        get { return ib.namespace }
        set { ib.namespace = newValue }
    }

//    @IBInspectable
//    public var entityId: String? {
//        get { return ib.entityId }
//        set { ib.entityId = newValue }
//    }

    @IBInspectable
    public var modelId: String? {
        get { return ib.modelId }
        set { ib.modelId = newValue }
    }

//    @IBInspectable
//    public var presented: String? {
//        get { return ib.presented }
//        set { ib.presented = newValue }
//    }
//
//    @IBInspectable
//    public var ibEnabled: String? {
//        get { return ib.enabled }
//        set { ib.enabled = newValue }
//    }
//
//    @IBInspectable
//    public var ibVisible: String? {
//        get { return ib.visible }
//        set { ib.visible = newValue }
//    }
}

extension UIResponder {

    public var ib: Bindings {
        get {
            let bindings: Bindings =
                objc_getAssociatedObject(self, &_bindings_key) as? Bindings
                    ?? {
                        let bindings = Bindings()
                        self.ib = bindings
                        return bindings
                    }()
            return bindings
        }
        set {
            objc_setAssociatedObject(self, &_bindings_key,
                                     newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

// MARK: Content Value Extensions

extension UIView {

    @objc public var contentValue: Any? {
        get { return nil }
        set {}
    }
}

extension UIActivityIndicatorView {
    @objc override public var contentValue: Any? {
        get { return isAnimating }
        set {
            let flag: Bool = (newValue as? Bool) ?? false
            if flag {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
}

extension UISwitch {
    @objc override public var contentValue: Any? {
        get { return isOn }
        set {
            let value: Bool = (newValue as? Bool) ?? false
            isOn = value
        }
    }
}

extension UILabel {
    @objc override public var contentValue: Any? {
        get { return text }
        set {
            if let value = newValue {
                text = "\(value)"
            } else {
                text = nil
            }
        }
    }
}

extension UITextField {
    @objc override public var contentValue: Any? {
        get { return text }
        set {
            if let value = newValue {
                text = "\(value)"
            } else {
                text = nil
            }
        }
    }
}

// MARK: Visible View Controllers

@objc protocol ActiveController where Self: UIViewController {
    var visibleViewControllers: [UIViewController] { get }
}

extension UIViewController: ActiveController {
    public var visibleViewControllers: [UIViewController] {
        return self.children
    }
}

extension UINavigationController {
    public override var visibleViewControllers: [UIViewController] {
        guard let visibleViewController = visibleViewController else { return [] }
        return [visibleViewController]
    }
}

extension UITabBarController {
    public override var visibleViewControllers: [UIViewController] {
        guard let visibleViewController = selectedViewController else { return [] }
        return [visibleViewController]
    }
}

extension UISplitViewController {
    public override var visibleViewControllers: [UIViewController] {
        return self.viewControllers
    }
}

