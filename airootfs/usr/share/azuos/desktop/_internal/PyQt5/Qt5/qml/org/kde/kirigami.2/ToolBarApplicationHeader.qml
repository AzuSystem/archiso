/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private" as P


// TODO KF6: Remove!
/**
 * @brief ToolBarApplicationHeader represents a toolbar that
 * will display the actions of the current page.
 *
 * Both Contextual actions and the main, left and right actions
 *
 * @deprecated This will be removed in KF6.
 */
ApplicationHeader {
    id: header

    preferredHeight: 42
    maximumHeight: preferredHeight
    headerStyle: ApplicationHeaderStyle.Titles

    // FIXME: needs a property definition to have its own type in qml
    /** @internal */
    property string _internal: ""

    Component.onCompleted: print("Warning: ToolbarApplicationHeader is deprecated, remove and use the automatic internal toolbar instead.")
    pageDelegate: Item {
        id: delegateItem
        readonly property bool current: __appWindow.pageStack.currentIndex === index
        implicitWidth: titleTextMetrics.width/2 + buttonTextMetrics.collapsedButtonsWidth

        RowLayout {
            id: titleLayout
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: actionsLayout.left
            }
            Kirigami.Separator {
                id: separator
                Layout.preferredHeight: parent.height * 0.6
            }

            Kirigami.Heading {
                id: title
                Layout.fillWidth: true

                Layout.preferredWidth: implicitWidth
                Layout.minimumWidth: Math.min(titleTextMetrics.width, delegateItem.width - buttonTextMetrics.requiredWidth)
                leftPadding: Kirigami.Units.largeSpacing
                opacity: delegateItem.current ? 1 : 0.4
                maximumLineCount: 1
                color: Kirigami.Theme.textColor
                elide: Text.ElideRight
                text: page ? page.title : ""
            }
        }

        TextMetrics {
            id: titleTextMetrics
            text: page ? page.title : ""
            font: title.font
        }
        TextMetrics {
            id: buttonTextMetrics
            text: (page.actions.left ? page.actions.left.text : "") + (page.actions.main ? page.actions.main.text : "") + (page.actions.right ? page.actions.right.text : "")
            readonly property int collapsedButtonsWidth: ctxActionsButton.width + (page.actions.left ? ctxActionsButton.width + Kirigami.Units.gridUnit : 0) + (page.actions.main ? ctxActionsButton.width + Kirigami.Units.gridUnit : 0) + (page.actions.right ? ctxActionsButton.width + Kirigami.Units.gridUnit : 0)
            readonly property int requiredWidth: width + collapsedButtonsWidth
        }

        RowLayout {
            id: actionsLayout
            anchors {
                verticalCenter: parent.verticalCenter
                right: ctxActionsButton.visible ? ctxActionsButton.left : parent.right
            }

            readonly property bool toobig: delegateItem.width - titleTextMetrics.width - Kirigami.Units.gridUnit < buttonTextMetrics.requiredWidth

            P.PrivateActionToolButton {
                Layout.alignment: Qt.AlignVCenter
                action: page && page.actions ? page.actions.left : null
                display: parent.toobig ? QQC2.AbstractButton.IconOnly : QQC2.AbstractButton.TextBesideIcon
            }
            P.PrivateActionToolButton {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Kirigami.Units.smallSpacing
                action: page && page.actions ? page.actions.main : null
                display: parent.toobig ? QQC2.AbstractButton.IconOnly : QQC2.AbstractButton.TextBesideIcon
                flat: false
            }
            P.PrivateActionToolButton {
                Layout.alignment: Qt.AlignVCenter
                action: page && page.actions ? page.actions.right : null
                display: parent.toobig ? QQC2.AbstractButton.IconOnly : QQC2.AbstractButton.TextBesideIcon
            }
        }

        P.PrivateActionToolButton {
            id: ctxActionsButton
            showMenuArrow: page.actions.contextualActions.length === 1
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: Kirigami.Units.smallSpacing
            }
            Kirigami.Action {
                id: overflowAction
                icon.name: "overflow-menu"
                tooltip: qsTr("More Actions")
                visible: children.length > 0
                children: page && page.actions.contextualActions ? page.actions.contextualActions : null
            }

            action: page && page.actions.contextualActions.length === 1 ? page.actions.contextualActions[0] : overflowAction
        }
    }
}
