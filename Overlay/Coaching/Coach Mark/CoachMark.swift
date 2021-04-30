//
//  CoachMark.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//

import UIKit

/// This structure handle the parametrization of a given coach mark.
/// It doesn't provide any clue about the way it will look, however.
public struct CoachMark {
    // MARK: - Public properties
    /// The path to cut in the overlay, so the point of interest will be visible.
    public var cutoutPath: UIBezierPath?


    /// The "point of interest" toward which the arrow will point.
    ///
    /// At the moment, it's only used to shift the arrow horizontally and make it sits above/below
    /// the point of interest.
    public var pointOfInterest: CGPoint?

    /// Offset between the coach mark and the cutout path.
    public var gapBetweenCoachMarkAndCutoutPath: CGFloat = 6.0

    /// Maximum width for a coach mark.
    public var maxWidth: CGFloat = 350

    /// Trailing and leading margin of the coach mark.
    public var horizontalMargin: CGFloat = 2

    /// Set this property to `true` to allow touch forwarding inside the cutoutPath.
    public var isUserInteractionEnabledInsideCutoutPath: Bool = false

    // MARK: - Initialization
    /// Allocate and initialize a Coach mark with default values.
    public init () {
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
