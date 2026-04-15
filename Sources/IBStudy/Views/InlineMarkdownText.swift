import SwiftUI

/// Renders `**bold**` and light markdown in labels (SwiftUI `Text` does not parse `**` alone).
struct InlineMarkdownText: View {
    let string: String

    var body: some View {
        Group {
            if let attributed = try? AttributedString(markdown: string) {
                Text(attributed)
            } else {
                Text(string)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
