//
//  ResultView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 04/03/2026.
//

import SwiftUI
import BeautifulMermaid


class TestData {
  var user: AppObject
  var system: AppObject
  var bill: AppObject
  var transaction: AppObject
  var user1: AppObject
  var system1: AppObject
  var bill1: AppObject
  var transaction1: AppObject
  
  init() {
    bill = AppObject(name: "Bill", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "money", typeOfData: "Double", appObject: nil)])
    
    user = AppObject(name: "User", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "age", typeOfData: "Integer", appObject: nil),
      Argument(name: "bill", typeOfData: "", appObject: bill)])
    
    system = AppObject(name: "System", arguments: [
      Argument(name: "users", typeOfData: "Array", appObject: user)])
    
    transaction = AppObject(name: "Transaction", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user),
      Argument(name: "userTo", typeOfData: "", appObject: user)])
    
    bill1 = AppObject(name: "Bill1", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "money", typeOfData: "Double", appObject: nil)])
    
    user1 = AppObject(name: "User1", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "age", typeOfData: "Integer", appObject: nil),
      Argument(name: "bill1", typeOfData: "", appObject: bill1)])
    
    system1 = AppObject(name: "System1", arguments: [
      Argument(name: "users", typeOfData: "Array", appObject: user1)])
    
    transaction1 = AppObject(name: "Transaction1", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user1),
      Argument(name: "userTo", typeOfData: "", appObject: user1)])
    
  }
}

struct MermaidViewRepresentable: NSViewRepresentable {
  var source: String
  var theme: DiagramTheme = .default
  
  func makeNSView(context: Context) -> MermaidView {
    let view = MermaidView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
    view.wantsLayer = true
    return view
    
  }
  
  func updateNSView(_ nsView: MermaidView, context: Context) {
    nsView.source = source
    nsView.theme = theme
  }
}

struct ResultView: View {
  var project: DesignData
  @SwiftUI.State var image: NSImage? = nil
  
  init() {
    let testData = TestData()
    project = DesignData(name: "Test", objects: [testData.system, testData.bill, testData.user, testData.transaction,])
//    project.objects.append(testData.system1)
//    project.objects.append(testData.bill1)
//    project.objects.append(testData.user1)
//    project.objects.append(testData.transaction1)
  }
  
  var body: some View {
    ScrollView() {
      if let image = image {
        Image(nsImage: image)
        Button() {
          saveImageToDesktop(image: image, fileName: "String")
        } label: {
          Text("Сохранить диаграмму")
        }
      }
    }
    .onAppear() {
      do {
        image = try MermaidRenderer.renderImage(source: getMermaidCode())
      } catch {
          print("Ошибка: \(error)")
      }
    }
  }
  func saveImageToDesktop(image: NSImage, fileName: String) {
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
  
  private func getMermaidCode() -> String {
    var code: String = "erDiagram"
    for object in project.objects {
      code +=  "\n \(object.name) {"
      for argument in object.arguments {
        code += "\n \(argument.typeOfData)"
        code += "\(argument.typeOfData == "Array" ? "<": "")\(argument.appObject?.name ?? "")\(argument.typeOfData == "Array" ? ">": "")"
        code += " \(argument.name)"
      }
      code += "\n }"
    }
    
    for object in project.objects {
      for argument in object.arguments {
        if let appObjectName = argument.appObject?.name {
          if (argument.typeOfData == "Array") || (object.arguments.filter { $0.appObject?.name == argument.appObject?.name}.count > 1) {
            code += "\n \(object.name) ||--|{ \(appObjectName) : contains"
          } else {
            code += "\n \(object.name) ||--|| \(appObjectName) : has"
          }
        }
      }
    }
    
    return code
  }
}

#Preview {
  ResultView()
}
