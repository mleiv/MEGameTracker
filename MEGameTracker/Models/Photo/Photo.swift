//
//  Photo.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit
import Nuke

/// Stores details about photo for an object, whether it is default url or custom local image.
public struct Photo {

// MARK: Properties

	internal var filePath: String
	internal var isCustomSavedPhoto: Bool = true

// MARK: Computed Properties

	public var stringValue: String {
		return filePath
	}

// MARK: Initialization

	public init?(filePath: String?) {
		if let filePath = filePath {
			self.filePath = filePath
			isCustomSavedPhoto = !NSPredicate(format:"SELF MATCHES %@", "http:.*").evaluate(with: filePath)
		} else {
			return nil
		}
	}
}

// MARK: Basic Actions
extension Photo {

	/// Save a new photo to a file identified by the object specified, using the image passed.
	public static func create(_ image: UIImage, object: Photographical) -> Photo? {
		let filePath = object.photoFileNameIdentifier
		if let url = Photo.getUrl(filePath: filePath, isCustomSavedPhoto: true),
			let imageData = UIImagePNGRepresentation(image) {
			do {
				try imageData.write(to: url, options: [.atomic])
				return Photo(filePath: filePath)
			} catch {}
		}
		return nil
	}

	/// Assigns the Photographical's photo to the UIImageView in question.
	/// (We always want to set the placeholder, so this is a static that still runs if source/photo is nil)
	public static func addPhoto(from source: Photographical?, toView view: UIImageView?, placeholder: UIImage?) {
		guard let view = view else { return }
		view.image = nil
		if let photo = source?.photo, let url = photo.getUrl() {
			Nuke.loadImage(with: url, into: view)
			DispatchQueue.main.async {
				if placeholder != nil && view.image == nil {
					view.image = placeholder
				}
			}
		} else {
			DispatchQueue.main.async {
				view.image = placeholder
			}
		}
	}

	/// Optional - invoke when photo view disappears from screen and this will cancel any pending requests
	public static func cancelPhoto(inView view: UIImageView?) {
		guard let view = view else { return }
		Nuke.cancelRequest(for: view)
	}

	/// Get a URL for the specified file path (local or remote).
	private static func getUrl(filePath: String, isCustomSavedPhoto: Bool = false) -> URL? {
		if isCustomSavedPhoto {
			let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) as [URL]
			if let documentsFilePath = documentsDirectories.first?.appendingPathComponent(filePath).path {
				return URL(fileURLWithPath: documentsFilePath)
			}
		} else {
			return URL(string: filePath)
		}
		return nil
	}

	/// Get a URL for this photo (local or remote).
	public func getUrl() -> URL? {
		return Photo.getUrl(filePath: filePath, isCustomSavedPhoto: isCustomSavedPhoto)
	}

	/// Delete this photo's custom file from local storage.
	public func delete() -> Bool {
		guard isCustomSavedPhoto else { return true }
		// don't need to explicitly delete on new photo because any new overwrites previous
		let fileManager = FileManager.default
		if let url = Photo.getUrl(filePath: filePath, isCustomSavedPhoto: true) {
			do {
				try fileManager.removeItem(atPath: url.absoluteString)
				return true
			} catch {}
		}
		return false
	}
}

extension Photo: Equatable {
	static public func == (lhs: Photo, rhs: Photo) -> Bool {
		return lhs.filePath == rhs.filePath
	}
}

// MARK: Save/Retrieve Data

extension Photo {

	public func getData() -> SerializableData {
		return filePath.getData()
	}

}
