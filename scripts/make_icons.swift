// Draws the extension icons into icons/ (16, 32, 48 and 128 px). Run from the
// repository root:  swift scripts/make_icons.swift
//
// The picture is the extension's own behaviour: chrome-less panes stepping
// down and to the right, the way each popped page lands 36px from the last.
// Two panes at the toolbar sizes (16, 32), three where there is room for the
// staircase. Each size has its own pixel geometry so the 16px toolbar icon
// stays sharp instead of being a blurred copy of the 128, and a tile-coloured
// ring is knocked out around each front pane so overlapping panes stay
// separate even at 16px.
//
// The 128 follows the Chrome Web Store rule of 96px of artwork inside 16px of
// transparent padding; the toolbar sizes use the whole square.
import AppKit
import CoreGraphics

struct Pane { let x, y, w, h: CGFloat; let alpha: CGFloat }
struct Spec { let size: Int; let pad, radius, paneRadius, gap: CGFloat; let panes: [Pane] }

// Pane rects are tile-relative, top-left origin, back to front.
let specs: [Spec] = [
    Spec(size: 16, pad: 0, radius: 3.5, paneRadius: 1, gap: 1, panes: [
        Pane(x: 3, y: 4, w: 7, h: 6, alpha: 0.55),
        Pane(x: 6, y: 7, w: 7, h: 6, alpha: 1.0)]),
    Spec(size: 32, pad: 0, radius: 7, paneRadius: 2, gap: 1, panes: [
        Pane(x: 5, y: 6, w: 15, h: 13, alpha: 0.55),
        Pane(x: 12, y: 13, w: 15, h: 13, alpha: 1.0)]),
    Spec(size: 48, pad: 4, radius: 9, paneRadius: 2, gap: 1, panes: [
        Pane(x: 6, y: 7, w: 16, h: 13, alpha: 0.35),
        Pane(x: 12, y: 13, w: 16, h: 13, alpha: 0.62),
        Pane(x: 18, y: 19, w: 16, h: 13, alpha: 1.0)]),
    Spec(size: 128, pad: 16, radius: 21, paneRadius: 4, gap: 3, panes: [
        Pane(x: 14, y: 18, w: 40, h: 32, alpha: 0.35),
        Pane(x: 28, y: 32, w: 40, h: 32, alpha: 0.62),
        Pane(x: 42, y: 46, w: 40, h: 32, alpha: 1.0)]),
]

let rgb = CGColorSpace(name: CGColorSpace.sRGB)!
func color(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: rgb, components: [CGFloat(r)/255, CGFloat(g)/255, CGFloat(b)/255, a])!
}
let tileTop = color(74, 139, 163), tileBottom = color(42, 94, 116)
let cream = (247, 242, 232)

func render(_ s: Spec) -> CGImage {
    let S = CGFloat(s.size)
    let ctx = CGContext(data: nil, width: s.size, height: s.size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: rgb, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.translateBy(x: 0, y: S)
    ctx.scaleBy(x: 1, y: -1)

    let tile = CGRect(x: s.pad, y: s.pad, width: S - 2*s.pad, height: S - 2*s.pad)
    let tilePath = CGPath(roundedRect: tile, cornerWidth: s.radius, cornerHeight: s.radius, transform: nil)
    let gradient = CGGradient(colorsSpace: rgb, colors: [tileTop, tileBottom] as CFArray, locations: [0, 1])!

    func paintTile(clip: CGPath) {
        ctx.saveGState()
        ctx.addPath(tilePath); ctx.clip()
        ctx.addPath(clip); ctx.clip()
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: tile.minY),
                               end: CGPoint(x: 0, y: tile.maxY), options: [])
        ctx.restoreGState()
    }
    paintTile(clip: tilePath)

    for (i, p) in s.panes.enumerated() {
        let r = CGRect(x: tile.minX + p.x, y: tile.minY + p.y, width: p.w, height: p.h)
        if i > 0 {
            let ring = r.insetBy(dx: -s.gap, dy: -s.gap)
            paintTile(clip: CGPath(roundedRect: ring, cornerWidth: s.paneRadius + s.gap,
                                   cornerHeight: s.paneRadius + s.gap, transform: nil))
        }
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: s.paneRadius, cornerHeight: s.paneRadius, transform: nil))
        ctx.setFillColor(color(cream.0, cream.1, cream.2, p.alpha))
        ctx.fillPath()
    }
    return ctx.makeImage()!
}

try? FileManager.default.createDirectory(atPath: "icons", withIntermediateDirectories: true)
for s in specs {
    let rep = NSBitmapImageRep(cgImage: render(s))
    try! rep.representation(using: .png, properties: [:])!
        .write(to: URL(fileURLWithPath: "icons/icon-\(s.size).png"))
    print("icons/icon-\(s.size).png")
}
