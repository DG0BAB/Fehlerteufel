//
//  LocalizedError.swift
//  Fehlerteufel
//
//  Created by Joachim Deelen on 22.03.19.
//  Copyright © 2019 micabo software UG. All rights reserved.
//

import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Clause

/**
Error-Type with severity, localization support and position independent
parameter/value substitution.

All text used for title, failure-reason and recovery suggestion, constructed using
a `Clause`, which in turn uses Swift 5 `ExpressibleByStringInterpolation` protocol, to make it
possible to specify parameter values directly within the string literal.

Like so:
```
let path = "/data"
let name = "VeryImportantData"
let error: MyError = .fileError { "File \("name:", name) not found at path \("path:", path)." }
```
This creates a `fileError` of Type `MyError` with internal code "fileError",
an `errorDescription` with "fileError" and a `failureReason`: "File VeryImportantData not found at path /data."

To make i.e. the `errorDescription` more appealing you just add a locaization strings file.
```
"MyError.fileError" = "File Error";
```
If you now query the `errorDescription` you'll get: "File Error" instead of "fileError".

If you want to provide i.e. german localization you just add the appropriate strings-file.

```
"MyError.fileError" = "Datei Fehler";
"MyError.fileError.failure.File \\(name: %@) not found at path \\(path: %@)." = "Unter “\\(path %@)” konnte die Datei “\\(name: %@)” nicht gefunden werden.";
```
Now you get "Datei Fehler" for the `errorDescription` and
"Unter “/data” konnte die Datei “VeryImportantData” nicht gefunden werden." for the `failureReason`

This also is a great example to show parameter position independency. The original
`failureReason` put the `name` in front of the `path`. In the transalation `path` is used first.

__Note:__ The parameter `title` maps to `errorDescription` of the `Swift.LocalizedError`

To create your own error type, only a few lines of code are needed.

```
struct MyError: LocalizedError {
	// All localizations are retrived from a file called "MyErrors.strings"
	// If you dont specify this, all localizations a taken from "Localizable.string"
	static var tableName: String { return "MyErrors" }

	// Required to fulfill protocol conformance
	let specifics: ErrorSpecifics
	init(_ specifics: ErrorSpecifics) { self.specifics = specifics }

	static func fileError(_ code: String = "\(#function)", title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) -> MyError {
		return Error(code, .warning, title: title, recovery: recovery, failure)
	}
}
```
To add more, just copy&paste the static function and rename it to whatever name you want your error to have. Don't forget to adjust the severity to your needs.
The easiest usage of this error is
```
let error = MyError.fileError
```
This creates a `fileError` with a severity `.warning` with `code` and `errorDescription` set to "fileError".
```
let name = "Customer"
let error = MyError.fileError(title: "File Error Occurred") { "File “\("name:", name)” was not found." }
```
This creates a `fileError` with a severity `.warning` with `code` set to "fileError", `errorDescription` set to "File Error Occurred" and `failureReason` set to "File “Customer” was not found".
To specify localizations, just add "MyError.string" files to the appropriate .lproj-directories or let Xcode doing it for you.

If you want to localize the error title while `code` and `title` are the same just add the following line to the localization file:
```
"MyError.fileError" = "File Error";
```
If you specify a title explicitly, like in the example above, the localization should look like:
```
"MyError.fileError.File Error Occured" = "Occurence of file error";
```
*/
public protocol LocalizedError: Foundation.LocalizedError, CustomStringConvertible, TableNameProviding {

	typealias ErrorAction = (LocalizedError) -> Void
	
	/** Store for error details.

	This has to be provided by the concrete error type
	__Required.__
	*/
	var specifics: ErrorSpecifics { get }

	
	/** Initialzes the error with the given details

	This has to be provided by the concrete error type
	__Required.__
	*/
	init(_ specifics: ErrorSpecifics)

	var code: String { get }
	
	/// Contains the `Error` that caused this error or nil
	var cause: Error? { get }

	
	/** The severity of this error.

	__Required.__
	*/
	var severity: Severity { get }

	
	/** This prefix is prepended to keys when retrieving the localized string
	for the error title from a .strings-file.

	Defaults to the name of the concrete type. If you i.e. declare a type
	`MyError: LocalizedError` with `code` `fileNotFound`, the resulting key for
	accessing the strings file will be "MyError.fileNotFound"

	If you don't want any prefix just overwrite this in your error type and
	return an empty "" string.

	__Required.__ Default implementation provided
	*/
	var prefix: String { get }

	
	/** This prefix is prepended to keys when retrieving the localized string
	for the failure reason from a .strings-file.

	Defaults to "failure"

	If you i.e. declare a type `MyError: LocalizedError` with `code` `fileNotFound`,
	the resulting key for accessing the failure reason in the strings file
	will be "MyError.fileNotFound.failure"

	If you don't want any prefix just overwrite this in your error type and
	return an empty "" string.

	__Required.__ Default implementation provided
	*/
	var failurePrefix: String { get }

	
	/** This prefix is prepended to keys when retrieving the localized string
	for the reovery suggestion from a .strings-file.

	Defaults to "recovery"

	If you i.e. declare a type `MyError: LocalizedError` with `code` `fileNotFound`,
	the resulting key for accessing the recovery suggestion in the strings file
	will be "MyError.fileNotFound.recovery"

	If you don't want any prefix just overwrite this in your error type and
	return an empty "" string.

	__Required.__ Default implementation provided
	*/
	var recoveryPrefix: String { get }

	
	#if canImport(UIKit)
	
	/** A `UIAlertController` with `title` initialized to the localized title
	and `message` set to the localized failure text of this error.

	The default `preferredStyle` is set to `.alert`
	__Required.__ Default implementation provided
	*/
	func alertController(_ preferredStyle: UIAlertController.Style) -> UIAlertController
	
	#elseif canImport(AppKit)
	
	/// A `NSAlert` initialized with this error
	/// __Required.__ Default implementation provided
	var alert: NSAlert { get }
	
	#endif

	#if canImport(UIKit)
	
	/** Presents this `LocalizedError` as an `UIAlertController` together with an
	OK `UIAlertAction` Button

	__Required.__ Default implementation provided

	- Parameters:
		- viewController: The `UIViewController` used as the presenting view controller
	   	- style: `UIAlertController` style. Defaults to .alert
		- completion: If given, it gets called when the OK action was selected
	*/
	func presentOkAlert(_ viewController: UIViewController, as style: UIAlertController.Style, completion: ((UIAlertAction) -> Void)?)

	/** Presents this `LocalizedError` as an `UIAlertController` together with
	OK and Cancel `UIAlertAction` Buttons.

	__Required.__ Default implementation provided

	- Parameters:
	- viewController: The `UIViewController` used as the presenting view controller
	- style: `UIAlert*Controller` style. Defaults to .alert
	- completion: If given, it gets called when the OK or Cancel action was selected
	*/
	func presentOkCancelAlert(_ viewController: UIViewController, as style: UIAlertController.Style, completion: ((UIAlertAction) -> Void)?)
	
	#endif
}

/// Type that returns the `Clause` that is used as the failure text of the error
public typealias FailureText = () -> Clause

public extension LocalizedError {

	/** Factory method offering constructor like creation of errors

	You normally call this method from within your static function of your custom error type.
	Have a look at the documentaion of the `LocalizedError` protocol to see how to create your
	own error types and how to use them in code.

	- Parameters:
		- code: Internal error code. Use "\(#function)" as default value to take the name of the function. All text is taken up to the first "(".
	  	- severity: One of the severity defined by `Severity`
	  	- title: A `Clause` that is displayed as the title. Defaults to `code`
		- recovery: A `Clause` that is displayed as the recovery suggestion. Defaults to nil which means no recovery suggestion is displayed.
	  	- failure: A `Clause` that is displayed as the failure reason which is the error-message. Defaults to nil which is no error message.
		- Returns: An instance of the concrete type that conforms `LocalizedError`
	*/
	static func Error(_ code: String, _ severity: Severity, cause: Error? = nil, title: Clause? = nil, recovery: Clause? = nil, _ failure: FailureText? = nil) -> Self {
		return self.init(ErrorSpecifics(code, severity, cause: cause, title: title, recovery: recovery, failure: failure))
	}

	/** Factory method for creating errors. See `Error(_:,_:,title:,recovery:,_:)` for a description.

	- Parameters:
		- code: Internal error code. Use "\(#function)" as default value to take the name of the function. All text is taken up to the first "(".
		- severity: One of the severity defined by `Severity`
		- title: A `Clause` that is displayed as the title. Defaults to `code`
		- recovery: A `Clause` that is displayed as the recovery suggestion. Defaults to nil which means no recovery suggestion is displayed.
		- failure: A `Clause` that is displayed as the failure reason which is the error-message. Defaults to nil which is no error message.
	- Returns: An instance of the concrete type that conforms `LocalizedError`
	*/
	static func makeError(_ code: String, _ severity: Severity, cause: Error? = nil, title: Clause? = nil, recovery: Clause? = nil, _ failure: FailureText? = nil) -> Self {
		return Error(code, severity, cause: cause, title: title, recovery: recovery, failure)
	}

	static func == (lhs: LocalizedError, rhs: Self) -> Bool {
		return lhs.specifics.code == rhs.specifics.code
	}
	static func != (lhs: LocalizedError, rhs: Self) -> Bool {
		return lhs.specifics.code != rhs.specifics.code
	}

	var code: String {
		return specifics.code
	}
	
	var severity: Severity {
		return specifics.severity
	}

	var cause: Error? {
		return specifics.cause
	}

	var errorDescription: String? {
		let errorString = specifics.title.localization(Self.tableName) { return $0 == self.specifics.code ? self.prefix : self.prefixedErrorCode }
		return errorString
	}

	var failureReason: String? {
		guard let failure = self.specifics.failure else { return nil }
		return failure.localization(Self.tableName) { _ in return self.failurePrefix.isEmpty ? "" : "\(self.prefixedErrorCode).\(self.failurePrefix)" }
	}

	var recoverySuggestion: String? {
		guard let recovery = self.specifics.recovery else { return nil }
		return recovery.localization(Self.tableName) { _ in return self.recoveryPrefix.isEmpty ? "" : "\(self.prefixedErrorCode).\(self.recoveryPrefix)" }
	}

	var prefix: String {
		return name(of: self)
	}

	var failurePrefix: String {
		return "failure"
	}

	var recoveryPrefix: String {
		return "recovery"
	}

	#if canImport(UIKit)
	func alertController(_ preferredStyle: UIAlertController.Style = .alert ) -> UIAlertController {
		var message = self.failureReason;
		if let cause = self.cause?.asLocalizedError?.failureReason ?? self.cause?.localizedDescription,
			cause.count > 0 {
			message = message?.count ?? 0 > 0 ? message! + "\n" + cause : cause
		}
		if let recoverySuggestion = recoverySuggestion,
			recoverySuggestion.count > 0 {
			message = message?.count ?? 0 > 0 ? message! + "\n" + recoverySuggestion : recoverySuggestion
		}
		let alertController = UIAlertController(title: errorDescription, message: message, preferredStyle: preferredStyle)
		return alertController
	}
	func presentOkAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style)
		alert.addAction(UIAlertAction(title: Clause("OK").localization(Self.tableName) { _ in return self.prefix }, style: .default, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
	func presentOkCancelAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style)
		alert.addAction(UIAlertAction(title: Clause("OK").localization(Self.tableName), style: .default, handler: completion))
		alert.addAction(UIAlertAction(title: Clause("Cancel").localization(Self.tableName) { _ in return self.prefix }, style: .cancel, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
	#elseif canImport(AppKit)
	var alert: NSAlert {
		let alert = NSAlert(error: self)
		severity.setStyleForAlert(alert)
		return alert
	}
	#endif

	private var prefixedErrorCode: String {
		return "\(prefix).\(self.specifics.code)"
	}
}

public extension LocalizedError {
	var description: String {
		return """
		\(errorDescription ?? prefixedErrorCode)\
		\(failureReason != nil ? " - \(failureReason!)" : "")\
		\(recoverySuggestion != nil ? " - \(recoverySuggestion!)" : "")\
		\(cause != nil ? " - \(cause!.asLocalizedError?.description ?? "")" : "")
		"""
	}
}

public typealias FTLocalizedError = Fehlerteufel.LocalizedError

/** Stores error specific details.

When creating an error, an instance of this type is used, to store all details.
The default implementation of the `LocalizedError` is using this instance for
retrieving and returning these details.
*/
public struct ErrorSpecifics {
	fileprivate let code: String
	fileprivate let severity: Severity
	fileprivate let cause: Error?
	fileprivate let title: Clause
	fileprivate let recovery: Clause?
	fileprivate let failure: Clause?

	/** Initialize a new instance of `ErrorSpecifics`

	 - Parameters:
	   	- code: The code this error should get. Text is taken up to the first, but not including "("
	   	- severity: The severity of the error
		- cause: The `Error` that caused this error or nil if there's no causing error
	   	- title: The `errorDescription`. If nil, `code` is taken
	   	- recovery: The `recoverySuggestion`
	   	- failure: The `failureReason`
	*/
	init(_ code: String, _ severity: Severity, cause: Error? = nil, title: Clause? = nil, recovery: Clause? = nil, failure: FailureText? = nil) {
		var code = code
		if let endIndex = code.firstIndex(of: "(") {
			code = String(code[..<endIndex])
		}
		self.code = code
		self.severity = severity
		self.cause = cause
		self.title = title ?? Clause(stringLiteral: code)
		self.recovery = recovery
		self.failure = failure?()
	}
}

/// Extracts the type name outof instances of Reference- and Value-Types.
///
/// - Parameter instance: Instance to extract the type name from
/// - Returns: String containing the name of the instance type
func name<T: Any>(of instance: T) -> String {
	return String(describing: type(of: instance)).replacingOccurrences(of: ".Type", with: "")
}

extension Error {
	/// Returns this `Error` as a `LocalizedError`
	/// If casting is impossible, it logs the error and returns nil
	var asLocalizedError: LocalizedError? {
		guard let localizedError = self as? LocalizedError else {
			print("Non localized error: \(self)")
			return nil
		}
		return localizedError
	}

	static func == (lhs: Error, rhs: LocalizedError) -> Bool {
		guard let lhs = lhs as? LocalizedError else { return false }
		return lhs.specifics.code == rhs.specifics.code
	}
}
