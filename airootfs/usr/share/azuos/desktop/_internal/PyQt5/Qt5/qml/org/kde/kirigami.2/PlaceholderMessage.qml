/*
 *  SPDX-FileCopyrightText: 2020 by Nate Graham <nate@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import "private" as P

/**
 * @brief A placeholder message indicating that a view is empty.
 *
 * The message comprises a label with text, an optional explanation below the main text,
 * an optional icon above all the text, and an optional button below all the text which
 * can be used to easily show the user what to do next to add content to the view.
 *
 * The top-level component is a QtQuick.Layouts.ColumnLayout, so additional components items
 * can simply be added as child items and they will be positioned sanely.
 *
 * Example usage:
 ** Used as a "this view is empty" message
 * @code{.qml}
 * import org.kde.kirigami 2.12 as Kirigami
 *
 * ListView {
 *     id: listView
 *     model: [...]
 *     delegate: [...]
 *
 *     Kirigami.PlaceholderMessage {
 *         anchors.centerIn: parent
 *         width: parent.width - (Kirigami.Units.largeSpacing * 4)
 *
 *         visible: listView.count === 0
 *
 *         text: "There are no items in this list"
 *     }
 * }
 * @endcode
 *
 ** Used as a "here's how to proceed" message:
 * @code{.qml}
 * import org.kde.kirigami 2.12 as Kirigami
 *
 * ListView {
 *     id: listView
 *     model: [...]
 *     delegate: [...]
 *
 *     Kirigami.PlaceholderMessage {
 *         anchors.centerIn: parent
 *         width: parent.width - (Kirigami.Units.largeSpacing * 4)
 *
 *         visible: listView.count === 0
 *
 *         text: "Add an item to proceed"
 *
 *         helpfulAction: Kirigami.Action {
 *             icon.name: "list-add"
 *             text: "Add item..."
 *             onTriggered: {
 *                 [...]
 *             }
 *         }
 *     }
 *     [...]
 * }
 * @endcode
 *
 ** Used as a "there was a problem here" message:
 * @code{.qml}
 * import org.kde.kirigami 2.12 as Kirigami
 *
 * Kirigami.Page {
 *     id: root
 *     readonly property bool networkConnected: [...]
 *
 *     Kirigami.PlaceholderMessage {
 *         anchors.centerIn: parent
 *         width: parent.width - (Kirigami.Units.largeSpacing * 4)
 *
 *         visible: root.networkConnected
 *
 *         icon.name: "network-disconnect"
 *         text: "Unable to load content
 *         explanation: "Please try again later"
 *     }
 * }
 * @endcode
 *
 ** Used as a loading indicator:
 * @code{.qml}
 * import org.kde.kirigami 2.12 as Kirigami
 *
 * Kirigami.Page {
 *     id: root
 *     readonly property bool loading: [...]
 *     readonly property int completionStatus: [...]
 *
 *     Kirigami.PlaceholderMessage {
 *         anchors.centerIn: parent
 *         width: parent.width - (Kirigami.Units.largeSpacing * 4)
 *
 *         visible: root.loading
 *
 *         icon.name: "my-awesome-app-icon"
 *         text: "Loading this awesome app"
 *
 *         ProgressBar {
 *             Layout.preferredWidth: Kirigami.Units.gridUnit * 20
 *             value: root.completionStatus
 *             from: 0
 *             to: 100
 *         }
 *     }
 * }
 * @endcode
 *
 ** Used as a "Here's what you do next" button:
 * @code{.qml}
 * import org.kde.kirigami 2.12 as Kirigami
 *
 * Kirigami.Page {
 *     id: root
 *
 *     Kirigami.PlaceholderMessage {
 *         anchors.centerIn: parent
 *         width: parent.width - (Kirigami.Units.largeSpacing * 4)
 *
 *         visible: root.loading
 *
 *         helpfulAction: Kirigami.Action {
 *             icon.name: "list-add"
 *             text: "Add item..."
 *             onTriggered: {
 *                 [...]
 *             }
 *         }
 *     }
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/hig/patterns-content/placeholdermessage">KDE Human Interface Guidelines on Placeholder Messages</a>
 * @since org.kde.kirigami 2.12
 * @inherit QtQuick.Layouts.ColumnLayout
 */
ColumnLayout {
    id: root

    enum Type {
        Actionable,
        Informational
    }

//BEGIN properties
    /**
     * @brief This property holds the PlaceholderMessage type.
     *
     * The following values are allowed:
     * * ``Kirigami.PlaceholderMessage.Type.Actionable``: makes it more attention grabbing. Useful when the user is expected to interact with the message.
     * * ``Kirigami.PlaceholderMessage.Type.Informational``: makes it less prominent. Useful when the message is only informational.
     *
     * default: `if a ::helpfulAction is provided this will be of type Actionable otherwise of type Informational.`
     *
     * @since KDE Frameworks 5.94
     */
    property int type: actionButton.action && actionButton.action.enabled ? PlaceholderMessage.Type.Actionable : PlaceholderMessage.Type.Informational

    /**
     * @brief This property holds the text to show in the placeholder label.
     *
     * Optional; if not defined, the message will have no large text label
     * text. If both text: and explanation: are omitted, the message will have
     * no text and only an icon, action button, and/or other custom content.
     *
     * @since KDE Frameworks 5.70
     */
    property string text

    /**
     * @brief This property holds the smaller explanatory text to show below the larger title-style text
     *
     * Useful for providing a user-friendly explanation on how to proceed.
     *
     * Optional; if not defined, the message will have no supplementary
     * explanatory text.
     *
     * @since KDE Frameworks 5.80
     */
    property string explanation

    /**
     * @brief This property provides an icon to display above the top text label.
     *
     * Optional; if undefined, the message will have no icon.
     * Falls back to `undefined` if the specified icon is not valid or cannot
     * be loaded.
     *
     * @since KDE Frameworks 5.70
     */
    property P.ActionIconGroup icon: P.ActionIconGroup {}

    /**
     * @brief This property holds an action that helps the user proceed.
     *
     * Typically used to guide the user to the next step for adding
     * content or items to an empty view.
     *
     * Optional; if undefined, no button will appear below the text label.
     *
     * @property QtQuick.Controls.Action helpfulAction
     * @since KDE Frameworks 5.70
     */
    property alias helpfulAction: actionButton.action
//END properties

    spacing: Kirigami.Units.largeSpacing

    Kirigami.Icon {
        visible: source !== undefined
        opacity: 0.5

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.huge * 1.5)
        Layout.preferredHeight: Math.round(Kirigami.Units.iconSizes.huge * 1.5)

        source: {
            if (root.icon.source.length > 0) {
                return root.icon.source
            } else if (root.icon.name.length > 0) {
                return root.icon.name
            }
            return undefined
        }
    }

    Kirigami.Heading {
        text: root.text
        visible: text.length > 0

        type: Kirigami.Heading.Primary
        opacity: root.type === PlaceholderMessage.Type.Actionable ? 1 : 0.65


        Layout.fillWidth: true
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        wrapMode: Text.WordWrap
    }

    QQC2.Label {
        text: root.explanation
        visible:  root.explanation !== ""
        opacity: root.type === PlaceholderMessage.Type.Actionable ? 1 : 0.65

        horizontalAlignment: Qt.AlignHCenter
        wrapMode: Text.WordWrap

        Layout.fillWidth: true
    }

    QQC2.Button {
        id: actionButton

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: Kirigami.Units.gridUnit

        visible: action && action.enabled
    }
}
