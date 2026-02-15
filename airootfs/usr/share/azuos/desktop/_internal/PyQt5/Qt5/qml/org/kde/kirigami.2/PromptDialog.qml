/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

/**
 * A simple dialog to quickly prompt a user with information,
 * and possibly perform an action.
 *
 * Provides content padding (instead of padding outside of the scroll
 * area). Also has a default Dialog::preferredWidth, as well as the ::subtitle property.
 *
 * <b>Note:</b> If a ::mainItem is specified, it will replace
 * the ::subtitle label, and so the respective property will have no effect.
 *
 * Example usage:
 * @code{.qml}
 * Kirigami.PromptDialog {
 *     title: "Reset settings?"
 *     subtitle: "The stored settings for the application will be deleted, with the defaults restored."
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     onAccepted: console.log("Accepted")
 *     onRejected: console.log("Rejected")
 * }
 * @endcode
 *
 * Text field prompt dialog:
 * @code{.qml}
 * Kirigami.PromptDialog {
 *     id: textPromptDialog
 *     title: "New Folder"
 *
 *     standardButtons: Kirigami.Dialog.NoButton
 *     customFooterActions: [
 *         Kirigami.Action {
 *             text: qsTr("Create Folder")
 *             iconName: "dialog-ok"
 *             onTriggered: {
 *                 showPassiveNotification("Created");
 *                 textPromptDialog.close();
 *             }
 *         },
 *         Kirigami.Action {
 *             text: qsTr("Cancel")
 *             iconName: "dialog-cancel"
 *             onTriggered: {
 *                 textPromptDialog.close();
 *             }
 *         }
 *     ]
 *
 *     QQC2.TextField {
 *         placeholderText: qsTr("Folder name...")
 *     }
 * }
 * @endcode
 * @see kirigami::Dialog
 * @see kirigami::MenuDialog
 * @see <a href="https://develop.kde.org/hig/components/navigation/dialog">Human Interface Guidelines on Dialogs</a>
 * @see <a href="https://develop.kde.org/hig/components/assistance/message">Human Interface Guidelines on Modal Message Dialogs</a>
 * @inherit kirigami::Dialog
 */
Kirigami.Dialog {
    default property alias mainItem: control.contentItem

    /**
     * The text to use in the dialog's contents.
     */
    property string subtitle

    /**
     * The padding around the content, within the scroll area.
     *
     * Default is `Kirigami.Units.largeSpacing`.
     */
    property real contentPadding: Kirigami.Units.largeSpacing

    /**
     * The top padding of the content, within the scroll area.
     */
    property real contentTopPadding: contentPadding

    /**
     * The bottom padding of the content, within the scroll area.
     */
    property real contentBottomPadding: contentPadding

    /**
     * The left padding of the content, within the scroll area.
     */
    property real contentLeftPadding: contentPadding

    /**
     * The right padding of the content, within the scroll area.
     */
    property real contentRightPadding: contentPadding

    padding: 0 // we want content padding, not padding of the scrollview
    preferredWidth: Kirigami.Units.gridUnit * 18

    QQC2.Control {
        id: control
        topPadding: contentTopPadding
        bottomPadding: contentBottomPadding
        leftPadding: contentLeftPadding
        rightPadding: contentRightPadding

        contentItem: Kirigami.SelectableLabel {
            text: subtitle
            wrapMode: QQC2.Label.Wrap
        }
    }
}
