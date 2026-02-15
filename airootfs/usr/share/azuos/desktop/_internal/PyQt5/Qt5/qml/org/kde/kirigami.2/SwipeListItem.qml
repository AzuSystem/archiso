/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "private" as P
import "templates" as T

/**
 * An item delegate that shows actions on the right side, which are, on mobile mode,
 * obtainable by dragging away the item with the handle. If the app is not in mobile mode,
 * the actions are always shown to the user.
 *
 * Example usage:
 * @code{.qml}
 * ListView {
 *     model: myModel
 *     delegate: SwipeListItem {
 *         QQC2.Label {
 *             text: model.text
 *         }
 *         actions: [
 *              Action {
 *                  icon.name: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  icon.name: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 *
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/hig/components/editing/list">KDE Human Interface Guidelines on List Views and List Items</a>
 * @inherit kirigami::templates::SwipeListItem
 */
T.SwipeListItem {
    id: listItem

    background: P.DefaultListItemBackground {}
}
