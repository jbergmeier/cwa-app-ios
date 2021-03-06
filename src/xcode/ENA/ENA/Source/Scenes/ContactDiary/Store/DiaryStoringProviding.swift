////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

typealias DiaryStoringProviding = DiaryStoring & DiaryProviding

enum DiaryStoringError: Error {
	case database(SQLiteErrorCode)
	case timeout
}

protocol DiaryStoring {

	typealias DiaryStoringResult = Result<Int, DiaryStoringError>
	typealias DiaryStoringVoidResult = Result<Void, DiaryStoringError>

	@discardableResult
	func addContactPerson(name: String) -> DiaryStoringResult
	@discardableResult
	func addLocation(name: String) -> DiaryStoringResult
	@discardableResult
	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult
	@discardableResult
	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult

	@discardableResult
	func updateContactPerson(id: Int, name: String) -> DiaryStoringVoidResult
	@discardableResult
	func updateLocation(id: Int, name: String) -> DiaryStoringVoidResult

	@discardableResult
	func removeContactPerson(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeLocation(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeContactPersonEncounter(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeLocationVisit(id: Int) -> DiaryStoringVoidResult
	@discardableResult
	func removeAllLocations() -> DiaryStoringVoidResult
	@discardableResult
	func removeAllContactPersons() -> DiaryStoringVoidResult
	@discardableResult
	func cleanup() -> DiaryStoringVoidResult
	@discardableResult
	func cleanup(timeout: TimeInterval) -> DiaryStoringVoidResult
	@discardableResult
	func reset() -> DiaryStoringVoidResult
	func close()
}

protocol DiaryProviding {

	var dataRetentionPeriodInDays: Int { get }
	var userVisiblePeriodInDays: Int { get }
	var diaryDaysPublisher: OpenCombine.CurrentValueSubject<[DiaryDay], Never> { get }

	func export() -> Result<String, SQLiteErrorCode>
	
}

/**
This extension provides a default implementation for the properties.
So we make sure to not declare the properties in any other implementations of this protocol, expecially in the unit tests. So the values are always the same.
*/

extension DiaryProviding {

	var dataRetentionPeriodInDays: Int { 17 } // Including today.
	var userVisiblePeriodInDays: Int { 15 } // Including today.
}
