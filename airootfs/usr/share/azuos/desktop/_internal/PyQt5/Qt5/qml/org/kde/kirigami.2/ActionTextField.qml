/*
 *  SPDX-FileCopyrightText: 2019 Carl-Lucien Schwan <carl@carlschwan.eu>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami

/**
 * This is advanced textfield. It is recommended to use this class when there
 * is a need to create a create a textfield with action buttons (e.g a clear
 * action).
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.20 as Kirigami
 *
 * Kirigami.ActionTextField {
 *     id: searchField
 *
 *     placeholderText: i18n("Search…")
 *
 *     focusSequence: StandardKey.Find
 *
 *     rightActions: Kirigami.Action {
 *         icon.name: "edit-clear"
 *         visible: searchField.text !== ""
 *         onTriggered: {
 *             searchField.clear();
 *             searchField.accepted();
 *         }
 *     }
 *
 *     onAccepted: console.log("Search text is " + searchField.text);
 * }
 * @endcode
 * @since KDE Frameworks 5.56
 * @inherit QtQuick.Controls.TextField
 */
QQC2.TextField {
    id: root

    /**
     * @brief This property holds a shortcut sequence that will focus the text field.
     * @since KDE Frameworks 5.56
     */
    property alias focusSequence: focusShortcut.sequence

    /**
     * @brief This property holds a list of actions that will be displayed on the left side of the text field.
     *
     * By default, this list is empty.
     *
     * @since KDE Frameworks 5.56
     */
    property list<QtObject> leftActions

    /**
     * @brief This property holds a list of actions that will be displayed on the right side of the text field.
     *
     * By default, this list is empty.
     *
     * @since KDE Frameworks 5.56
     */
    property list<QtObject> rightActions

    /** @internal */
    property alias _leftActionsRow: leftActionsRow

    /** @internal */
    property alias _rightActionsRow: rightActionsRow

    hoverEnabled: true

    // Manually setting this fixes alignment in RTL layouts
    horizontalAlignment: TextInput.AlignLeft

    leftPadding: Kirigami.Units.smallSpacing + (root.effectiveHorizontalAlignment === TextInput.AlignRight ? rightActionsRow : leftActionsRow).width
    rightPadding: Kirigami.Units.smallSpacing + (root.effectiveHorizontalAlignment === TextInput.AlignRight ? leftActionsRow : rightActionsRow).width

    Behavior on leftPadding {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on rightPadding {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Shortcut {
        id: focusShortcut
        enabled: root.visible && root.enabled
        onActivated: {
            root.forceActiveFocus(Qt.ShortcutFocusReason)
            root.selectAll()
        }
    }

    QQC2.ToolTip {
        visible: focusShortcut.nativeText.length > 0 && root.text.length === 0 && !rightActionsRow.hovered && !leftActionsRow.hovered && hovered
        text: focusShortcut.nativeText
    }

    component ActionIconMouseArea: MouseArea {
        anchors.fill: parent
        activeFocusOnTab: true
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        Accessible.role: Accessible.Button
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                clicked(null);
                event.accepted = true;
                break;
            }
        }
    }

    Row {
        id: leftActionsRow
        padding: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: Qt.LeftToRight
        LayoutMirroring.enabled: root.effectiveHorizontalAlignment === TextInput.AlignRight
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.smallSpacing
        anchors.top: parent.top
        anchors.topMargin: parent.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.bottomPadding
        Repeater {
            model: root.leftActions
            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
                implicitHeight: Kirigami.Units.iconSizes.sizeForLabels

                anchors.verticalCenter: parent.verticalCenter

                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                active: leftActionArea.containsPress || leftActionArea.activeFocus
                visible: !(modelData instanceof Kirigami.Action) || modelData.visible
                enabled: modelData.enabled

                ActionIconMouseArea {
                    id: leftActionArea
                    Accessible.name: modelData.text
                    onClicked: mouse => modelData.trigger()
                }

                QQC2.ToolTip {
                    visible: (rightActionArea.containsMouse || rightActionArea.activeFocus) && (modelData.text.length > 0)
                    text: modelData.text
                }
            }
        }
    }

    Row {
        id: rightActionsRow
        padding: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: Qt.RightToLeft
        LayoutMirroring.enabled: root.effectiveHorizontalAlignment === TextInput.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.smallSpacing
        anchors.top: parent.top
        anchors.topMargin: parent.topPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.bottomPadding
        Repeater {
            model: root.rightActions
            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
                implicitHeight: Kirigami.Units.iconSizes.sizeForLabels

                anchors.verticalCenter: parent.verticalCenter

                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                active: rightActionArea.containsPress || rightActionArea.activeFocus
                visible: !(modelData instanceof Kirigami.Action) || modelData.visible
                enabled: modelData.enabled

                ActionIconMouseArea {
                    id: rightActionArea
                    Accessible.name: modelData.text
                    onClicked: mouse => modelData.trigger()
                }

                QQC2.ToolTip {
                    visible: (rightActionArea.containsMouse || rightActionArea.activeFocus) && (modelData.text.length > 0)
                    text: modelData.text
                }
            }
        }
    }
}
