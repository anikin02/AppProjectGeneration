//
//  ResultView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 04/03/2026.
//

import SwiftUI
import BeautifulMermaid

struct ResultView: View {
  @SwiftUI.State var image: NSImage? = nil
  @ObservedObject var viewModel = ResultViewModel()
  
  var body: some View {
    VStack {
      ScrollView([.horizontal, .vertical]) {
        if let image = image {
          Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 800)
        }
      }
      HStack {
        if let image = image {
          Button() {
            saveImageToDesktop(image: image, fileName: "String")
          } label: {
            Text("Сохранить диаграмму")
          }
        }
      }
      
      Spacer()
      
      VStack {
        
      }
    }
    .onAppear() {
      do {
        image = try MermaidRenderer.renderImage(source: viewModel.mermaidCode)
      } catch {
        print("Ошибка: \(error)")
      }
    }
  }
  
  private func saveImageToDesktop(image: NSImage, fileName: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData) else { return }
    
    let pngData = bitmapImage.representation(using: .png, properties: [:])
    
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.png]
    savePanel.begin { result in
      if result == .OK, let url = savePanel.url {
        do {
          try pngData?.write(to: url)
          print("Изображение сохранено: \(url)")
        } catch {
          print("Ошибка сохранения: \(error)")
        }
      }
    }
  }
}

#Preview {
  ResultView()
}
