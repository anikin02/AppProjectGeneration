//
//  ApplicationHelpView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 28/09/2025.
//

import SwiftUI

struct ApplicationHelpView: View {
  @ObservedObject var viewModel = ApplicationHelpViewModel()
  var count: Int = 1
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        ForEach(Array(viewModel.topics.enumerated()), id: \.offset) { index, item in
          Text("\(index + 1). \(item)")
            .font(.system(size: 21, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .toolbarTitleDisplayMode(.inline)
  }
}
