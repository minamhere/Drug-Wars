import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Calculator body
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                .frame(width: 200, height: 260)
            
            VStack(spacing: 8) {
                // Screen
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.7, green: 0.8, blue: 0.6))
                    .frame(width: 160, height: 80)
                    .overlay(
                        VStack(spacing: 2) {
                            Text("DRUG")
                                .font(.custom("Courier", size: 14).weight(.black))
                                .foregroundColor(.black)
                            Text("WARS")
                                .font(.custom("Courier", size: 14).weight(.black))
                                .foregroundColor(.black)
                        }
                    )
                
                // Button grid
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .frame(width: 24, height: 24)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .frame(width: 24, height: 24)
                        }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .frame(width: 24, height: 24)
                        }
                    }
                }
            }
        }
        .frame(width: 1024, height: 1024)
        .background(Color.black)
    }
}