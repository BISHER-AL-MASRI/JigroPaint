import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color: Color = .red
    var lineWidth: Double = 1.0
}

struct ContentView: View {
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var thickness: Double = 1.0
    @State private var showingThicknessSheet = false
    
    var body: some View {
        ZStack {
            Color.white
            
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                }
            }
            .frame(minWidth: 400, minHeight: 400)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    let newPoint = value.location
                    currentLine.points.append(newPoint)
                    self.lines.append(currentLine)
                })
                .onEnded({ value in
                    self.lines.append(currentLine)
                    self.currentLine = Line(points: [], color: currentLine.color, lineWidth: thickness)
                })
            )
            
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {
                        showingThicknessSheet = true
                    }) {
                        Image(systemName: "lineweight")
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Divider()
                        .frame(height: 24)
                    
                    ColorPickerView(selectedColor: $currentLine.color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.white))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showingThicknessSheet) {
            ThicknessAdjustmentSheet(thickness: $thickness, currentLine: $currentLine)
        }
    }
}

struct ThicknessAdjustmentSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var thickness: Double
    @Binding var currentLine: Line
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Line Thickness: \(Int(thickness))")
                    .font(.headline)
                    .padding(.top)
                
                Slider(value: $thickness, in: 1...20) { _ in
                    currentLine.lineWidth = thickness
                }
                .padding(.horizontal)
                
                Rectangle()
                    .fill(currentLine.color)
                    .frame(width: 100, height: thickness)
                    .padding(.vertical)
                
                Spacer()
            }
            .navigationTitle("Adjust Thickness")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(250)])
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
