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
  @Published var errorMessage: String = ""
  @Published var showError: Bool = false
  
  @Published var isLoading: Bool = false
  
  @Published var parsedObjects: [AppObject] = []
  @Published var parsedRequirements: [String] = []
  
  func parseButton() {
    guard let value = droppedFileContent else { return }
    isLoading = true
    
    let objects = Parser.shared.parseAppObjects(from: value)
    let requirements = Parser.shared.parseRequirements(from: value)
    
    if objects.isEmpty {
      errorMessage = "Файл не содержит объектов"
      showError = true
      isLoading = false
      return
    }
    
    if requirements.isEmpty {
      errorMessage = "Файл не содержит требований"
      showError = true
      isLoading = false
      return
    }
    
    parsedObjects = objects
    parsedRequirements = requirements
    navigateToResult = true
    isLoading = false
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


