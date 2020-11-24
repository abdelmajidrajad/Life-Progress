import SwiftUI
public struct CloseButtonCircleStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1: 1.0)
            .padding(.py_grid(3))
            .font(.headline)
            .foregroundColor(Color(.darkGray))
            .background(
                VisualEffectBlur(blurStyle: .extraLight)
                    .clipShape(Circle())
            )

    }
}


public struct RoundedButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color(white: 0.5))
            .padding(.py_grid(2))
            .background(
                Circle()
                    .fill(Color(white: 0.98))
            )
        
    }
}

public struct CreateButtonStyle: ButtonStyle {
    var isValid: Bool = false
    let color: Color
    public init(
        isValid: Bool = false,
        color: Color
    ) {
        self.isValid = isValid
        self.color = color
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(Font.preferred(.py_title2()).bold().smallCaps())
            .padding()
            .padding(.horizontal, .py_grid(10))
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).fill(color.opacity(isValid ? 1: 0.5))
                .saturation(isValid ? 3.0: 1.0)
                    
            )
    }
}


public struct AddButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.py_grid(1))
            .font(.preferred(UIFont.py_caption2().monospaced.bolded))
            .foregroundColor(
                configuration.isPressed
                ? Color.white
                : Color(.lightGray)
            )
            .multilineTextAlignment(.center)
            .frame(width: .py_grid(14), height: .py_grid(14))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(3), style: .continuous)
                    .stroke(
                        configuration.isPressed
                            ? Color.blue
                            : Color.white.opacity(0.2)
                    )
            ).scaleEffect(configuration.isPressed ? 1.1: 1)
            .animation(.linear(duration: 0.2))
        
    }
}


public struct PlusButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, .py_grid(5))
            .padding(.vertical, .py_grid(3))
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.white)
                    .shadow(color: Color(white: 0.95), radius: 1)
            )
    }
}


public struct CornerButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).stroke(Color.white)
            )
    }
}


public struct SelectedCornerButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(
                    cornerRadius: .py_grid(4),
                    style: .continuous
                ).stroke(isSelected
                            ? Color(.label)
                            : Color(.systemBackground)
                )
            )
    }
}



public struct RoundButtonStyle: ButtonStyle {
    public init() { }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(Font.preferred(.py_title2()).bold().smallCaps())
            .padding(.vertical)
            .padding(.horizontal, .py_grid(6))
            .background(
                RoundedRectangle(cornerRadius: .py_grid(4))
                    .fill(Color(white: 0.97))
            )
    }
}
