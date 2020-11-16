import SwiftUI
import Core

public struct FullProgressView: View {
    public init() { }
    public var body: some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                ProgressCircle(
                    color: .pink,
                    lineWidth: .py_grid(4),
                    labelHidden: true,
                    progress: .constant(0.3)
                ).padding()
                .shadow(color: Color.pink, radius: 1)
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: .py_grid(2), height: .py_grid(2))
                    Text("18%")
                        .font(.preferred(.py_caption2()))
                }.padding([.top, .leading], .py_grid(1))
            }
            ZStack(alignment: .topTrailing) {
                ProgressCircle(
                    color: .green,
                    lineWidth: .py_grid(4),
                    labelHidden: true,
                    progress: .constant(0.7)
                ).padding()
                 .padding(.py_grid(3))
                .shadow(color: Color.green, radius: 2)
                HStack(spacing: 2) {
                    Text("60%")
                        .font(.preferred(.py_caption2()))
                        .foregroundColor(Color(.secondaryLabel))
                    Circle()
                        .fill(Color.green)
                        .frame(width: .py_grid(2), height: .py_grid(2))
                }.padding([.top, .trailing], .py_grid(1))
            }
            ZStack(alignment: .bottomTrailing) {
                ProgressCircle(
                    color: .blue,
                    lineWidth: .py_grid(4),
                    labelHidden: true,
                    progress: .constant(0.7)
                ).padding()
                 .padding()
                 .padding(.py_grid(3))
                .shadow(color: Color.blue, radius: 3)
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: .py_grid(2), height: .py_grid(2))
                    Text("60%")
                        .font(.preferred(.py_caption2()))
                        .foregroundColor(Color(.secondaryLabel))
                }.padding([.bottom, .trailing], .py_grid(1))
            }
            ZStack(alignment: .bottomLeading) {
                ProgressCircle(
                    color: .orange,
                    lineWidth: .py_grid(4),
                    labelHidden: true,
                    progress: .constant(0.7)
                ).padding()
                 .padding()
                 .padding(.py_grid(3))
                .padding(.py_grid(4))
                .shadow(color: Color.orange, radius: 4)
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: .py_grid(2), height: .py_grid(2))
                    Text("60%")
                        .font(.preferred(.py_footnote(size: .py_grid(2))))
                        .foregroundColor(Color(.secondaryLabel))
                }.padding([.bottom, .leading], .py_grid(1))
            }
        }
    }
}

struct FullProgressView_Previews: PreviewProvider {
    static var previews: some View {
        FullProgressView()
            .previewLayout(.fixed(width: 167, height: 167))
    }
}
