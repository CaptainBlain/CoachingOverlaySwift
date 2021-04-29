// Copyright (c) 2015-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

/// This structure handle the parametrization of a given coach mark.
/// It doesn't provide any clue about the way it will look, however.
public struct CoachMark {
    // MARK: - Public properties
    /// The path to cut in the overlay, so the point of interest will be visible.
    public var cutoutPath: UIBezierPath?

    /// The orientation of the arrow, around the body of the coach mark (top or bottom).
    public var arrowOrientation: PeakSide?

    /// The "point of interest" toward which the arrow will point.
    ///
    /// At the moment, it's only used to shift the arrow horizontally and make it sits above/below
    /// the point of interest.
    public var pointOfInterest: CGPoint?

    /// Offset between the coach mark and the cutout path.
    public var gapBetweenCoachMarkAndCutoutPath: CGFloat = 2.0

    /// Maximum width for a coach mark.
    public var maxWidth: CGFloat = 350

    /// Trailing and leading margin of the coach mark.
    public var horizontalMargin: CGFloat = 20

    /// Set this property to `true` to display the coach mark over the cutoutPath.
    public var isDisplayedOverCutoutPath: Bool = false

    /// Set this property to `true` to allow touch forwarding inside the cutoutPath.
    ///
    /// If you need to enable cutout interaction for all the coachmarks,
    /// prefer setting
    /// `CoachMarkController.isUserInteractionEnabledInsideCutoutPath`
    /// to `true`.
    public var isUserInteractionEnabledInsideCutoutPath: Bool = false

    // MARK: - Initialization
    /// Allocate and initialize a Coach mark with default values.
    public init () {
    }

    internal func ceiledMaxWidth(in frame: CGRect) -> CGFloat {
        return min(maxWidth, frame.width - 2 * horizontalMargin)
    }

    // MARK: - Renamed Properties
    // swiftlint:disable unused_setter_value
    @available(*, unavailable, renamed: "isDisplayedOverCutoutPath")
    public var displayOverCutoutPath: Bool {
        get { return false }
        set {}
    }

    @available(*, unavailable, renamed: "isUserInteractionEnabledInsideCutoutPath")
    public var allowTouchInsideCutoutPath: Bool {
        get { return false }
        set {}
    }
}

extension CoachMark: Equatable {}
