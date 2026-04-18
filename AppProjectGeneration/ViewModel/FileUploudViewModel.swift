//
//  FileUploudViewModel.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 18/04/2026.
//

import Combine
import UniformTypeIdentifiers

class FileUploudViewModel: ObservableObject {
  @Published var droppedFileName: String? = nil
  @Published var isTargeted: Bool = false
  @Published var droppedFileContent: String? = nil
  @Published var navigateToResult = false
  @Published var parsedObjects: [AppObject] = []
  @Published var parseError: String? = nil
  @Published var pendingDrop: (name: String, content: String)?
  @Published var dropImageName: String = "square.and.arrow.down"
  
  func parseButton() {
    guard let value = droppedFileContent else { return }
    
    let objects = Parser.shared.parseAppObjects(from: value)
    if objects.isEmpty {
      parseError = "Файл не содержит объектов"
      return
    }
    
    parsedObjects = objects
    parseError = nil
    navigateToResult = true
  }
  
  func cancelUploud() {
    switchDragAndDropView()
    droppedFileName = nil
  }
  
  func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }
    
    if provider.hasItemConformingToTypeIdentifier(UTType.rtf.identifier) {
      
      provider.loadFileRepresentation(forTypeIdentifier: UTType.rtf.identifier) { url, error in
        if let error = error {
          print("Error: \(error)")
          return
        }
        
        guard let url else { return }
        
        do {
          let data = try Data(contentsOf: url)
          
          if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
          ) {
            DispatchQueue.main.async {
              self.droppedFileName = url.lastPathComponent
              self.droppedFileContent = attributedString.string
              self.switchDragAndDropView()
            }
          }
        } catch {
          print("Read error: \(error)")
        }
      }
      
      return true
    }
    
    return false
  }
  
  private func switchDragAndDropView() {
    if dropImageName == "square.and.arrow.down" {
      dropImageName = "checkmark.circle.fill"
    } else {
      dropImageName = "square.and.arrow.down"
    }
  }
}
