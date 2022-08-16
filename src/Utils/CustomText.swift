//
//  CustomText.swift
//  DukeSakai (iOS)
//
//  Created by Luke Redmore on 8/15/22.
//

import SwiftUI

extension Font {
    
    public static var tabBarItem: UIFont {
        UIFont(name: UIAccessibility.isBoldTextEnabled ? "OpenSans-Semibold" : "OpenSans", size: 11)!
    }
    
    /// Create a font with the large title text style.
    public static var largeTitle: Font {
        return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .heavy : .bold)
    }

    /// Create a font with the title text style.
    public static var title: Font {
        return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .title1).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .heavy : .bold)
    }
    
    public static var loginTitle: Font {
        title
    }

    /// Create a font with the headline text style.
    public static var headline: Font {
        return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .bold : .semibold)
    }

    /// Create a font with the subheadline text style.
    public static var subheadline: Font {
        return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .semibold : .regular)
    }

    /// Create a font with the body text style.
    public static var body: Font {
           return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .semibold : .regular)
       }

    /// Create a font with the callout text style.
    public static var callout: Font {
           return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .semibold : .regular)
       }

    /// Create a font with the footnote text style.
    public static var footnote: Font {
           return Font.custom("OpenSans", size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .regular : .light)
       }

    /// Create a font with the caption text style.
    public static var caption: Font {
           return Font.custom("OpenSans-Regular", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
            .weight(UIAccessibility.isBoldTextEnabled ? .regular : .light)
       }

    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        var font = "OpenSans-Regular"
        switch weight {
        case .bold: font = "OpenSans-Bold"
        case .heavy: font = "OpenSans-ExtraBold"
        case .light: font = "OpenSans-Light"
        case .medium: font = "OpenSans-Regular"
        case .semibold: font = "OpenSans-SemiBold"
        case .thin: font = "OpenSans-Light"
        case .ultraLight: font = "OpenSans-Light"
        default: break
        }
        return Font.custom(font, size: size)
    }
}

struct Text: View {
    @Environment(\.font) var font
    
    let str: String
    init(_ str: String) {
        self.str = str
    }
    
    var body: some View {
        SwiftUI.Text(str)
            .font( font ?? .body )
    }
}

struct Button<Label>: View where Label: View {
    @Environment(\.font) var font
    
    let button: SwiftUI.Button<Label>
    
    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        button = SwiftUI.Button(action: action, label: label)
    }
    
    init<S: StringProtocol>(_ title: S, action: @escaping () -> Void) where Label == SwiftUI.Text {
        button = SwiftUI.Button(title, action: action)
    }
    
    var body: some View {
        button.font(font ?? .body )
    }
}
