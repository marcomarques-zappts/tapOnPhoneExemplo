import SwiftUI

struct NFCPaymentOverlay: View {
    let amount: String
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                Text(amount)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.25 - Double(i) * 0.07), lineWidth: 1.5)
                            .frame(width: CGFloat(80 + i * 44), height: CGFloat(80 + i * 44))
                            .scaleEffect(pulsing ? 1.12 : 0.9)
                            .animation(
                                .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.3),
                                value: pulsing
                            )
                    }

                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                }
                .frame(height: 170)

                Text("Aproxime o cartão")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.white.opacity(0.85))

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.3)

                Spacer()
            }
            .padding()
        }
        .onAppear { pulsing = true }
        .transition(.opacity)
    }
}

#Preview {
    NFCPaymentOverlay(amount: "R$ 10,00")
}
