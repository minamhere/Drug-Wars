//
//  ContentView.swift
//  Drug Wars
//
//  Created by Chris Nolan on 8/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        VStack(spacing: 0) {
            CalculatorScreenView(gameState: gameState)
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.4)
            
            CalculatorButtonsView(gameState: gameState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct CalculatorScreenView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.7, green: 0.8, blue: 0.6))
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 3)
                        .padding(4)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DRUG WARS")
                    .font(.custom("Courier", size: 20).weight(.black).monospaced())
                    .foregroundColor(.black)
                    .tracking(2.0)
                    .textCase(.uppercase)
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(gameState.displayLines, id: \.self) { line in
                            Text(line)
                                .font(.custom("Courier", size: 14).weight(.black).monospaced())
                                .foregroundColor(.black)
                                .tracking(1.2)
                                .textCase(.uppercase)
                        }
                    }
                }
                
                HStack {
                    Text("LOC: \(gameState.currentLocation.uppercased())")
                        .font(.custom("Courier", size: 12).weight(.black).monospaced())
                        .foregroundColor(.black)
                        .tracking(0.5)
                    
                    Spacer()
                    
                    Text("CAP: \(gameState.usedCapacity())/\(gameState.capacity)")
                        .font(.custom("Courier", size: 12).weight(.black).monospaced())
                        .foregroundColor(.black)
                        .tracking(0.5)
                }
                .padding(.top, 4)
                
                HStack {
                    Text("DAY: \(gameState.currentDay)/30")
                        .font(.custom("Courier", size: 12).weight(.black).monospaced())
                        .foregroundColor(.black)
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Text("CASH: $\(gameState.cash)")
                        .font(.custom("Courier", size: 12).weight(.black).monospaced())
                        .foregroundColor(.black)
                        .tracking(1.0)
                    
                    Spacer()
                    
                    Text("DEBT: $\(gameState.debt)")
                        .font(.custom("Courier", size: 12).weight(.black).monospaced())
                        .foregroundColor(.black)
                        .tracking(1.0)
                }
            }
            .padding(12)
        }
        .padding(.horizontal, 8)
    }
}

struct CalculatorButtonsView: View {
    @ObservedObject var gameState: GameState
    
    let buttonLayout = [
        ["Y=", "WINDOW", "ZOOM", "TRACE", "GRAPH"],
        ["2nd", "MODE", "DEL", "←", "CLEAR"],
        ["X,T,θ,n", "STAT", "MATH", "APPS", "PRGM"],
        ["x⁻¹", "SIN", "COS", "TAN", "^"],
        ["x²", "x", "LOG", "LN", "STO→"],
        ["7", "8", "9", ")", "÷"],
        ["4", "5", "6", "×", "-"],
        ["1", "2", "3", "+", "ENTER"],
        ["0", ".", "(-)", "", ""]
    ]
    
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<buttonLayout.count, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<buttonLayout[row].count, id: \.self) { col in
                        let buttonText = buttonLayout[row][col]
                        if !buttonText.isEmpty {
                            CalculatorButton(
                                text: buttonText,
                                action: { gameState.handleButtonPress(buttonText) },
                                isLastColumn: col == 4
                            )
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity, maxHeight: 35)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxHeight: .infinity)
        .background(Color(red: 0.3, green: 0.35, blue: 0.25))
    }
}

struct CalculatorButton: View {
    let text: String
    let action: () -> Void
    let isLastColumn: Bool
    
    init(text: String, action: @escaping () -> Void, isLastColumn: Bool = false) {
        self.text = text
        self.action = action
        self.isLastColumn = isLastColumn
    }
    
    var buttonColor: Color {
        if isLastColumn {
            return Color(red: 0.2, green: 0.3, blue: 0.6)
        }
        return Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    var textColor: Color {
        if isLastColumn {
            return .white
        }
        return Color(red: 0.9, green: 0.9, blue: 0.9)
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom("Helvetica Neue", size: 12).weight(.bold))
                .foregroundColor(textColor)
                .minimumScaleFactor(0.6)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(buttonColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                )
        }
        .frame(height: 35)
    }
}


#Preview {
    ContentView()
}
