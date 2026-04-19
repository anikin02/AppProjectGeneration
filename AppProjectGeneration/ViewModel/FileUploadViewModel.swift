//
//  FileUploadViewModel.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 18/04/2026.
//

import Combine
import UniformTypeIdentifiers

@MainActor
final class FileUploadViewModel: ObservableObject {
  @Published var isTargeted: Bool = false
  @Published var droppedFileName: String? = nil
  @Published var droppedFileContent: String? = nil
  @Published var navigateToResult = false
  @Published var dropImageName: String = "square.and.arrow.down"
  @Published var errorMessage: String? = nil
  
  private var parsedObjects: [AppObject] = []
  
  func parseButton() {
    guard let value = droppedFileContent else { return }
    
    let objects = Parser.shared.parseAppObjects(from: value)
    if objects.isEmpty {
      errorMessage = "Файл не содержит объектов"
      return
    }
    
    parsedObjects = objects
    errorMessage = nil
    navigateToResult = true
  }
  
  func cancelUploud() {
    switchDragAndDropView()
    droppedFileName = nil
  }
  
  func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first(where: {
      $0.hasItemConformingToTypeIdentifier(UTType.rtf.identifier)
    }) else { return false }
    
    Task {
      do {
        try await loadRTF(from: provider)
      } catch {
        await MainActor.run {
          self.errorMessage = error.localizedDescription
        }
      }
    }
    
    return true
  }
  
  nonisolated private func loadRTF(from provider: NSItemProvider) async throws {
    let url = try await provider.loadFileRepresentationAsync(
      forTypeIdentifier: UTType.rtf.identifier
    )
    
    let data = try Data(contentsOf: url)
    
    guard let attributedString = try? NSAttributedString(
      data: data,
      options: [.documentType: NSAttributedString.DocumentType.rtf],
      documentAttributes: nil
    ) else {
      throw NSError(domain: "RTFParse", code: -1)
    }
    let fileName = url.lastPathComponent
    let plainText = attributedString.string
    
    await MainActor.run {
      self.droppedFileName = fileName
      self.droppedFileContent = plainText
      self.switchDragAndDropView()
    }
  }
  
  private func switchDragAndDropView() {
    if dropImageName == "square.and.arrow.down" {
      dropImageName = "checkmark.circle.fill"
    } else {
      dropImageName = "square.and.arrow.down"
    }
  }
}


