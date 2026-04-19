//
//  NSItemProvider.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 19/04/2026.
//

import Foundation

extension NSItemProvider {
  func loadFileRepresentationAsync(
    forTypeIdentifier typeIdentifier: String
  ) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      self.loadFileRepresentation(
        forTypeIdentifier: typeIdentifier
      ) { url, error in
        if let error {
          continuation.resume(throwing: error)
        } else if let url {
          continuation.resume(returning: url)
        } else {
          continuation.resume(
            throwing: NSError(
              domain: "FileLoad",
              code: -1,
              userInfo: [NSLocalizedDescriptionKey: "URL is nil"]
            )
          )
        }
      }
    }
  }
}
