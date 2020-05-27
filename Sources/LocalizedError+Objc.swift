//
//  LocalizedError+Objc.swift
//  Fehlerteufel
//
//  Created by Joachim Deelen on 08.04.19.
//  Copyright © 2019 micabo software UG. All rights reserved.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Clause

@objc
extension NSError {
	
	#if canImport(UIKit)
	
	@objc
	func alertController(_ preferredStyle: UIAlertController.Style = .alert ) -> UIAlertController {
		var message = localizedFailureReason;
		if let recoverySuggestion = localizedRecoverySuggestion,
			recoverySuggestion.count > 0 {
			message = message?.count ?? 0 > 0 ? message! + "\n" + recoverySuggestion : recoverySuggestion
		}
		return UIAlertController(title: localizedDescription, message: message, preferredStyle: preferredStyle)
	}
	
	@objc
	func presentOkAlert(_ viewController: UIViewController) {
		self.presentOkAlert(viewController, as: .alert, completion: nil)
	}
	
	@objc
	func presentOkAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style)
		alert.addAction(UIAlertAction(title: Clause("OK").localization(), style: .default, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
	
	@objc
	func presentOkCancelAlert(_ viewController: UIViewController) {
		self.presentOkCancelAlert(viewController, as: .alert, completion: nil)
	}
	
	@objc
	func presentOkCancelAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style)
		alert.addAction(UIAlertAction(title: Clause("OK").localization(), style: .default, handler: completion))
		alert.addAction(UIAlertAction(title: Clause("Cancel").localization(), style: .cancel, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
	
	#elseif canImport(AppKit)
	
	var alert: NSAlert {
		let alert = NSAlert(error: self)
		if let localizedError = self as? LocalizedError {
			localizedError.severity.setStyleForAlert(alert)
		}
		return alert
	}
	
	#endif
}
