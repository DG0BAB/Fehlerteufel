//
//  ErrorSeverity.swift
//  Fehlerteufel
//
//  Created by Joachim Deelen on 22.03.19.
//  Copyright © 2019 micabo software UG. All rights reserved.
//

import Foundation
#if canImport(AppKit)
import AppKit
#endif
import Clause


public protocol SeverityDescriptive {
	/// A localized text, describing the severity
	var severityDescription: String { get }
}

/**
Severity levels for Errors
*/
public enum Severity: SeverityDescriptive, TableNameProviding {
	/// Severity descriptions a read from Severity.strings by default
	static public var tableName: String { return "Severity" }

	/// Just an informational note.
	case info

	/// A warning - nothing really bad.
	case warning

	/// Error
	case error

	/// Fatal - Something really bad, better exit the App!
	case fatal

	/// Localized textual description of the severity.
	public var severityDescription: String {
		let severityString = "severity.\(self)"
		return NSLocalizedString(severityString, tableName: Severity.tableName, value: severityString, comment: "")
	}
}

#if canImport(AppKit)
extension Severity {
	func setStyleForAlert(_ alert: NSAlert) {
		switch self {
		case .info:
			alert.alertStyle = .informational
		case .warning:
			alert.alertStyle = .warning
		case .error, .fatal:
			alert.alertStyle = .critical
		}
	}
}
#endif