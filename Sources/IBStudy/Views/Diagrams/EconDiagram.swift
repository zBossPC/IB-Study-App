import SwiftUI

// MARK: - Coordinate system

/// Maps (Q, P) economic coordinates to canvas pixel coordinates.
private struct DC {
    let s: CGSize
    let q0: Double, q1: Double  // Q domain
    let p0: Double, p1: Double  // P domain

    static let lm: CGFloat = 58   // left margin (P axis)
    static let bm: CGFloat = 54   // bottom margin (Q axis)
    static let rm: CGFloat = 74   // right margin (curve labels)
    static let tm: CGFloat = 30   // top margin

    var pw: CGFloat { s.width  - DC.lm - DC.rm }
    var ph: CGFloat { s.height - DC.bm - DC.tm }

    func x(_ q: Double) -> CGFloat { DC.lm + CGFloat((q - q0) / (q1 - q0)) * pw }
    func y(_ p: Double) -> CGFloat { (s.height - DC.bm) - CGFloat((p - p0) / (p1 - p0)) * ph }
    func pt(_ q: Double, _ p: Double) -> CGPoint { CGPoint(x: x(q), y: y(p)) }
}

// MARK: - Drawing helpers

private enum Draw {

    static func grid(_ ctx: inout GraphicsContext, dc: DC, xSteps: Int = 4, ySteps: Int = 4) {
        var path = Path()
        for step in 1..<xSteps {
            let q = dc.q0 + (dc.q1 - dc.q0) * Double(step) / Double(xSteps)
            path.move(to: dc.pt(q, dc.p0))
            path.addLine(to: dc.pt(q, dc.p1))
        }
        for step in 1..<ySteps {
            let p = dc.p0 + (dc.p1 - dc.p0) * Double(step) / Double(ySteps)
            path.move(to: dc.pt(dc.q0, p))
            path.addLine(to: dc.pt(dc.q1, p))
        }
        ctx.stroke(path, with: .color(.white.opacity(0.08)), style: StrokeStyle(lineWidth: 1, dash: [4, 6]))
    }

    /// Axes with arrow tips and P / Q labels.
    static func axes(_ ctx: inout GraphicsContext, dc: DC) {
        var p = Path()
        let ox = dc.x(dc.q0), oy = dc.y(dc.p0)
        // Y axis
        p.move(to: CGPoint(x: ox, y: oy + 4))
        p.addLine(to: CGPoint(x: ox, y: DC.tm - 6))
        p.addLine(to: CGPoint(x: ox - 4, y: DC.tm))
        p.move(to: CGPoint(x: ox, y: DC.tm - 6))
        p.addLine(to: CGPoint(x: ox + 4, y: DC.tm))
        // X axis
        p.move(to: CGPoint(x: ox - 4, y: oy))
        p.addLine(to: CGPoint(x: dc.s.width - DC.rm + 10, y: oy))
        p.addLine(to: CGPoint(x: dc.s.width - DC.rm + 4, y: oy - 4))
        p.move(to: CGPoint(x: dc.s.width - DC.rm + 10, y: oy))
        p.addLine(to: CGPoint(x: dc.s.width - DC.rm + 4, y: oy + 4))
        ctx.stroke(p, with: .color(.white.opacity(0.54)), lineWidth: 1.5)

        ctx.draw(Text("P").font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.68)),
                 at: CGPoint(x: ox, y: max(8, DC.tm - 18)), anchor: .center)
        ctx.draw(Text("Q").font(.system(size: 13, weight: .semibold)).foregroundColor(.white.opacity(0.68)),
                 at: CGPoint(x: min(dc.s.width - 10, dc.s.width - DC.rm + 20), y: oy), anchor: .center)
    }

    /// Sample a function and stroke it as a polyline. Clips to domain if out of range.
    static func curve(_ ctx: inout GraphicsContext, dc: DC,
                      fn: (Double) -> Double,
                      from qA: Double? = nil, to qB: Double? = nil,
                      color: Color, lw: CGFloat = 2.5, dashed: Bool = false) {
        let a = qA ?? dc.q0, b = qB ?? dc.q1
        let steps = 120
        var path  = Path(); var first = true
        for i in 0...steps {
            let q = a + Double(i) * (b - a) / Double(steps)
            let pv = fn(q)
            guard pv >= dc.p0 - 0.5, pv <= dc.p1 + 1 else { first = true; continue }
            let pt = dc.pt(q, pv)
            if first { path.move(to: pt); first = false } else { path.addLine(to: pt) }
        }
        let style = StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round, dash: dashed ? [7, 5] : [])
        ctx.stroke(path, with: .color(color), style: style)
    }

    /// Shade the vertical band between topFn and botFn over [qa, qb].
    static func shade(_ ctx: inout GraphicsContext, dc: DC,
                      top topFn: (Double) -> Double, bot botFn: (Double) -> Double,
                      from qa: Double, to qb: Double, color: Color) {
        let steps = 80
        var path  = Path(); var first = true
        for i in 0...steps {
            let q = qa + Double(i) * (qb - qa) / Double(steps)
            let pt = dc.pt(q, max(dc.p0, min(dc.p1, topFn(q))))
            if first { path.move(to: pt); first = false } else { path.addLine(to: pt) }
        }
        for i in stride(from: steps, through: 0, by: -1) {
            let q = qa + Double(i) * (qb - qa) / Double(steps)
            path.addLine(to: dc.pt(q, max(dc.p0, min(dc.p1, botFn(q)))))
        }
        path.closeSubpath()
        ctx.fill(path, with: .color(color))
    }

    /// Filled circle at (q, p) with white outline.
    static func dot(_ ctx: inout GraphicsContext, dc: DC, q: Double, p: Double,
                    r: CGFloat = 5, fill: Color = .primary) {
        let c = dc.pt(q, p)
        let rect = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
        ctx.fill(Path(ellipseIn: rect), with: .color(fill))
        ctx.stroke(Path(ellipseIn: rect), with: .color(.white), lineWidth: 1.5)
    }

    /// Dashed vertical guide line from (q, p0) to (q, p1).
    static func vGuide(_ ctx: inout GraphicsContext, dc: DC, q: Double, p0 pA: Double, p1 pB: Double) {
        var p = Path()
        p.move(to: dc.pt(q, pA)); p.addLine(to: dc.pt(q, pB))
        ctx.stroke(p, with: .color(.secondary.opacity(0.38)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }

    /// Dashed horizontal guide line from (q0, p) to (q1, p).
    static func hGuide(_ ctx: inout GraphicsContext, dc: DC, p: Double, q0 qA: Double, q1 qB: Double) {
        var path = Path()
        path.move(to: dc.pt(qA, p)); path.addLine(to: dc.pt(qB, p))
        ctx.stroke(path, with: .color(.secondary.opacity(0.38)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
    }

    /// Short tick + small numeric label on the Q axis.
    /// Clamps the label so it never extends past the Canvas left/right edges.
    static func qLabel(_ ctx: inout GraphicsContext, dc: DC, q: Double, label: String, color: Color = .secondary) {
        let xv = dc.x(q), yv = dc.y(dc.p0)
        var p = Path()
        p.move(to: CGPoint(x: xv, y: yv - 2)); p.addLine(to: CGPoint(x: xv, y: yv + 5))
        ctx.stroke(p, with: .color(color.opacity(0.6)), lineWidth: 1.5)
        let labelX = max(20, min(dc.s.width - 20, xv))
        ctx.draw(Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(color.opacity(0.75)),
                 at: CGPoint(x: labelX, y: min(yv + 15, dc.s.height - 6)), anchor: .center)
    }

    /// Short tick + small numeric label on the P axis.
    /// Clamps vertically so labels near the top/bottom don't clip.
    static func pLabel(_ ctx: inout GraphicsContext, dc: DC, p: Double, label: String, color: Color = .secondary) {
        let xv = dc.x(dc.q0), yv = dc.y(p)
        var path = Path()
        path.move(to: CGPoint(x: xv - 5, y: yv)); path.addLine(to: CGPoint(x: xv + 2, y: yv))
        ctx.stroke(path, with: .color(color.opacity(0.6)), lineWidth: 1.5)
        let clampedY = max(8, min(dc.s.height - 8, yv))
        ctx.draw(Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(color.opacity(0.75)),
                 at: CGPoint(x: xv - 9, y: clampedY), anchor: .trailing)
    }

    /// Bold colored label placed just off the end of a curve.
    /// Automatically flips to `.trailing` anchor when the label would
    /// overflow the right edge of the Canvas, and clamps vertically.
    static func label(_ ctx: inout GraphicsContext, dc: DC,
                      q: Double, p: Double, text: String, color: Color,
                      anchor: UnitPoint = .leading, dx: CGFloat = 6, dy: CGFloat = 0) {
        let base = dc.pt(q, p)
        var ptX = base.x + dx
        let ptY = max(8, min(dc.s.height - 8, base.y + dy))

        var used = anchor
        let charWidth: CGFloat = 8
        let estimatedWidth = CGFloat(text.count) * charWidth
        if used == .leading && ptX + estimatedWidth > dc.s.width - 4 {
            used = .trailing
            ptX = base.x - dx
        }

        ctx.draw(
            Text(text).font(.system(size: 12, weight: .bold)).foregroundColor(color),
            at: CGPoint(x: ptX, y: ptY),
            anchor: used
        )
    }

    /// Small annotation label (used for region names like "Profit", "DWL").
    /// Clamped to Canvas bounds.
    static func regionLabel(_ ctx: inout GraphicsContext, dc: DC,
                             q: Double, p: Double, text: String, color: Color) {
        let pt = dc.pt(q, p)
        let cx = max(30, min(dc.s.width - 30, pt.x))
        let cy = max(10, min(dc.s.height - 10, pt.y))
        ctx.draw(
            Text(text).font(.system(size: 10, weight: .semibold)).foregroundColor(color),
            at: CGPoint(x: cx, y: cy), anchor: .center
        )
    }
}

private struct DiagramCardStyle: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), tint.opacity(0.06), Color.black.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.14),
                                        tint.opacity(0.14),
                                        Color.black.opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), tint.opacity(0.28), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

private extension View {
    func diagramCard(tint: Color) -> some View {
        modifier(DiagramCardStyle(tint: tint))
    }
}

private enum EconCurveModel {
    static let fixedCost = 18.0

    static func shortRunVariableCost(_ q: Double) -> Double {
        5 * q - 0.9 * q * q + 0.12 * q * q * q
    }

    static func shortRunTotalCost(_ q: Double) -> Double {
        fixedCost + shortRunVariableCost(q)
    }

    static func shortRunMC(_ q: Double) -> Double {
        max(0.2, 5 - 1.8 * q + 0.36 * q * q)
    }

    static func shortRunAVC(_ q: Double) -> Double {
        q > 0 ? shortRunVariableCost(q) / q : 0
    }

    static func shortRunATC(_ q: Double) -> Double {
        q > 0 ? shortRunTotalCost(q) / q : 0
    }
}

// MARK: - ─────────────────────────────────────────────────────────────────
// MARK:   Monopoly diagram
// MARK: ─────────────────────────────────────────────────────────────────

/// Textbook monopoly graph: D, MR, MC, ATC with profit rectangle and DWL triangle.
/// Interactive Q slider so students can explore MR vs MC.
struct MonopolyDiagramView: View {
    @State private var chosenQ: Double = 6.0
    @EnvironmentObject private var progress: ProgressStore

    private func demand(_ q: Double) -> Double { max(0, 24 - q) }
    private func mr(_ q: Double)     -> Double { 24 - 2 * q }
    private func mc(_ q: Double)     -> Double { 6 + q }
    private func tc(_ q: Double)     -> Double { 18 + 6 * q + 0.5 * q * q }
    private func atc(_ q: Double)    -> Double { q > 0 ? tc(q) / q : 0 }

    private let qStar = 6.0, pStar = 18.0
    private var atcStar: Double { atc(qStar) }
    private var qComp: Double { 9.0 }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 15, p0: 0, p1: 26)

                // Profit rectangle
                Draw.shade(&c, dc: dc,
                           top: { _ in pStar }, bot: { _ in atcStar },
                           from: 0, to: qStar,
                           color: .green.opacity(0.12))

                // DWL triangle: (Q*, P*) → (Qcomp, Pcomp) → (Q*, MC(Q*))
                let qc = qComp, pComp = demand(qComp), mcStar = mc(qStar)
                var dwlPath = Path()
                dwlPath.move(to: dc.pt(qStar, pStar))
                dwlPath.addLine(to: dc.pt(qc, pComp))
                dwlPath.addLine(to: dc.pt(qStar, mcStar))
                dwlPath.closeSubpath()
                c.fill(dwlPath, with: .color(.orange.opacity(0.20)))

                // Chosen Q region highlight (dimmer)
                if abs(chosenQ - qStar) > 0.4 {
                    Draw.shade(&c, dc: dc,
                               top: { _ in demand(chosenQ) }, bot: { _ in atc(chosenQ) },
                               from: 0, to: chosenQ,
                               color: demand(chosenQ) >= atc(chosenQ) ? .green.opacity(0.07) : .red.opacity(0.07))
                }

                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                // ATC
                Draw.curve(&c, dc: dc, fn: atc, from: 0.8, to: 14, color: .green, lw: 2)
                // Demand
                Draw.curve(&c, dc: dc, fn: demand, from: 0, to: 14.5, color: .blue, lw: 2.5)
                // MR
                Draw.curve(&c, dc: dc, fn: mr, from: 0, to: 10, color: .red, lw: 2, dashed: true)
                // MC
                Draw.curve(&c, dc: dc, fn: mc, from: 0, to: 14, color: Color(hue: 0.08, saturation: 0.9, brightness: 0.85), lw: 2.5)

                // Guide lines for Q*
                Draw.vGuide(&c, dc: dc, q: qStar, p0: 0, p1: pStar)
                Draw.hGuide(&c, dc: dc, p: pStar,   q0: 0, q1: qStar)
                Draw.hGuide(&c, dc: dc, p: atcStar, q0: 0, q1: qStar)

                // Guide for chosen Q (if different from equilibrium)
                if abs(chosenQ - qStar) > 0.4 {
                    Draw.vGuide(&c, dc: dc, q: chosenQ, p0: 0, p1: demand(chosenQ))
                    Draw.hGuide(&c, dc: dc, p: demand(chosenQ), q0: 0, q1: chosenQ)
                    Draw.dot(&c, dc: dc, q: chosenQ, p: demand(chosenQ), r: 4, fill: .purple)
                    Draw.dot(&c, dc: dc, q: chosenQ, p: mc(chosenQ), r: 4, fill: Color(hue: 0.08, saturation: 0.9, brightness: 0.85))
                }

                // Equilibrium dot
                Draw.dot(&c, dc: dc, q: qStar, p: pStar, r: 5.5, fill: .blue)
                Draw.dot(&c, dc: dc, q: qStar, p: mcStar, r: 5, fill: Color(hue: 0.08, saturation: 0.9, brightness: 0.85))

                // Axis tick labels
                Draw.qLabel(&c, dc: dc, q: qStar, label: "Q*", color: .primary.opacity(0.65))
                Draw.qLabel(&c, dc: dc, q: qComp, label: "Qc", color: .secondary)
                Draw.pLabel(&c, dc: dc, p: pStar,   label: "P*",   color: .blue.opacity(0.8))
                Draw.pLabel(&c, dc: dc, p: atcStar, label: "ATC*", color: .green.opacity(0.8))

                // Region labels
                Draw.regionLabel(&c, dc: dc, q: qStar * 0.5, p: (pStar + atcStar) * 0.5, text: "Profit", color: .green.opacity(0.7))
                Draw.regionLabel(&c, dc: dc, q: qStar + 1.6, p: pStar * 0.67 + mcStar * 0.33, text: "DWL", color: .orange.opacity(0.75))

                // Curve labels
                Draw.label(&c, dc: dc, q: 14.5, p: demand(14.5), text: "D", color: .blue, dy: -2)
                Draw.label(&c, dc: dc, q: 10,   p: max(0, mr(10)) + 0.5, text: "MR", color: .red, dy: -2)
                Draw.label(&c, dc: dc, q: 14,   p: mc(14) + 0.4,    text: "MC", color: Color(hue: 0.08, saturation: 0.9, brightness: 0.85), dy: -2)
                Draw.label(&c, dc: dc, q: 13,   p: atc(13) + 0.5,   text: "ATC", color: .green, dy: -2)
            }
            .frame(height: 400)
            .padding(.horizontal, 4)

            // Controls
            diagramControls
        }
        .diagramCard(tint: .purple)
        .onAppear { progress.recordExploreOpened(sectionId: "monopoly") }
    }

    private var diagramControls: some View {
        VStack(spacing: 6) {
            HStack {
                let mrNow = mr(chosenQ), mcNow = mc(chosenQ)
                let status: (String, Color) = {
                    let d = mrNow - mcNow
                    if abs(d) < 1.0 { return ("MR ≈ MC — at the profit-maximizing output", .green) }
                    if d > 0        { return ("MR > MC — expand output to raise profit", .orange) }
                    return              ("MR < MC — cut back to raise profit", .red)
                }()
                Circle().fill(status.1).frame(width: 7, height: 7)
                Text(status.0)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(status.1)
                Spacer()
                Text("Q = \(chosenQ, specifier: "%.1f")")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $chosenQ, in: 1...14, step: 0.2)
                .tint(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.7))
    }
}

// MARK: - Short-run cost curves diagram

struct CostCurvesDiagramView: View {
    @State private var chosenQ: Double = 5.0
    @EnvironmentObject private var progress: ProgressStore

    private func mc(_ q: Double)  -> Double { EconCurveModel.shortRunMC(q) }
    private func avc(_ q: Double) -> Double { EconCurveModel.shortRunAVC(q) }
    private func atc(_ q: Double) -> Double { EconCurveModel.shortRunATC(q) }

    private var minAVCQ: Double { stride(from: 0.5, through: 12, by: 0.05).min(by: { avc($0) < avc($1) }) ?? 2.9 }
    private var minATCQ: Double { stride(from: 0.5, through: 12, by: 0.05).min(by: { atc($0) < atc($1) }) ?? 3.7 }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 13, p0: 0, p1: 24)
                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                Draw.curve(&c, dc: dc, fn: atc, from: 0.8, to: 12.5, color: .blue, lw: 2.5)
                Draw.curve(&c, dc: dc, fn: avc, from: 0.8, to: 12.5, color: .teal, lw: 2)
                Draw.curve(&c, dc: dc, fn: mc,  from: 0.5, to: 12.5, color: .red, lw: 2.5)

                // Q guide + dots at chosen Q
                Draw.vGuide(&c, dc: dc, q: chosenQ, p0: 0, p1: atc(chosenQ))
                Draw.dot(&c, dc: dc, q: chosenQ, p: mc(chosenQ),  r: 4.5, fill: .red)
                Draw.dot(&c, dc: dc, q: chosenQ, p: avc(chosenQ), r: 4, fill: .teal)
                Draw.dot(&c, dc: dc, q: chosenQ, p: atc(chosenQ), r: 4, fill: .blue)

                // Mark minima
                Draw.dot(&c, dc: dc, q: minAVCQ, p: avc(minAVCQ), r: 4, fill: .teal)
                Draw.dot(&c, dc: dc, q: minATCQ, p: atc(minATCQ), r: 4, fill: .blue)

                // Axis labels for minima
                Draw.qLabel(&c, dc: dc, q: minAVCQ, label: "min AVC", color: .teal.opacity(0.7))
                Draw.qLabel(&c, dc: dc, q: minATCQ, label: "min ATC", color: .blue.opacity(0.7))

                // Curve labels
                Draw.label(&c, dc: dc, q: 12.5, p: atc(12.5) - 0.5, text: "ATC", color: .blue)
                Draw.label(&c, dc: dc, q: 12.5, p: avc(12.5) - 0.5, text: "AVC", color: .teal)
                Draw.label(&c, dc: dc, q: 12.5, p: mc(12.5) + 0.3,  text: "MC",  color: .red)
            }
            .frame(height: 380)
            .padding(.horizontal, 4)

            // Metric chips
            HStack(spacing: 0) {
                metricCell("MC",  mc(chosenQ),  .red)
                metricCell("AVC", avc(chosenQ), .teal)
                metricCell("ATC", atc(chosenQ), .blue)
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)

            HStack {
                Text("Q = \(chosenQ, specifier: "%.1f")")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            Slider(value: $chosenQ, in: 0.8...12.5, step: 0.1)
                .tint(.red)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
        .diagramCard(tint: .orange)
        .onAppear { progress.recordExploreOpened(sectionId: "short-run-costs") }
    }

    private func metricCell(_ name: String, _ v: Double, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(name).font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
            Text(v, format: .number.precision(.fractionLength(2)))
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.07), in: RoundedRectangle(cornerRadius: 6))
        .padding(.horizontal, 3)
    }
}

// MARK: - Perfect competition — firm diagram

struct PCFirmDiagramView: View {
    @State private var marketPrice: Double = 15
    @EnvironmentObject private var progress: ProgressStore

    private func mc(_ q: Double)  -> Double { EconCurveModel.shortRunMC(q) }
    private func avc(_ q: Double) -> Double { EconCurveModel.shortRunAVC(q) }
    private func atc(_ q: Double) -> Double { EconCurveModel.shortRunATC(q) }

    private var firmQ: Double {
        // Find Q where MC = P on upward-sloping section
        var lo = 0.5, hi = 14.0
        guard mc(hi) >= marketPrice else { return hi }
        guard mc(lo) <= marketPrice else { return lo }
        for _ in 0..<60 { let m = (lo+hi)/2; if mc(m) < marketPrice { lo = m } else { hi = m } }
        return (lo+hi)/2
    }

    private var minAVC: Double {
        stride(from: 0.5, through: 12, by: 0.05).map { avc($0) }.min() ?? 5
    }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 15, p0: 0, p1: 26)
                let q  = firmQ
                let operating = marketPrice >= minAVC - 0.05

                // Profit / loss shading
                if operating {
                    let profColor: Color = marketPrice >= atc(q) ? .green.opacity(0.13) : .red.opacity(0.13)
                    Draw.shade(&c, dc: dc, top: { _ in marketPrice }, bot: atc, from: 0, to: q, color: profColor)
                }

                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                Draw.curve(&c, dc: dc, fn: atc, from: 0.8, to: 14, color: .blue, lw: 2)
                Draw.curve(&c, dc: dc, fn: avc, from: 0.8, to: 14, color: .teal, lw: 2)
                Draw.curve(&c, dc: dc, fn: mc,  from: 0.5, to: 14, color: .red, lw: 2.5)

                // P = MR = D horizontal line
                Draw.curve(&c, dc: dc, fn: { _ in marketPrice }, from: 0, to: 14, color: .purple, lw: 2.5)

                // Guide lines
                if operating {
                    Draw.vGuide(&c, dc: dc, q: q, p0: 0, p1: marketPrice)
                    Draw.hGuide(&c, dc: dc, p: marketPrice, q0: 0, q1: q)
                    Draw.dot(&c, dc: dc, q: q, p: marketPrice, r: 5.5, fill: .purple)

                    Draw.qLabel(&c, dc: dc, q: q, label: "Q*", color: .primary.opacity(0.65))
                    Draw.pLabel(&c, dc: dc, p: marketPrice, label: "P*", color: .purple.opacity(0.8))

                    // Region label
                    let pAtc = atc(q)
                    let mid = (marketPrice + pAtc) * 0.5
                    if abs(marketPrice - pAtc) > 0.8 {
                        Draw.regionLabel(&c, dc: dc, q: q * 0.5, p: mid,
                                         text: marketPrice >= pAtc ? "Profit" : "Loss",
                                         color: marketPrice >= pAtc ? .green.opacity(0.7) : .red.opacity(0.7))
                    }
                } else {
                    Draw.label(&c, dc: dc, q: 7, p: marketPrice + 1.5,
                               text: "Shut down: P < min AVC", color: .red.opacity(0.8), anchor: .center, dx: 0, dy: 0)
                }

                // Curve labels
                Draw.label(&c, dc: dc, q: 14, p: atc(14) + 0.3, text: "ATC", color: .blue)
                Draw.label(&c, dc: dc, q: 14, p: avc(14) - 1.0, text: "AVC", color: .teal)
                Draw.label(&c, dc: dc, q: 14, p: mc(14) + 0.4,  text: "MC",  color: .red)
                Draw.label(&c, dc: dc, q: 14, p: marketPrice - 1.3, text: "D=MR=P=AR", color: .purple)
            }
            .frame(height: 380)
            .padding(.horizontal, 4)

            HStack {
                Text("Market price P = \(marketPrice, specifier: "$.2f")")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(marketPrice >= minAVC - 0.05 ? "Operate" : "Shut down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(marketPrice >= minAVC - 0.05 ? .green : .red)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Slider(value: $marketPrice, in: 3...25, step: 0.25)
                .tint(.purple)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
        .diagramCard(tint: .teal)
        .onAppear { progress.recordExploreOpened(sectionId: "perfect-competition") }
    }
}

// MARK: - Monopolistic competition diagram

struct MonCompDiagramView: View {
    @State private var isLongRun = false
    @EnvironmentObject private var progress: ProgressStore

    private func tc(_ q: Double)  -> Double { 16.2 + 3.9 * q + 0.2 * q * q }
    private func atc(_ q: Double) -> Double { q > 0 ? tc(q) / q : 0 }
    private func mc(_ q: Double)  -> Double { 3.9 + 0.4 * q }

    // Short run: positive economic profit while firms still face a fairly elastic demand curve.
    private func srD(_ q: Double)  -> Double { max(0, 11.4 - 0.25 * q) }
    private func srMR(_ q: Double) -> Double { 11.4 - 0.5 * q }
    private let srQ = 8.33
    private var srP: Double { srD(srQ) }

    // Long run: demand becomes tangent to ATC left of minimum ATC, creating excess capacity.
    private func lrD(_ q: Double)  -> Double { max(0, 9.3 - 0.25 * q) }
    private func lrMR(_ q: Double) -> Double { 9.3 - 0.5 * q }
    private let lrQ = 6.0
    private var lrP: Double { lrD(lrQ) }

    private var qMinATC: Double { 9.0 }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc  = DC(s: size, q0: 0, q1: 14, p0: 0, p1: 14)
                let qSt = isLongRun ? lrQ : srQ
                let pSt = isLongRun ? lrP : srP
                let dFn: (Double) -> Double  = isLongRun ? lrD : srD
                let mrFn: (Double) -> Double = isLongRun ? lrMR : srMR
                let pAtc = atc(qSt)

                // Profit / loss shade (SR only)
                if !isLongRun {
                    Draw.shade(&c, dc: dc, top: { _ in pSt }, bot: atc, from: 0, to: qSt,
                               color: pSt >= pAtc ? .green.opacity(0.13) : .red.opacity(0.13))
                }

                // Excess capacity marker line (LR only)
                if isLongRun {
                    var ecPath = Path()
                    ecPath.move(to: dc.pt(qSt, pAtc - 1.0))
                    ecPath.addLine(to: dc.pt(qMinATC, pAtc - 1.0))
                    c.stroke(ecPath, with: .color(.orange.opacity(0.7)), style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                    Draw.label(&c, dc: dc, q: (qSt + qMinATC)*0.5, p: pAtc - 2.2, text: "Excess capacity", color: .orange.opacity(0.7), anchor: .center, dx: 0, dy: 0)
                }

                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                Draw.curve(&c, dc: dc, fn: atc, from: 0.9, to: 13, color: .blue, lw: 2)
                Draw.curve(&c, dc: dc, fn: mc,  from: 0,   to: 13, color: .red, lw: 2.5)
                Draw.curve(&c, dc: dc, fn: dFn, from: 0,   to: 13, color: .teal, lw: 2.5)
                Draw.curve(&c, dc: dc, fn: mrFn, from: 0, to: 13, color: .purple, lw: 2, dashed: true)

                // Equilibrium guides
                Draw.vGuide(&c, dc: dc, q: qSt, p0: 0, p1: pSt)
                Draw.hGuide(&c, dc: dc, p: pSt, q0: 0, q1: qSt)
                if !isLongRun {
                    Draw.hGuide(&c, dc: dc, p: pAtc, q0: 0, q1: qSt)
                    Draw.pLabel(&c, dc: dc, p: pAtc, label: "ATC*", color: .blue.opacity(0.7))
                    let mid = (pSt + pAtc) * 0.5
                    Draw.regionLabel(&c, dc: dc, q: qSt*0.5, p: mid,
                                     text: pSt >= pAtc ? "Profit" : "Loss",
                                     color: pSt >= pAtc ? .green.opacity(0.7) : .red.opacity(0.7))
                }

                // Equilibrium dot
                Draw.dot(&c, dc: dc, q: qSt, p: pSt, r: 5.5, fill: .teal)
                // MR=MC dot
                Draw.dot(&c, dc: dc, q: qSt, p: mc(qSt), r: 4.5, fill: .red)

                // Min ATC marker (LR)
                if isLongRun {
                    Draw.dot(&c, dc: dc, q: qMinATC, p: atc(qMinATC), r: 4, fill: .blue.opacity(0.5))
                    Draw.qLabel(&c, dc: dc, q: qMinATC, label: "min ATC Q", color: .blue.opacity(0.6))
                }

                Draw.qLabel(&c, dc: dc, q: qSt, label: "Q*", color: .primary.opacity(0.65))
                Draw.pLabel(&c, dc: dc, p: pSt, label: "P*", color: .teal.opacity(0.8))

                // Curve labels
                Draw.label(&c, dc: dc, q: 13, p: dFn(13) + 0.3, text: "D", color: .teal)
                Draw.label(&c, dc: dc, q: 11, p: max(0, mrFn(11)) + 0.8, text: "MR", color: .purple)
                Draw.label(&c, dc: dc, q: 13, p: mc(13) + 0.4, text: "MC", color: .red)
                Draw.label(&c, dc: dc, q: 12, p: atc(12) + 0.5, text: "ATC", color: .blue)
            }
            .frame(height: 380)
            .padding(.horizontal, 4)

            HStack {
                Spacer()
                Picker("", selection: $isLongRun) {
                    Text("Short Run").tag(false)
                    Text("Long Run").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 240)
                .padding(.vertical, 8)
                Spacer()
            }
            .padding(.bottom, 4)
        }
        .diagramCard(tint: .indigo)
        .onAppear { progress.recordExploreOpened(sectionId: "monopolistic-competition") }
    }
}

// MARK: - Production function diagram

struct ProductionDiagramView: View {
    @State private var workers: Double = 5
    @EnvironmentObject private var progress: ProgressStore

    private func tp(_ l: Double) -> Double { max(0, -0.1*l*l*l + 1.5*l*l + 2*l) }
    private func mp(_ l: Double) -> Double { max(0, -0.3*l*l + 3.0*l + 2) }
    private func ap(_ l: Double) -> Double { l > 0 ? tp(l) / l : 0 }

    var body: some View {
        VStack(spacing: 0) {
            // TP diagram
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 12, p0: 0, p1: 60)
                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                Draw.curve(&c, dc: dc, fn: tp, from: 0, to: 11.5, color: .blue, lw: 2.5)

                // Chosen worker guide
                let tpNow = tp(workers)
                Draw.vGuide(&c, dc: dc, q: workers, p0: 0, p1: tpNow)
                Draw.hGuide(&c, dc: dc, p: tpNow, q0: 0, q1: workers)
                Draw.dot(&c, dc: dc, q: workers, p: tpNow, r: 5.5, fill: .blue)

                // Inflection point ~5 workers
                Draw.dot(&c, dc: dc, q: 5, p: tp(5), r: 4, fill: .orange)

                // Labels
                Draw.label(&c, dc: dc, q: 11, p: tp(11) + 1, text: "TP", color: .blue)

                // Axis labels
                ctx.draw(Text("Total output").font(.system(size: 11, weight: .medium)).foregroundColor(Color.secondary),
                         at: CGPoint(x: DC.lm + 6, y: DC.tm + 6), anchor: .topLeading)
                ctx.draw(Text("L (workers)").font(.system(size: 11, weight: .medium)).foregroundColor(Color.secondary),
                         at: CGPoint(x: size.width * 0.55, y: size.height - 10), anchor: .center)

                // Inflection label
                Draw.label(&c, dc: dc, q: 5.3, p: tp(5) + 2, text: "DMR kicks in", color: .orange.opacity(0.8), anchor: .leading, dx: 0, dy: 0)
            }
            .frame(height: 230)
            .padding(.horizontal, 4)

            Divider().padding(.vertical, 4)

            // MP and AP diagram
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 12, p0: 0, p1: 20)
                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                Draw.curve(&c, dc: dc, fn: mp, from: 0, to: 11, color: .red, lw: 2.5)
                Draw.curve(&c, dc: dc, fn: ap, from: 0.5, to: 11, color: .teal, lw: 2)

                // Current worker
                Draw.vGuide(&c, dc: dc, q: workers, p0: 0, p1: mp(workers))
                Draw.dot(&c, dc: dc, q: workers, p: mp(workers), r: 4.5, fill: .red)
                Draw.dot(&c, dc: dc, q: workers, p: ap(workers), r: 4, fill: .teal)

                // Max AP (where MP = AP)
                Draw.dot(&c, dc: dc, q: 5, p: ap(5), r: 4.5, fill: .orange)

                Draw.label(&c, dc: dc, q: 11, p: mp(11) + 0.5, text: "MP", color: .red)
                Draw.label(&c, dc: dc, q: 11, p: ap(11) + 0.5, text: "AP", color: .teal)

                ctx.draw(Text("Output / worker").font(.system(size: 11, weight: .medium)).foregroundColor(Color.secondary),
                         at: CGPoint(x: DC.lm + 6, y: DC.tm + 6), anchor: .topLeading)
            }
            .frame(height: 190)
            .padding(.horizontal, 4)

            HStack {
                Text("Workers L = \(Int(workers))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("TP = \(tp(workers), specifier: "%.0f")  ·  MP = \(mp(workers), specifier: "%.1f")  ·  AP = \(ap(workers), specifier: "%.1f")")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            Slider(value: $workers, in: 0.5...11, step: 0.5)
                .tint(.blue)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
        .diagramCard(tint: .blue)
        .onAppear { progress.recordExploreOpened(sectionId: "production") }
    }
}

// MARK: - LRATC / scale diagram

struct LRATCDiagramView: View {
    @State private var scale: Double = 6   // 1-11, firm's chosen scale
    @EnvironmentObject private var progress: ProgressStore

    // Family of SRATC curves; each centred at its optimal Q
    private let plants: [(center: Double, minCost: Double)] = [
        (3, 14), (5, 11), (7, 9), (9, 9.5), (11, 11)
    ]
    private func sratc(_ q: Double, plant: (center: Double, minCost: Double)) -> Double {
        let c = plant.center, m = plant.minCost
        return m + 1.2 * pow(q - c, 2) / (c * c) * 8
    }
    // LRATC envelope: min over plants
    private func lratc(_ q: Double) -> Double {
        plants.map { sratc(q, plant: $0) }.min() ?? 12
    }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 14, p0: 0, p1: 26)
                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)

                // SRATC curves (faint)
                for plant in plants {
                    Draw.curve(&c, dc: dc,
                               fn: { q in sratc(q, plant: plant) },
                               from: max(0.5, plant.center - 4),
                               to: min(13, plant.center + 4),
                               color: .secondary.opacity(0.35), lw: 1.5)
                }

                // Highlighted chosen SRATC
                let chosen = plants.min(by: { abs($0.center - scale) < abs($1.center - scale) }) ?? plants[2]
                Draw.curve(&c, dc: dc,
                           fn: { q in sratc(q, plant: chosen) },
                           from: max(0.5, chosen.center - 4.5),
                           to: min(13, chosen.center + 4.5),
                           color: .blue.opacity(0.65), lw: 2.2)

                // LRATC
                Draw.curve(&c, dc: dc, fn: lratc, from: 1, to: 13, color: .orange, lw: 2.5)

                // Chosen scale guide
                let lratcNow = lratc(scale)
                Draw.vGuide(&c, dc: dc, q: scale, p0: 0, p1: lratcNow)
                Draw.dot(&c, dc: dc, q: scale, p: lratcNow, r: 5, fill: .orange)

                // Min LRATC region
                Draw.dot(&c, dc: dc, q: 7, p: lratc(7), r: 5, fill: .green)
                Draw.label(&c, dc: dc, q: 7.2, p: lratc(7) - 1.5, text: "MES", color: .green.opacity(0.8), dx: 4, dy: 0)

                // Phase annotation
                let phase: (String, Color) = scale < 6.5
                    ? ("Economies of scale (LRATC ↓)", .green.opacity(0.7))
                    : scale > 8.5
                        ? ("Diseconomies of scale (LRATC ↑)", .red.opacity(0.7))
                        : ("Constant returns", .orange.opacity(0.7))
                ctx.draw(Text(phase.0).font(.system(size: 10, weight: .semibold)).foregroundColor(phase.1),
                         at: CGPoint(x: dc.s.width * 0.55, y: DC.tm + 18), anchor: .center)

                // Labels
                Draw.label(&c, dc: dc, q: 13, p: lratc(13) + 0.5, text: "LRATC", color: .orange)
                Draw.label(&c, dc: dc, q: chosen.center + 3.5, p: sratc(chosen.center + 3.5, plant: chosen) + 0.5, text: "SRATC", color: .blue.opacity(0.6))
                Draw.qLabel(&c, dc: dc, q: scale, label: "Q", color: .secondary)
            }
            .frame(height: 360)
            .padding(.horizontal, 4)

            HStack {
                Text("Chosen scale Q = \(scale, specifier: "%.0f")")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
                Spacer()
                Text("LRATC = \(lratc(scale), specifier: "$.2f")")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16).padding(.top, 8)
            Slider(value: $scale, in: 1...12, step: 0.5)
                .tint(.orange).padding(.horizontal, 16).padding(.bottom, 10)
        }
        .diagramCard(tint: .orange)
        .onAppear { progress.recordExploreOpened(sectionId: "long-run-costs") }
    }
}

// MARK: - Profit (TR vs TC) diagram

struct ProfitDiagramView: View {
    @State private var chosenQ: Double = 7
    @EnvironmentObject private var progress: ProgressStore

    private let price = 14.0
    private func tr(_ q: Double) -> Double { price * q }
    private func tc(_ q: Double) -> Double { EconCurveModel.shortRunTotalCost(q) }
    private func profit(_ q: Double) -> Double { tr(q) - tc(q) }

    private var breakEven1: Double {
        var lo = 0.5, hi = 4.0
        for _ in 0..<60 { let m = (lo+hi)/2; if profit(m) < 0 { lo = m } else { hi = m } }
        return (lo+hi)/2
    }
    private var breakEven2: Double {
        var lo = 7.0, hi = 14.0
        for _ in 0..<60 { let m = (lo+hi)/2; if profit(m) > 0 { lo = m } else { hi = m } }
        return (lo+hi)/2
    }

    var body: some View {
        VStack(spacing: 0) {
            Canvas { ctx, size in
                var c = ctx
                let dc = DC(s: size, q0: 0, q1: 15, p0: 0, p1: 230)

                // Profit shading
                Draw.shade(&c, dc: dc, top: tr, bot: tc,
                           from: breakEven1, to: min(breakEven2, 14), color: .green.opacity(0.13))

                Draw.grid(&c, dc: dc)
                Draw.axes(&c, dc: dc)
                Draw.curve(&c, dc: dc, fn: tr, from: 0, to: 14, color: .blue, lw: 2.5)
                Draw.curve(&c, dc: dc, fn: tc, from: 0, to: 14, color: .red, lw: 2.5)

                // Q guide
                Draw.vGuide(&c, dc: dc, q: chosenQ, p0: 0, p1: max(tr(chosenQ), tc(chosenQ)))
                Draw.dot(&c, dc: dc, q: chosenQ, p: tr(chosenQ), r: 4.5, fill: .blue)
                Draw.dot(&c, dc: dc, q: chosenQ, p: tc(chosenQ), r: 4.5, fill: .red)

                // Break-even dots
                Draw.dot(&c, dc: dc, q: breakEven1, p: tr(breakEven1), r: 4, fill: .secondary)
                Draw.dot(&c, dc: dc, q: breakEven2, p: tr(breakEven2), r: 4, fill: .secondary)

                Draw.regionLabel(&c, dc: dc, q: (breakEven1 + breakEven2)*0.5, p: 120, text: "Profit", color: .green.opacity(0.7))

                // Labels
                Draw.label(&c, dc: dc, q: 14, p: tr(14) + 3, text: "TR", color: .blue)
                Draw.label(&c, dc: dc, q: 14, p: tc(14) - 8, text: "TC", color: .red)

                // Y axis override label
                ctx.draw(Text("$").font(.system(size: 12, weight: .semibold)).foregroundColor(Color.secondary),
                         at: CGPoint(x: DC.lm, y: max(8, DC.tm - 16)), anchor: .center)
            }
            .frame(height: 360)
            .padding(.horizontal, 4)

            HStack {
                Text("Q = \(chosenQ, specifier: "%.1f")  ·  Profit = \(profit(chosenQ), specifier: "$%.1f")")
                    .font(.caption.monospacedDigit()).foregroundStyle(profit(chosenQ) >= 0 ? .green : .red)
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 8)
            Slider(value: $chosenQ, in: 0.5...14, step: 0.25)
                .tint(.blue).padding(.horizontal, 16).padding(.bottom, 10)
        }
        .diagramCard(tint: .green)
        .onAppear { progress.recordExploreOpened(sectionId: "cost-revenue-profit") }
    }
}

// MARK: - Lesson → diagram mapping

private let lessonDiagramSection: [String: String] = [
    // Production
    "prod-measures": "production",
    "prod-mc-link":  "production",
    // Short-run costs
    "src-fixed-variable": "short-run-costs",
    "src-per-unit":       "short-run-costs",
    "src-table-skill":    "short-run-costs",
    // Cost-revenue-profit
    "crp-revenue":     "cost-revenue-profit",
    "crp-profit-types":"cost-revenue-profit",
    "crp-maximize":    "cost-revenue-profit",
    // Long-run
    "lr-lratc":         "long-run-costs",
    "lr-returns-scale": "long-run-costs",
    // Perfect competition
    "pc-structure":    "perfect-competition",
    "pc-profit-max":   "perfect-competition",
    "pc-lr-adjustment":"perfect-competition",
    // Monopoly
    "mono-structure":       "monopoly",
    "mono-mreqmc":          "monopoly",
    "mono-dwl-regulation":  "monopoly",
    // Monopolistic competition
    "mc-structure":      "monopolistic-competition",
    "mc-lr-efficiency":  "monopolistic-competition",
]

// MARK: - Section diagram dispatcher

struct SectionDiagram: View {
    let sectionId: String
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        Group {
            switch sectionId {
            case "production":             ProductionDiagramView()
            case "short-run-costs":        CostCurvesDiagramView()
            case "cost-revenue-profit":    ProfitDiagramView()
            case "long-run-costs":         LRATCDiagramView()
            case "perfect-competition":    PCFirmDiagramView()
            case "monopoly":               MonopolyDiagramView()
            case "monopolistic-competition": MonCompDiagramView()
            default: EmptyView()
            }
        }
        .environmentObject(progress)
    }
}

/// Returns whether `lessonId` has an associated diagram.
func lessonHasDiagram(_ lessonId: String) -> Bool {
    lessonDiagramSection[lessonId] != nil
}

/// Returns the section ID whose diagram should accompany `lessonId`.
func diagramSectionId(for lessonId: String) -> String? {
    lessonDiagramSection[lessonId]
}
