//
//  ApplicationHelpView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 28/09/2025.
//

import SwiftUI

struct ApplicationHelpView: View {
  @ObservedObject var viewModel = ApplicationHelpViewModel()
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      ScrollView {
        ForEach(viewModel.topics, id: \.self) { item in
          Text(item)
            .font(.system(size: 21, weight: .medium))
        }
      }
      .frame(alignment: .leading)
    }
    .padding(20)
    .frame(alignment: .leading)
    .toolbarTitleDisplayMode(.inline)
  }
}
