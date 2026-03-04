import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Sfondo gradiente
            LinearGradient(
                colors: [Color(hex: "#4A90E2"), Color(hex: "#7B68EE")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Lucchetto
            Image(systemName: "lock.shield.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 400, height: 400)
            
            // Dollaro
            Text("$")
                .font(.system(size: 280, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 1024, height: 1024)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(red: Double((int >> 16) & 0xFF) / 255, green: Double((int >> 8) & 0xFF) / 255, blue: Double(int & 0xFF) / 255)
    }
}

#Preview {
    AppIconView()
}
