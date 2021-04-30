//
//  CoachMarksControllerDataSource.swift
//  Overlay
//
//  Created by Blain Ellis on 28/04/2021.
//


import UIKit

/// Describe how a coachmark datasource should behave.
/// It works a bit like `UITableViewDataSource`.
public protocol CoachMarksControllerDataSource: AnyObject {

    /// Asks for the metadata of the coach mark that will be displayed
    ///
    /// - Parameter coachMarksController: the coach mark controller requesting the information.
    ///
    /// - Returns: the coach mark
    func getCoachMark(for coachMarksController: CoachMarkController) -> CoachMark

    /// Asks for the views defining the coach mark that will be displayed in
    ///
    /// - Parameter coachMarksController: the coach mark controller requesting
    ///                                   the information.
    /// - Returns: a coach mark bubble
    func getCoachMarkBubble(for coachMarksController: CoachMarkController) -> CoachMarkBubble

    /// Asks for the views defining the coach mark that will be displayed in
    ///
    /// - Parameter coachMarksController: the coach mark controller requesting
    ///                                   the information.
    /// - Returns: a coach mark bubble
    func getCoachMarkBubbleHorizontalAlignment(for coachMarksController: CoachMarkController) -> HorizontalAlignment
}


internal protocol CoachMarksControllerProxyDataSource: AnyObject {

    func coachMark() -> CoachMark

    func coachMarkBubble() -> CoachMarkBubble
    
    func coachMarkBubbleHorizontalAlignment() -> HorizontalAlignment

}
