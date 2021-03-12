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
@_exported import Clause

/**
Error-Type with severity, localization support and position independent
parameter/value substitution.

All text used for description, failure-reason and recovery suggestion, constructed using
a `Clause`, which in turn uses Swift 5 `ExpressibleByStringInterpolation` protocol, to make it
possible to specify parameter values directly within the string literal.

Like so:
```
let path = "/data"
let name = "VeryImportantData"
let error: MyError = .fileError { "File \("name:", name) not found at path \("path:", path)." }
```
This creates an instance of `MyError` with `name` and `errorDescription` of
"fileError" and a `failureReason`: "File VeryImportantData not found at path /data."

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
Now, when your language is set to german, you get "Datei Fehler" for the `errorDescription`.
For the `failureReason` you get "Unter “/data” konnte die Datei “VeryImportantData” nicht gefunden werden.".

This is also a great example to show parameter position independency. The original
`failureReason` put the `name` in front of the `path`. In the transalation `path` is used first.

__Note:__ If you don't specify an `errorDescription` explicitly the `name` is taken.

To create your own error type, only a few lines of code are needed.

```
struct MyError: LocalizedError {
	// All localizations are retrived from a file called "MyErrors.strings"
	// If you dont specify this, all localizations a taken from "Localizable.string"
	static var baseStringsFileName: String { return "MyErrors" }

	// Required to fulfill protocol conformance
	let store: ErrorStoring

	static func fileError(description: Clause? = nil, failure: FailureText? = nil) -> MyError {
		return Error(name: #function, severity: .warning, failure: failure)
	}
}
```
If you want your error to have a code, a different title, recovery suggection, and a causing error just add the desired parameters to your static function
and call the `Error()` method with the appropriate parameters like shown in the next example which is an extension to the `MyError` created above:
```
extension MyError {
	static func invalidData(cause: Error, failure: FailureText? = nil) -> MyError {
		return Error(name: #function, code: 102, severity: .error, title: "Invalid Data", cause: cause, recovery: "Please try again", failure: failure)
	}
}
```
To add more, just copy&paste the static function and rename it to whatever name you want your error to have. Don't forget to adjust the severity to your needs.
The easiest usage of the `fileError` from the first example is
```
let error = MyError.fileError()
```
This creates a `MyError` with `name` "fileError" with a severity of `.warning`, no `code` and `errorDescription` set to "fileError".
```
let name = "Customer"
let error = MyError.fileError(description: "File Error Occurred") { "File “\("name:", name)” was not found." }
```
This creates a `MyError` with name "fileError", with a severity `.warning`, no `code`, `errorDescription` set to "File Error Occurred"
and `failureReason` set to "File “Customer” was not found".
To specify localizations, just add "MyErrors.string" files to the appropriate .lproj-directories or let Xcode doing it for you.

If you want to localize the error title while `name` and `description` are the same (which is the default)
just add the following line to the localization file:
```
"MyError.fileError" = "File Error";
```
If you specify a description explicitly, like in the example above, the localization should look like:
```
"MyError.fileError.File Error Occured" = "Occurence of file error";
```
*/
public protocol LocalizedError: Foundation.LocalizedError, CustomStringConvertible, LocalizationMetadataProviding {

	typealias ErrorAction = (LocalizedError) -> Void
	
	/// Store for error details.
	///
	/// This has to be provided by the concrete error type
	///
	/// __Required.__
	var store: ErrorStoring { get }

	/// Initializes the instance with the details of the error
	///
	/// This is automatically provided by the concrete error type
	/// because of the required `store` property
	///
	/// __Required.__ Implementation provided automatically
	init(store: ErrorStoring)

	/// A unique `name` for this error.
	///
	/// The `name` uniquely identifies the error and is used to search
	/// for the localizations in the strings file.
	///
	/// __Required.__ Default implementation provided
	var name: String { get }

	/// The code of this error or  nil, if this error has no code
	///
	/// __Required.__ Default implementation provided
	var code: Int? { get }

	/// The severity of this error or nil, if no severity was given
	///
	/// __Required.__ Default implementation provided
	var severity: Severity? { get }

	/// Contains the `Error` that caused this error or nil
	///
	/// __Required.__ Default implementation provided
	var cause: Error? { get }

	/** This prefix is prepended to keys when retrieving the localized string
	for the error description from a .strings-file.

	Defaults to the name of the concrete type. If you i.e. declare a type
	`MyError: LocalizedError` with `name` "fileNotFound", the resulting key for
	accessing the strings file will be "MyError.fileNotFound"

	If you want a different prefix or no prefix at all just overwrite this
	in your error type and	return the desired string.

	__Required.__ Default implementation provided
	*/
	var prefix: String { get }

	
	/** This prefix is prepended to keys when retrieving the localized string
	for the failure reason from a .strings-file.

	Defaults to "failure"

	If you i.e. declare a type `MyError: LocalizedError` with `name` "fileNotFound",
	the resulting key for accessing the failure reason in the strings file
	will be "MyError.fileNotFound.failure"

	If you want a different prefix or no prefix at all just overwrite this
	in your error type and	return the desired string.

	__Required.__ Default implementation provided
	*/
	var failurePrefix: String { get }

	
	/** This prefix is prepended to keys when retrieving the localized string
	for the reovery suggestion from a .strings-file.

	Defaults to "recovery"

	If you i.e. declare a type `MyError: LocalizedError` with `name` "fileNotFound",
	the resulting key for accessing the recovery suggestion in the strings file
	will be "MyError.fileNotFound.recovery"

	If you want a different prefix or no prefix at all just overwrite this
	in your error type and	return the desired string.

	__Required.__ Default implementation provided
	*/
	var recoveryPrefix: String { get }
}

/// Typealias for `Fehlerteufel.LocalizedError` to remove ambiguity with `Foundation.LocalizedError`
public typealias FTLocalizedError = Fehlerteufel.LocalizedError

// Default implementation for basic error-values
public extension LocalizedError {

	var name: String {
		return (store as! ErrorStore).name //errorStore.name
	}
	var code: Int? {
		return errorStore.code
	}
	
	var severity: Severity? {
		return errorStore.severity
	}

	var cause: Error? {
		return errorStore.cause
	}

	var errorDescription: String? {
		let errorString = errorStore.description.localized(Self.stringsFileName, bundle: Self.bundle) { return $0 == self.errorStore.name ? self.prefix : self.namePrefix }
		return errorString
	}

	var failureReason: String? {
		guard let failure = self.errorStore.failure else { return nil }
		return failure.localized(Self.stringsFileName, bundle: Self.bundle) { _ in return self.failurePrefix.isEmpty ? "" : "\(self.namePrefix).\(self.failurePrefix)" }
	}

	var recoverySuggestion: String? {
		guard let recovery = self.errorStore.recovery else { return nil }
		return recovery.localized(Self.stringsFileName, bundle: Self.bundle) { _ in return self.recoveryPrefix.isEmpty ? "" : "\(self.namePrefix).\(self.recoveryPrefix)" }
	}
}

/// Type that returns the `Clause` that is used as the failure text of the error
public typealias FailureText = () -> Clause

// Extension for `LocalizedError` creation
public extension LocalizedError {
	/** Factory method offering constructor like creation of errors

	You normally call this method from within your static function of your custom error type.
	Have a look at the documentaion of the `LocalizedError` protocol to see how to create your
	own error types and how to use them in code.

	- Parameters:
		- name: A `String` that is used as the unique name. Use #function as default value to take the name of the function. All text is taken up to the first "(".
		- code: Optional code (number) of this error.
		- severity: Optional severity of the error. See `Severity` type
		- description: An optional `Clause` that is used as the description. If not specified, the value of `name` is taken
		- cause: An optional `Error` that caused this error
		- recovery: An optional `Clause` that is displayed as the recovery suggestion. Defaults to nil which means no recovery suggestion is displayed.
		- failure: Optional closure returning a `Clause` which is displayed as the failure reason aka error-message. Defaults to nil which is no error message.
	- Returns: An instance of the concrete type that conforms `LocalizedError`
	*/
	static func Error(
		name: String,
		code: Int? = nil,
		severity: Severity? = nil,
		description: Clause? = nil,
		cause: Error? = nil,
		recovery: Clause? = nil,
		failure: FailureText? = nil
	) -> Self
	{
		return ErrorStore.makeError(name: name, code: code, severity: severity, description: description, cause: cause, recovery: recovery, failure: failure)
	}

	/** Factory method for creating errors. See `Error(name:,code:,severity:,description:,cause:,recovery:,failure:)` for a description.

	- Parameters:
		- name: A `String` that is used as the unique name. Use #function as default value to take the name of the function. All text is taken up to the first "(".
		- code: Optional code (number) of this error.
		- severity: Optional severity of the error. See `Severity` type
		- description: An optional `Clause` that is used as the description. If not specified, the value of `name` is taken
		- cause: An optional `Error` that caused this error
		- recovery: An optional `Clause` that is displayed as the recovery suggestion. Defaults to nil which means no recovery suggestion is displayed.
		- failure: Optional closure returning a `Clause` which is displayed as the failure reason aka error-message. Defaults to nil which is no error message.
	- Returns: An instance of the concrete type that conforms `LocalizedError`
	*/
	static func makeError(
		name: String,
		code: Int? = nil,
		severity: Severity? = nil,
		description: Clause? = nil,
		cause: Error? = nil,
		recovery: Clause? = nil,
		failure: FailureText? = nil
	) -> Self
	{
		return Error(name: name, code: code, severity: severity, description: description, cause: cause, recovery: recovery, failure: failure)
	}
}

// Default implementation for prefixes
public extension LocalizedError {
	var prefix: String {
		return typeName(of: self)
	}

	var failurePrefix: String {
		return "failure"
	}

	var recoveryPrefix: String {
		return "recovery"
	}

	private var namePrefix: String {
		return "\(prefix).\(self.errorStore.name)"
	}
}

// Extension for comparing `LocalizedError`s
public extension LocalizedError {
	/// Returns true, if the `name` property of both errors are the same. Otherwise false.
	static func == (lhs: LocalizedError, rhs: Self) -> Bool {
		return lhs.errorStore.name == rhs.errorStore.name
	}
	/// Returns true, if the `name` property of both errors are not the same. Otherwise false.
	static func != (lhs: LocalizedError, rhs: Self) -> Bool {
		return lhs.errorStore.name != rhs.errorStore.name
	}
}

// Default implementation for `CustomStringConvertible`
public extension LocalizedError {
	var description: String {
		return """
		\(errorDescription ?? namePrefix)\
		\(failureReason.map { " \($0)" } ?? "")\
		\(recoverySuggestion.map { " \($0)" } ?? "")\
		\(cause != nil ? " - \(cause!.asLocalizedError?.description ?? "")" : "")
		"""
	}
}

// Extension for shortDescription
public extension LocalizedError {

	/// Same as `description` but without the causing error(s)
	var shortDescription: String {
		return """
		\(errorDescription ?? namePrefix)\
		\(failureReason.map { " \($0)" } ?? "")\
		\(recoverySuggestion.map { " \($0)" } ?? "")
		"""
	}
}

public extension Error {
	/// Returns this `Error` as a `LocalizedError`
	/// If casting is impossible, it logs the error and returns nil
	var asLocalizedError: FTLocalizedError? {
		guard let localizedError = self as? FTLocalizedError else {
			print("Non localized error: \(self)")
			return nil
		}
		return localizedError
	}

	static func == (lhs: Error, rhs: FTLocalizedError) -> Bool {
		guard let lhs = lhs as? FTLocalizedError else { return false }
		return lhs.errorStore.code == rhs.errorStore.code
	}
}

// Convenience methods for iOS
#if canImport(UIKit)
public extension LocalizedError {
	/**
	A `UIAlertController` with `title` initialized to the localized description
	and `message` set to the localized failure text of this error.

	__Required.__ Default implementation provided

	- Parameters:
		- preferredStyle: The default `preferredStyle` is set to `.alert`
		- withCause: true, takes text of causing errors into account, false doesn't. Default is true
	- Returns: UIAlertController
	*/
	func alertController(_ preferredStyle: UIAlertController.Style = .alert, withCause: Bool = true) -> UIAlertController {
		var message = self.failureReason;
		if withCause,
		   let cause = self.cause?.asLocalizedError?.failureReason ?? self.cause?.localizedDescription,
		   !cause.isEmpty {
			message = message?.count ?? 0 > 0 ? message! + "\n" + cause : cause
		}
		if let recoverySuggestion = recoverySuggestion,
			recoverySuggestion.count > 0 {
			message = message?.count ?? 0 > 0 ? message! + "\n" + recoverySuggestion : recoverySuggestion
		}
		let alertController = UIAlertController(title: errorDescription, message: message, preferredStyle: preferredStyle)
		return alertController
	}

	/** Presents this `LocalizedError` as an `UIAlertController` together with an
	OK `UIAlertAction` Button

	__Required.__ Default implementation provided

	- Parameters:
		- viewController: The `UIViewController` used as the presenting view controller
		- style: `UIAlertController` style. Defaults to .alert
		- withCause: true, takes text of causing errors into account, false doesn't. Default is true
		- completion: If given, it gets called when the OK action was selected
	*/
	func presentOkAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, withCause: Bool = true, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style, withCause: withCause)
		alert.addAction(UIAlertAction(title: Clause("OK").localized(Self.stringsFileName, bundle: Self.bundle) { _ in return self.prefix }, style: .default, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
	/** Presents this `LocalizedError` as an `UIAlertController` together with
	OK and Cancel `UIAlertAction` Buttons.

	__Required.__ Default implementation provided

	- Parameters:
		- viewController: The `UIViewController` used as the presenting view controller
		- style: `UIAlert*Controller` style. Defaults to .alert
		- withCause: true, takes text of causing errors into account, false doesn't. Default is true
		- completion: If given, it gets called when the OK or Cancel action was selected
	*/
	func presentOkCancelAlert(_ viewController: UIViewController, as style: UIAlertController.Style = .alert, withCause: Bool = true, completion: ((UIAlertAction) -> Void)? = nil) {
		let alert = self.alertController(style, withCause: withCause)
		alert.addAction(UIAlertAction(title: Clause("OK").localized(Self.stringsFileName, bundle: Self.bundle), style: .default, handler: completion))
		alert.addAction(UIAlertAction(title: Clause("Cancel").localized(Self.stringsFileName, bundle: Self.bundle) { _ in return self.prefix }, style: .cancel, handler: completion))
		viewController.present(alert, animated: true, completion: nil)
	}
}
#endif

// Convenience methods for macOS
#if canImport(AppKit)
public extension LocalizedError {
	/// A `NSAlert` initialized with this error
	/// __Required.__ Default implementation provided
	var alert: NSAlert {
		let alert = NSAlert(error: self)
		if let severity = severity {
			severity.setStyleForAlert(alert)
		}
		return alert
	}
}
#endif

// MARK: - Error Storing

public protocol ErrorStoring {}

fileprivate extension ErrorStoring where Self == ErrorStore {
	var name: String { name }
	var code: Int? { code }
	var severity: Severity? { severity }
	var description: Clause { description }
	var cause: Error? { cause }
	var recovery: Clause? { recovery }
	var failure: Clause? { failure }
}

private extension LocalizedError {
	var errorStore: ErrorStore {
		return store as! ErrorStore
	}
}
/** Stores error specific details.

When creating an error, an instance of this type is used, to store all details.
The default implementation of the `LocalizedError` is using this instance for
retrieving and returning these details.
*/
private struct ErrorStore: ErrorStoring {
	fileprivate let name: String
	fileprivate let code: Int?
	fileprivate let severity: Severity?
	fileprivate let description: Clause
	fileprivate let cause: Error?
	fileprivate let recovery: Clause?
	fileprivate let failure: Clause?

	fileprivate static func makeError<T: LocalizedError>(
		name: String,
		code: Int? = nil,
		severity: Severity? = nil,
		description: Clause? = nil,
		cause: Error? = nil,
		recovery: Clause? = nil,
		failure: FailureText? = nil
	) -> T
	{
		return T(store: Self(name: name, code: code, severity: severity, description: description, cause: cause, recovery: recovery, failure: failure))
	}

	/** Initialize a new instance of `ErrorSpecifics`

	 - Parameters:
		- name: The unique name. Text is taken up to the first, but not including "("
	   	- code: The code this error should get
	   	- severity: The severity of the error
	   	- description: The `errorDescription`. If nil, `name` is taken
		- cause: The `Error` that caused this error or nil if there's no causing error
	   	- recovery: The `recoverySuggestion`
	   	- failure: The `failureReason`
	*/
	private init(name: String, code: Int? =  nil, severity: Severity? = nil, description: Clause? = nil, cause: Error? = nil, recovery: Clause? = nil, failure: FailureText? = nil) {
		let name = String(name[..<(name.firstIndex(of: "(") ?? name.endIndex)])
		self.name = name
		self.code = code
		self.severity = severity
		self.description = description ?? Clause(stringLiteral: name)
		self.cause = cause
		self.recovery = recovery
		self.failure = failure?()
	}
}

/// Extracts the type name outof instances of Reference- and Value-Types.
///
/// - Parameter instance: Instance to extract the type name from
/// - Returns: String containing the name of the instance type
fileprivate func typeName<T: Any>(of instance: T) -> String {
	return String(describing: type(of: instance)).replacingOccurrences(of: ".Type", with: "")
}
