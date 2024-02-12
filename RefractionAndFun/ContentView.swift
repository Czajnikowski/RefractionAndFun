//
//  ContentView.swift
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 12/02/2024.
//

import SwiftUI
import Forge

struct RendererView: View {
  var body: some View {
    ForgeView(renderer: RefractionAndFunRenderer())
      .ignoresSafeArea()
      .navigationTitle("Refraction & Fun")
  }
}

#Preview {
  RendererView()
}
