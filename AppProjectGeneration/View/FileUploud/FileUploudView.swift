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
      
      NavigationLink(destination: ResultView() {
        if let _ = droppedFileName {
          Text("Сгенерировать проект")
            .foregroundStyle(.gray)
            .font(.system(size: 14, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .cornerRadius(8)
        } else {
          Text("Ожидание файла...")
            .foregroundStyle(.gray)
            .font(.system(size: 14, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .cornerRadius(8)
        }
      }
      
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
    for provider in providers {
      if provider.hasItemConformingToTypeIdentifier(UTType.rtf.identifier) {
        provider.loadItem(forTypeIdentifier: UTType.rtf.identifier, options: nil) { item, error in
          DispatchQueue.main.async {
            if let url = item as? URL {
              self.droppedFileName = url.lastPathComponent
              switchDragAndDropView()
            }
          }
        }
        return true
      }
      
    }
    return false
  }
  
}

#Preview {
  FileUploudView()
}


