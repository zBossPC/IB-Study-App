import SwiftUI

// MARK: - Block model

private enum MDBlock {
    case h2(String)
    case h3(String)
    case paragraph(String)
    case bullets([String])
    case numbered([String])
    case callout(String)        // lines starting with "> "
}

private func parseMarkdown(_ source: String) -> [(Int, MDBlock)] {
    var results: [(Int, MDBlock)] = []
    var counter = 0

    let groups = source.components(separatedBy: "\n\n")
    for group in groups {
        let trimmed = group.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { continue }

        let block: MDBlock
        if trimmed.hasPrefix("## ") {
            block = .h2(String(trimmed.dropFirst(3)))
        } else if trimmed.hasPrefix("### ") {
            block = .h3(String(trimmed.dropFirst(4)))
        } else {
            let lines = trimmed.components(separatedBy: "\n")

            let bulletItems = lines.compactMap { line -> String? in
                if line.hasPrefix("- ") { return String(line.dropFirst(2)) }
                if line.hasPrefix("* ") { return String(line.dropFirst(2)) }
                return nil
            }
            let calloutItems = lines.compactMap { line -> String? in
                if line.hasPrefix("> ") { return String(line.dropFirst(2)) }
                return nil
            }
            let numberedItems = lines.compactMap { line -> String? in
                if let r = line.range(of: #"^\d+\. "#, options: .regularExpression) {
                    return String(line[r.upperBound...])
                }
                return nil
            }

            if bulletItems.count == lines.count {
                block = .bullets(bulletItems)
            } else if calloutItems.count == lines.count {
                block = .callout(calloutItems.joined(separator: " "))
            } else if numberedItems.count == lines.count {
                block = .numbered(numberedItems)
            } else {
                block = .paragraph(trimmed)
            }
        }
        results.append((counter, block))
        counter += 1
    }
    return results
}

private func inlineText(_ raw: String) -> Text {
    (try? Text(AttributedString(markdown: raw))) ?? Text(raw)
}

// MARK: - View

struct MarkdownLessonView: View {
    let markdown: String

    private var blocks: [(Int, MDBlock)] { parseMarkdown(markdown) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(blocks, id: \.0) { _, block in
                blockView(block)
                    .padding(.bottom, bottomPadding(block))
            }
        }
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bottomPadding(_ block: MDBlock) -> CGFloat {
        switch block {
        case .h2: return 10
        case .h3: return 8
        case .callout: return 20
        default: return 16
        }
    }

    @ViewBuilder
    private func blockView(_ block: MDBlock) -> some View {
        switch block {

        case .h2(let text):
            VStack(alignment: .leading, spacing: 4) {
                Divider().opacity(0.0).frame(height: 12)
                inlineText(text)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                Divider()
            }

        case .h3(let text):
            inlineText(text)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.top, 8)

        case .paragraph(let text):
            inlineText(text)
                .font(.body)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

        case .bullets(let items):
            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 5, height: 5)
                            .padding(.top, 7)
                        inlineText(item)
                            .font(.body)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

        case .numbered(let items):
            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(i + 1).")
                            .font(.body.monospacedDigit().weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                            .frame(minWidth: 22, alignment: .trailing)
                        inlineText(item)
                            .font(.body)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

        case .callout(let text):
            HStack(alignment: .top, spacing: 12) {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 3)
                    .cornerRadius(2)
                inlineText(text)
                    .font(.body)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.accentColor.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}
