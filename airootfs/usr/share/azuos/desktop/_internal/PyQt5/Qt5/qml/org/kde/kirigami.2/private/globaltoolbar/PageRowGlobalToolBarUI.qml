/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami
import "../../templates/private" as TP
import "../" as P

Kirigami.AbstractApplicationHeader {
    id: header
    readonly property int leftReservedSpace: (buttonsLayout.visible && buttonsLayout.visibleChildren.length > 0 ? buttonsLayout.width + Kirigami.Units.smallSpacing : 0) // Take into account the layout margins the nav buttons have
        + (leftHandleAnchor.visible ? leftHandleAnchor.width : 0)
        + (menuButton.visible ? menuButton.width : 0)
    readonly property int rightReservedSpace: rightHandleAnchor.visible ? backButton.background.implicitHeight : 0

    readonly property alias leftHandleAnchor: leftHandleAnchor
    readonly property alias rightHandleAnchor: rightHandleAnchor

    readonly property bool breadcrumbVisible: layerIsMainRow && breadcrumbLoader.active
    readonly property bool layerIsMainRow: (root.layers.currentItem.hasOwnProperty("columnView")) ? root.layers.currentItem.columnView === root.columnView : false
    readonly property Item currentItem: layerIsMainRow ? root.columnView : root.layers.currentItem

    height: visible ? implicitHeight : 0
    minimumHeight: globalToolBar.minimumHeight
    preferredHeight: globalToolBar.preferredHeight
    maximumHeight: globalToolBar.maximumHeight
    separatorVisible: globalToolBar.separatorVisible

    Kirigami.Theme.colorSet: globalToolBar.colorSet
    Kirigami.Theme.textColor: currentItem ? currentItem.Kirigami.Theme.textColor : parent.Kirigami.Theme.textColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredWidth: applicationWindow().pageStack.globalToolBar.leftReservedSpace
            visible: applicationWindow().pageStack !== root
        }

        Item {
            id: leftHandleAnchor
            visible: (typeof applicationWindow() !== "undefined" && applicationWindow().globalDrawer && applicationWindow().globalDrawer.enabled && applicationWindow().globalDrawer.handleVisible &&
            applicationWindow().globalDrawer.handle.handleAnchor === leftHandleAnchor) &&
            (globalToolBar.canContainHandles || (breadcrumbLoader.pageRow.firstVisibleItem &&
            breadcrumbLoader.pageRow.firstVisibleItem.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar))


            Layout.preferredHeight: Math.min(backButton.implicitHeight, parent.height)
            Layout.preferredWidth: height
        }

        P.PrivateActionToolButton {
            id: menuButton
            visible: !Kirigami.Settings.isMobile && applicationWindow().globalDrawer && "isMenu" in applicationWindow().globalDrawer && applicationWindow().globalDrawer.isMenu
            icon.name: "open-menu-symbolic"
            showMenuArrow: false

            Layout.preferredHeight: Math.min(backButton.implicitHeight, parent.height)
            Layout.preferredWidth: height
            Layout.leftMargin: Kirigami.Units.smallSpacing

            action: Kirigami.Action {
                children: applicationWindow().globalDrawer && applicationWindow().globalDrawer.actions ? applicationWindow().globalDrawer.actions : []
                tooltip: checked ? qsTr("Close menu") : qsTr("Open menu")
            }
            Accessible.name: action.tooltip
        }

        RowLayout {
            id: buttonsLayout
            Layout.fillHeight: true
            Layout.preferredHeight: Math.max(backButton.visible ? backButton.implicitHeight : 0, forwardButton.visible ? forwardButton.implicitHeight : 0)

            Layout.leftMargin: leftHandleAnchor.visible ? Kirigami.Units.smallSpacing : 0

            // TODO KF6: make showNavigationButtons an int, and replace with strict === equality
            visible: (globalToolBar.showNavigationButtons !== Kirigami.ApplicationHeaderStyle.NoNavigationButtons || applicationWindow().pageStack.layers.depth > 1 && !(applicationWindow().pageStack.layers.currentItem instanceof Kirigami.PageRow || header.layerIsMainRow))
                && globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None

            Layout.maximumWidth: visibleChildren.length > 0 ? Layout.preferredWidth : 0

            TP.BackButton {
                id: backButton
                Layout.leftMargin: leftHandleAnchor.visible ? 0 : Kirigami.Units.smallSpacing
                Layout.minimumWidth: implicitHeight
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: buttonsLayout.height
            }
            TP.ForwardButton {
                id: forwardButton
                Layout.minimumWidth: implicitHeight
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: buttonsLayout.height
            }
        }

        QQC2.ToolSeparator {
            visible: (menuButton.visible || (buttonsLayout.visible && buttonsLayout.visibleChildren.length > 0)) && breadcrumbVisible && pageRow.depth > 1
        }

        Loader {
            id: breadcrumbLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: -1
            Layout.preferredHeight: -1
            property Kirigami.PageRow pageRow: root

            asynchronous: true

            active: (globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.TabBar || globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.Breadcrumb) && currentItem && currentItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.None

            // TODO: different implementation?
            source: globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.TabBar ? Qt.resolvedUrl("TabBarControl.qml") : Qt.resolvedUrl("BreadcrumbControl.qml")
        }

        Item {
            id: rightHandleAnchor
            visible: (typeof applicationWindow() !== "undefined" &&
                    applicationWindow().contextDrawer &&
                    applicationWindow().contextDrawer.enabled &&
                    applicationWindow().contextDrawer.handleVisible &&
                    applicationWindow().contextDrawer.handle.handleAnchor === rightHandleAnchor &&
                    (globalToolBar.canContainHandles || (breadcrumbLoader.pageRow && breadcrumbLoader.pageRow.lastVisibleItem &&
                        breadcrumbLoader.pageRow.lastVisibleItem.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar)))
            Layout.fillHeight: true
            Layout.preferredWidth: height
        }
    }
    background.opacity: breadcrumbLoader.active ? 1 : 0
}
