import SwiftUI
import Core


var dateFormatter: () -> DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a  MMMM d,YYYY"
    return formatter
}

struct CreateTaskView: View {
    var body: some View {
        
        VStack(spacing: .zero) {
            
            ScrollView(.vertical) {
                
                VStack(spacing: .py_grid(3)) {
                    
                    TextField("Task Title", text: .constant("Read Zero to One"))
                        .font(Font.preferred(.py_title3()).bold())
                        .padding()
                    
                    Text("START DATE")
                        .foregroundColor(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                                                            
                    DateControlView(date: .constant(Date()))
                        
                    Text("END DATE")
                        .foregroundColor(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    DateControlView(date: .constant(Date()))
                    
                    Text("PROGRESS COLOUR")
                        .foregroundColor(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HDashedLine(color: Color(white: 0.8), lineWidth: 2)
                    ScrollView(.horizontal) {
                        HStack {
                            Spacer(minLength: .py_grid(2))
                            ForEach(
                                [Color.red, .blue, .green, .yellow, .pink, .gray],
                                id: \.self) { color in
                                ZStack {
                                    Circle()
                                        .fill(color == .green ? color: .clear)
                                        .frame(
                                            width: .py_grid(5),
                                            height: .py_grid(5)
                                        )
                                    Circle()
                                        .stroke(color, lineWidth: .py_grid(1))
                                        .frame(
                                            width: .py_grid(10),
                                            height: .py_grid(10)
                                        ).padding(.py_grid(1))
                                }
                            }
                            Spacer(minLength: .py_grid(2))
                        }
                    }
                    
                    Text("STYLE")
                        .foregroundColor(.gray)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        HDashedLine(color: Color(white: 0.8), lineWidth: 2)
                        HStack(alignment: .center, spacing: .zero) {
                            
                            ProgressBarStyleView(isSelected: .constant(true))
                            
                            ProgressCircleStyleView(isSelected: .constant(false))
                            
                        }.padding(.horizontal)
                    }
                                        
                }
                
                Spacer(minLength: .py_grid(3))
                
            }.font(.preferred(.py_subhead()))
            .multilineTextAlignment(.center)
            
            VStack {
                                                   
                Text("2months 16days 25min")
                    .font(.preferred(UIFont.py_title3().monospaced))
                                    
                Button(
                    action: {},
                    label: { Text("START") }
                ).buttonStyle(CreateButtonStyle())
                .padding(.bottom)
                                    
            }.frame(maxWidth: .infinity)
            .padding()
            .background(
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.white)
                        .shadow(radius: 1)
                    Button(action: {}) {
                        Image(systemName: "xmark")
                    }.buttonStyle(RoundedButtonStyle())
                    .padding()
                    
                }
            )
        }.edgesIgnoringSafeArea(.bottom)
    }
}


struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.py_grid(1))
            .font(.preferred(.py_footnote()))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .frame(width: .py_grid(14), height: .py_grid(14))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(3))
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 0.5)
            ).scaleEffect(configuration.isPressed ? 1.1: 1)
            .animation(.linear)
            
    }
}

struct CreateTaskView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CreateTaskView()
            CreateTaskView()
                .previewDevice(
                    PreviewDevice(rawValue: "iPhone X")
                )
        }
    }
}

struct RoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(white: 0.5))
            .padding(.py_grid(2))
            .background(
                Circle()
                    .fill(Color(white: 0.95))
            )
            
    }
}

struct CreateButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(Font.preferred(.py_title2()).bold())
            .padding()
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: .py_grid(4))
            )
    }
}

struct ProgressBarStyleView: View {
    @Binding var isSelected: Bool
    var body: some View {
        VStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color(white: 0.95))
                .frame(width: .py_grid(20), height: .py_grid(1))
            
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color(white: 0.95))
                .frame(
                    width: .py_grid(15),
                    height: .py_grid(1))
            
            ProgressBar(
                color: isSelected ? .pink: .gray,
                labelHidden: true,
                progress: .constant(0.2)
            ).frame(width: .py_grid(30))
        }.padding(.horizontal, .py_grid(2))
        .frame(height: .py_grid(15))
        .background(
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color.white)
                .shadow(radius: 1.0)
        ).frame(maxWidth: .infinity)
    }
}

struct ProgressCircleStyleView: View {
    @Binding var isSelected: Bool
    var body: some View {
        HStack {
            
            ProgressCircle(
                color: isSelected ? .pink: .gray,
                labelHidden: true,
                progress: .constant(0.4)
            ).frame(
                width: .py_grid(10),
                height: .py_grid(10)
            )
            
            VStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .py_grid(2))
                    .fill(Color(white: 0.95))
                    .frame(width: .py_grid(20), height: .py_grid(1))
                RoundedRectangle(cornerRadius: .py_grid(2))
                    .fill(Color(white: 0.95))
                    .frame(width: .py_grid(15), height: .py_grid(1))
            }
            
        }.padding(.horizontal, .py_grid(2))
        .frame(height: .py_grid(15))
        .background(
            RoundedRectangle(cornerRadius: .py_grid(2))
                .fill(Color.white)
                .shadow(radius: 1.0)
        ).frame(maxWidth: .infinity)
    }
}

struct DateControlView: View {
    @Binding var date: Date
    var body: some View {
        
        VStack(spacing: .py_grid(4)) {
            
            HDashedLine(color: Color(white: 0.8), lineWidth: 2)
            
            Text(date, formatter: dateFormatter())
                .font(.preferred(UIFont.py_headline().monospaced.bolded))
                .frame(height: .py_grid(12))
                .padding(.horizontal, .py_grid(10))
                .background(
                    RoundedRectangle(cornerRadius: .py_grid(4))
                        .fill(Color.white)
                        
                )
            HStack {
                Button(action: {}) {
                    VStack(spacing: .py_grid(2)) {
                        Image(systemName: "plus")
                        Text("HOUR")
                    }
                }.buttonStyle(AddButtonStyle())
                Button(action: {}) {
                    VStack(spacing: .py_grid(2)) {
                        Image(systemName: "plus")
                        Text("DAY")
                    }
                }.buttonStyle(AddButtonStyle())
                Button(action: {}) {
                    VStack(spacing: .py_grid(2)) {
                        Image(systemName: "plus")
                        Text("MONTH")
                    }
                }.buttonStyle(AddButtonStyle())
                Button(action: {}) {
                    VStack(spacing: .py_grid(2)) {
                        Image(systemName: "plus")
                        Text("YEAR")
                    }
                }.buttonStyle(AddButtonStyle())
            }
                       
        }
    }
}

public struct HDashedLine: View {
    let color: Color
    let lineWidth: CGFloat
    public init(color: Color = Color(white: 0.92), lineWidth: CGFloat = 1) {
        self.color = color
        self.lineWidth = lineWidth
    }
    public var body: some View {
        GeometryReader { proxy in
            Path { path in
                let maxX = proxy.size.width
                path.move(to: .zero)
                path.addLine(to: CGPoint.init(x: maxX, y: 0))
            }.stroke(style:
                StrokeStyle(
                    lineWidth: self.lineWidth,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [0.1,0.1,0.1, 4]
                )
            ).foregroundColor(self.color)
        }.frame(height: lineWidth)
    }
}
