/*
 *  SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.14 as Kirigami

/**
 * A simple subclass of BasicListItem that adds a checkbox on the left side of
 * the layout. The list item's own
 * <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-abstractbutton.html#checked-prop">checked</a>
 * property controls the check state of the checkbox.
 *
 * When the list item or its checkbox is clicked, the QtQuick.Controls.Action
 * specified in the list item's ``actions:`` property will be triggered.
 *
 * @note Due to the way BasicListItem works, the QtQuick.Controls.Action MUST contain the
 * line "checked = !checked" as the first line within its
 * @link QtQuick.Controls.Action.triggered QtQuick.Controls.Action.onTriggered @endlink handler.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.14 as Kirigami
 *
 * ListView {
 *     id: listView
 *     model: [...]
 *     delegate: Kirigami.CheckableListItem {
 *         label: model.display
 *
 *         checked: model.checked
 *
 *         action: Action {
 *             onTriggered: {
 *                 checked = !checked
 *                 [ do something amazing ]
 *             }
 *         }
 *     }
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/hig/components/editing/list">KDE Human Interface Guidelines on List Views and List Items</a>
 * @see <a href="https://develop.kde.org/hig/components/editing/checkbox">KDE Human Interface Guidelines on Checkboxes</a>
 * @since org.kde.kirigami 2.14
 * @inherit kirigami::BasicListItem
 */
Kirigami.BasicListItem {
    id: checkableListItem

    checkable: true
    activeBackgroundColor: "transparent"
    activeTextColor: Kirigami.Theme.textColor
    iconSelected: false

    leading: QQC2.CheckBox {
        checked: checkableListItem.checked
        onToggled: {
            checkableListItem.checked = !checkableListItem.checked

            // TODO(Qt6): rephrase as `checkableListItem.action?.trigger();`
            if (checkableListItem.action) {
                checkableListItem.action.trigger();
            }
        }
    }
}
