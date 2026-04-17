//
//  FileUploudView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 28/09/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileUploudView: View {
  @State private var dropImage = Image(systemName: "square.and.arrow.down")
  @State private var droppedFileName: String? = nil
  @State private var isTargeted: Bool = false
  @State private var droppedFileContent: String?
  @State private var navigateToResult = false
  @State private var parsedObjects: [AppObject] = []
  @State private var parseError: String? = nil
  @State private var pendingDrop: (name: String, content: String)?
  private var resultView = ResultView()
  
  var body: some View {
    VStack(alignment: .center) {
      HStack {
        Spacer()
        NavigationLink(destination: ApplicationHelpView()) {
          Text("Справка")
            .font(.system(size: 23, weight: .black))
            .foregroundStyle(.accent)
            .underline()
        }
        .buttonStyle(.plain)
      }
      .padding(20)
      
      Spacer()
      
      VStack(spacing: 20) {
        RoundedRectangle(cornerRadius: 12)
          .stroke(isTargeted ? Color.accentColor : Color.gray, style: StrokeStyle(lineWidth: 3, dash: [10]))
          .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
          .frame(height: 200)
          .overlay(
            VStack(spacing: 10) {
              dropImage
                .font(.system(size: 50))
                .foregroundStyle(.accent)
              Text("Перетащите файл сюда")
                .font(.headline)
              if let fileName = droppedFileName {
                Text("Файл: \(fileName)")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
          )
          .onDrop(of: [UTType.rtf], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
          }
      }
      .padding(40)
      
      Button {
        guard let droppedFileContent else { return }
        
        let objects = Parser.shared.parseAppObjects(from: droppedFileContent)
        if objects.isEmpty {
          parseError = "Файл не содержит объектов"
          return
        }
        parsedObjects = objects
        resultView.viewModel.project.objects = parsedObjects
        parseError = nil
        navigateToResult = true
        
      } label: {
        Text(droppedFileName != nil ? "Сгенерировать проект" : "Ожидание файла...")
          .foregroundStyle(.gray)
          .font(.system(size: 14, weight: .black))
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
      }
      .navigationDestination(isPresented: $navigateToResult) {
        resultView
      }
      .disabled(droppedFileName == nil)
      
      if let _ = droppedFileName {
        Button {
          cancelUploud()
        } label: {
          Text("Отмена")
            .foregroundStyle(.black)
            .font(.system(size: 14, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.red)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
      }
      
      
      Spacer()
    }
  }
  
  private func cancelUploud() {
    switchDragAndDropView()
    droppedFileName = nil
  }
  
  private func switchDragAndDropView() {
    if self.dropImage == Image(systemName: "square.and.arrow.down") {
      self.dropImage = Image(systemName: "checkmark.circle.fill")
    } else {
      self.dropImage = Image(systemName: "square.and.arrow.down")
    }
  }
  
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
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
}

#Preview {
  FileUploudView()
}


