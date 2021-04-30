//
//  CoachMarkBubbleView.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//


import UIKit

// swiftlint:disable force_cast

/// The actual coach mark that will be displayed.
class CoachMarkBubbleView: UIView {
    // MARK: - Internal properties

    /// The body of the coach mark (likely to contain some text).
    let bubbleView: CoachMarkBubble

    /// - Parameter bodyView

    init(_ bubbleView: CoachMarkBubble) {

        self.bubbleView = bubbleView

        super.init(frame: CGRect.zero)

        self.layoutViewComposition()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError(ErrorMessage.Fatal.doesNotSupportNSCoding)
    }

    // MARK: - Private Method

    /// Layout the body view and the arrow view together.
    private func layoutViewComposition() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(bubbleView)
        addConstraints(bubbleView.makeConstraintToFillSuperviewHorizontally())

        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}



