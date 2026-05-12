import SwiftUI
import TapOnPhone

struct SDKMessageOverlay: View {
    @ObservedObject var handler: SDKDelegateHandler

    var body: some View {
        ZStack {
            if handler.showMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text(handler.currentMessage)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: handler.showMessage)
            }
        }
        .sheet(isPresented: $handler.showKeyboard) {
            if let req = handler.keyboardRequest {
                if #available(iOS 16.0, *) {
                    NavigationStack {
                        VStack(spacing: 20) {
                            Text(req.title).font(.headline)
                            TextField("Entrada", text: $handler.keyboardInput)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                            HStack {
                                Button("Cancelar", role: .cancel) { handler.cancelKeyboard() }
                                Spacer()
                                Button("Confirmar") { handler.submitKeyboard() }
                                    .bold()
                            }
                            .padding()
                        }
                        .padding()
                        .navigationTitle("Entrada necessária")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDetents([.medium])
                } else {
                    NavigationView {
                        VStack(spacing: 20) {
                            Text(req.title).font(.headline)
                            TextField("Entrada", text: $handler.keyboardInput)
                                .textFieldStyle(.roundedBorder)
                                .padding()
                            HStack {
                                Button("Cancelar", role: .cancel) { handler.cancelKeyboard() }
                                Spacer()
                                Button("Confirmar") { handler.submitKeyboard() }
                                    
                            }
                            .padding()
                        }
                        .padding()
                        .navigationTitle("Entrada necessária")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        .sheet(isPresented: $handler.showMenu) {
            if let req = handler.menuRequest {
                if #available(iOS 16.0, *) {
                    NavigationStack {
                        List(req.options, id: \.self) { option in
                            Button(option) {
                                handler.selectMenuOption(option)
                            }
                        }
                        .navigationTitle(req.title)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .presentationDetents([.medium, .large])
                } else {
                    NavigationView {
                        List(req.options, id: \.self) { option in
                            Button(option) {
                                handler.selectMenuOption(option)
                            }
                        }
                        .navigationTitle(req.title)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
    }
}
