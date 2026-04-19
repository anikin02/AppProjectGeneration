//
//  FileUploudView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 28/09/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileUploadView: View {
  @ObservedObject var viewModel = FileUploadViewModel()
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
          .stroke(viewModel.isTargeted ? Color.accentColor : Color.gray, style: StrokeStyle(lineWidth: 3, dash: [10]))
          .background(viewModel.isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
          .frame(height: 200)
          .overlay(
            VStack(spacing: 10) {
              Image(systemName: viewModel.dropImageName)
                .font(.system(size: 50))
                .foregroundStyle(.accent)
              Text("Перетащите файл сюда")
                .font(.headline)
              if let fileName = viewModel.droppedFileName {
                Text("Файл: \(fileName)")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            }
          )
          .onDrop(of: [UTType.rtf], isTargeted: $viewModel.isTargeted) { providers in
            viewModel.handleDrop(providers: providers)
          }
      }
      .padding(40)
      
      Button {
        viewModel.parseButton()
        resultView.viewModel.project.objects = viewModel.parsedObjects
      } label: {
        Text(viewModel.droppedFileName != nil ? "Сгенерировать проект" : "Ожидание файла...")
          .foregroundStyle(.gray)
          .font(.system(size: 14, weight: .black))
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
      }
      .navigationDestination(isPresented: $viewModel.navigateToResult) {
        resultView
      }
      .disabled(viewModel.droppedFileName == nil)
      
      if let _ = viewModel.droppedFileName {
        Button {
          viewModel.cancelUploud()
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
}

#Preview {
  FileUploadView()
}

