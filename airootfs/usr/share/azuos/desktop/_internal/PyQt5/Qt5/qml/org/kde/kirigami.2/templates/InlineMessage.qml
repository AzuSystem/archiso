/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Templates 2.0 as T2
import org.kde.kirigami 2.20 as Kirigami
import "private"

/**
 * @brief An inline message Item with support for informational, positive,
 * warning and error types, and with support for associated actions.
 *
 * InlineMessage can be used to inform or interact with the user
 * without requiring the use of a dialog.
 *
 * The InlineMessage is hidden by default. It also manages its
 * height (and implicitHeight) during an animated reveal when shown.
 * You should avoid setting height on an InlineMessage unless it is
 * already visible.
 *
 * Optionally an icon can be set, defaulting to an icon appropriate
 * to the message type otherwise.
 *
 * Optionally, actions can be added which are shown alongside an
 * optional close button on the right side of the Item. If more
 * actions are set than can fit, an overflow menu is provided.
 *
 * Example usage:
 * @code{.qml}
 * InlineMessage {
 *     type: Kirigami.MessageType.Error
 *
 *     text: "My error message"
 *
 *     actions: [
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *     ]
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/docs/getting-started/kirigami/components-inlinemessages">Inline Messages in Kirigami</a>
 * @see <a href="https://develop.kde.org/hig/components/assistance/inline">KDE Human Interface Guidelines on Inline Messages</a>
 * @since KDE Frameworks 5.45
 * @inherit QtQuick.Controls.Control
 */
T2.Control {
    id: root

    visible: false

    /**
     * @brief This signal is emitted when a link is hovered in the message text.
     * @param The hovered link.
     */
    signal linkHovered(string link)

    /**
     * @brief This signal is emitted when a link is clicked or tapped in the message text.
     * @param The clicked or tapped link.
     */
    signal linkActivated(string link)

    /**
     * @brief This property holds the link embedded in the message text that the user is hovering over.
     */
    readonly property string hoveredLink: label.hoveredLink

    /**
     * @brief This property holds the message type.
     *
     * The following values are allowed:
     * * ``Kirigami.MessageType.Information``
     * * ``Kirigami.MessageType.Positive``
     * * ``Kirigami.MessageType.Warning``
     * * ``Kirigami.MessageType.Error``
     *
     * default: ``Kirigami.MessageType.Information``
     *
     * @property Kirigami.MessageType type
     */
    property int type: Kirigami.MessageType.Information

    /**
     * @brief This grouped property holds the description of an optional icon.
     *
     * If no custom icon is set, an icon appropriate to the message type
     * is shown.
     */
    property IconPropertiesGroup icon: IconPropertiesGroup {}

    /**
     * @brief This property holds the message text.
     */
    property string text

    /**
     * @brief This property holds whether the close button is displayed.
     *
     * default: ``false``
     */
    property bool showCloseButton: false

    /**
     * This property holds the list of Kirigami Actions to show in the inline
     * message's internal kirigami::ActionToolBar.
     *
     * Actions are added from left to right. If more actions
     * are set than can fit, an overflow menu is provided.
     */
    property list<QtObject> actions

    /**
     * @brief This property holds whether the current message item is animating.
     */
    readonly property bool animating: _animating

    /** @internal */
    property bool _animating: false

    implicitHeight: visible ? (contentLayout.implicitHeight + topPadding + bottomPadding) : 0

    padding: Kirigami.Units.smallSpacing
    // base style (such as qqc2-desktop-style) may define unique paddings for Control, reset it to uniform
    topPadding: undefined
    leftPadding: undefined
    rightPadding: undefined
    bottomPadding: undefined

    Behavior on implicitHeight {
        enabled: !root.visible

        SequentialAnimation {
            PropertyAction { targets: root; property: "_animating"; value: true }
            NumberAnimation { duration: Kirigami.Units.longDuration }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            contentLayout.opacity = 0;
        }
    }

    opacity: visible ? 1 : 0

    Behavior on opacity {
        enabled: !root.visible

        NumberAnimation { duration: Kirigami.Units.shortDuration }
    }

    onOpacityChanged: {
        if (opacity === 0) {
            contentLayout.opacity = 0;
        } else if (opacity === 1) {
            contentLayout.opacity = 1;
        }
    }

    onImplicitHeightChanged: {
        height = implicitHeight;
    }

    contentItem: Item {
        id: contentLayout

        // Used to defer opacity animation until we know if InlineMessage was
        // initialized visible.
        property bool complete: false

        Behavior on opacity {
            enabled: root.visible && contentLayout.complete

            SequentialAnimation {
                NumberAnimation { duration: Kirigami.Units.shortDuration * 2 }
                PropertyAction { targets: root; property: "_animating"; value: false }
            }
        }

        implicitHeight: {
            if (actionsLayout.atBottom) {
                return label.implicitHeight + actionsLayout.height + Kirigami.Units.gridUnit
            } else {
                return Math.max(icon.implicitHeight, label.implicitHeight, closeButton.implicitHeight, actionsLayout.height)
            }
        }

        readonly property real remainingWidth: width - (
            icon.width
            + labelArea.anchors.leftMargin + label.implicitWidth + labelArea.anchors.rightMargin
            + (root.showCloseButton ? closeButton.width : 0)
        )
        readonly property bool multiline: remainingWidth <= 0 || actionsLayout.atBottom

        Kirigami.Icon {
            id: icon

            width: Kirigami.Units.iconSizes.smallMedium
            height: Kirigami.Units.iconSizes.smallMedium

            anchors {
                left: parent.left
                top: actionsLayout.atBottom ? parent.top : undefined
                verticalCenter: actionsLayout.atBottom ? undefined : parent.verticalCenter
            }

            source: {
                if (root.icon.name) {
                    return root.icon.name;
                } else if (root.icon.source) {
                    return root.icon.source;
                }

                if (root.type === Kirigami.MessageType.Positive) {
                    return "dialog-positive";
                } else if (root.type === Kirigami.MessageType.Warning) {
                    return "dialog-warning";
                } else if (root.type === Kirigami.MessageType.Error) {
                    return "dialog-error";
                }

                return "dialog-information";
            }

            color: root.icon.color
        }

        MouseArea {
            id: labelArea

            anchors {
                left: icon.right
                leftMargin: Kirigami.Units.smallSpacing
                right: root.showCloseButton ? closeButton.left : parent.right
                rightMargin: root.showCloseButton ? Kirigami.Units.smallSpacing : 0
                top: parent.top
                bottom: contentLayout.multiline ? undefined : parent.bottom
            }

            acceptedButtons: Qt.NoButton
            cursorShape: label.hoveredLink.length > 0 ? Qt.PointingHandCursor : undefined
            propagateComposedEvents: true

            implicitWidth: label.implicitWidth
            height: contentLayout.multiline ? label.implicitHeight : implicitHeight

            Kirigami.SelectableLabel {
                id: label

                width: parent.width
                height: parent.height

                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap

                text: root.text

                verticalAlignment: Text.AlignVCenter

                onLinkHovered: link => root.linkHovered(link)
                onLinkActivated: link => root.linkActivated(link)
            }
        }

        Kirigami.ActionToolBar {
            id: actionsLayout

            flat: false
            actions: root.actions
            visible: root.actions.length > 0
            alignment: Qt.AlignRight

            readonly property bool atBottom: (root.actions.length > 0) && (label.lineCount > 1 || implicitWidth > contentLayout.remainingWidth)

            anchors {
                left: parent.left
                top: atBottom ? labelArea.bottom : parent.top
                topMargin: atBottom ? Kirigami.Units.gridUnit : 0
                right: (!atBottom && root.showCloseButton) ? closeButton.left : parent.right
                rightMargin: !atBottom && root.showCloseButton ? Kirigami.Units.smallSpacing : 0
            }
        }

        QQC2.ToolButton {
            id: closeButton

            visible: root.showCloseButton

            anchors {
                right: parent.right
                top: actionsLayout.atBottom ? parent.top : undefined
                verticalCenter: actionsLayout.atBottom ? undefined : parent.verticalCenter
            }

            height: actionsLayout.atBottom ? implicitHeight : implicitHeight

            icon.name: "dialog-close"

            onClicked: root.visible = false
        }

        Component.onCompleted: complete = true
    }
}
