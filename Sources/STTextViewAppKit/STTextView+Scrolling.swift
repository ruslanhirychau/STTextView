//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md


import AppKit

extension STTextView {

    override open func scroll(_ point: NSPoint) {
        contentView.scroll(point.applying(.init(translationX: -(gutterView?.frame.width ?? 0), y: 0)))
    }

    /// Adjusts a rect for scrolling by adding line fragment padding and gutter offset.
    private func adjustedScrollRect(_ rect: CGRect) -> CGRect {
        var adjusted = rect
        if adjusted.width.isZero {
            adjusted = adjusted.inset(by: .init(top: 0, left: -textContainer.lineFragmentPadding, bottom: 0, right: -textContainer.lineFragmentPadding))
        }
        adjusted.origin.x -= gutterView?.frame.width ?? 0
        adjusted.size.width += gutterView?.frame.width ?? 0
        return adjusted
    }

    @discardableResult
    func scrollToVisible(_ textRange: NSTextRange, type: NSTextLayoutManager.SegmentType) -> Bool {
        guard let rect = textLayoutManager.textSegmentFrame(in: textRange, type: type) else {
            return false
        }
        return contentView.scrollToVisible(adjustedScrollRect(rect))
    }

    @discardableResult
    func scrollToVisible(_ location: NSTextLocation, type: NSTextLayoutManager.SegmentType) -> Bool {
        guard let rect = textLayoutManager.textSegmentFrame(at: location, type: type) else {
            return false
        }
        return contentView.scrollToVisible(adjustedScrollRect(rect))
    }

    override open func centerSelectionInVisibleArea(_ sender: Any?) {
        guard let selectionTextRange = textLayoutManager.textSelections.last?.textRanges.last,
              let rect = textLayoutManager.textSegmentFrame(in: selectionTextRange, type: .selection) else {
            return
        }

        let adjusted = adjustedScrollRect(rect)
        // put rect origin in the center
        contentView.scroll(adjusted.origin.applying(.init(translationX: 0, y: -visibleRect.height / 2)))
    }

    override open func pageUp(_ sender: Any?) {
        scrollPageUp(sender)
    }

    override open func pageUpAndModifySelection(_ sender: Any?) {
        pageUp(sender)
    }

    override open func pageDown(_ sender: Any?) {
        scrollPageDown(sender)
    }

    override open func pageDownAndModifySelection(_ sender: Any?) {
        pageDown(sender)
    }

    override open func scrollPageDown(_ sender: Any?) {
        scroll(visibleRect.moved(dy: visibleRect.height).origin)
    }

    override open func scrollPageUp(_ sender: Any?) {
        scroll(visibleRect.moved(dy: -visibleRect.height).origin)
    }

    override open func scrollToBeginningOfDocument(_ sender: Any?) {
        scroll(CGPoint(x: visibleRect.origin.x, y: frame.minY))
    }

    override open func scrollToEndOfDocument(_ sender: Any?) {
        relocateViewport(to: textLayoutManager.documentRange.endLocation)
        scroll(CGPoint(x: visibleRect.origin.x, y: frame.maxY))
    }
}
