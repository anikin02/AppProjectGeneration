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
      
      HStack {
        
        Spacer()
        
        Slider(value: $viewModel.diagramScale, in: 0.1...4,
               minimumValueLabel: Image(systemName: "minus.magnifyingglass"), maximumValueLabel: Image(systemName: "plus.magnifyingglass")) {
          Text("Изменить масштаб диаграммы")
        }
               .frame(maxWidth: 500)
               .padding(.horizontal, 10)
        
        Button() {
          viewModel.resetDiagramScale()
        } label: {
          Text("Венуть изначальный масштаб")
        }
        .buttonStyle(.accessoryBarAction)
        
        themesMenu()
        
        Spacer()
      }
      .padding(10)
      
      ScrollView([.horizontal, .vertical]) {
        if let image = image {
          Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 700 * viewModel.diagramScale)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: 600)
      
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
      
      
    }
    .onAppear() {
      createImage(theme: .default)
    }
  }
  
  private func themesMenu() -> some View {
    Menu("Внешний вид диаграммы") {
      Button() {
        createImage(theme: .default)
      } label: {
        Text("Стандартный")
      }
      
      Button() {
        createImage(theme: .githubLight)
      } label: {
        Text("GitHub Light")
      }
      
      Button() {
        createImage(theme: .githubDark)
      } label: {
        Text("GitHub Dark")
      }
      
      Button() {
        createImage(theme: .tokyoNightLight)
      } label: {
        Text("Tokyo Light")
      }
      
      Button() {
        createImage(theme: .tokyoNight)
      } label: {
        Text("Tokyo Night")
      }
    }
  }
  
  
  // MARK: Image
  private func createImage(theme: DiagramTheme) {
    DispatchQueue.main.async {
      do {
        image = try MermaidRenderer.renderImage(source: viewModel.mermaidCode, theme: theme)
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
