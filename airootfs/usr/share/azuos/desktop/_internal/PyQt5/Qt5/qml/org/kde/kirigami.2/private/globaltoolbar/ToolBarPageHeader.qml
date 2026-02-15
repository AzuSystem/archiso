/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

AbstractPageHeader {
    id: root

    implicitWidth: layout.implicitWidth + Kirigami.Units.smallSpacing * 2
    implicitHeight: Math.max(titleLoader.implicitHeight, toolBar.implicitHeight) + Kirigami.Units.smallSpacing * 2

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => {
            page.forceActiveFocus()
            mouse.accepted = false
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.rightMargin: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        Loader {
            id: titleLoader

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item ? item.Layout.fillWidth : false
            Layout.minimumWidth: item ? item.Layout.minimumWidth : -1
            Layout.preferredWidth: item ? item.Layout.preferredWidth : -1
            Layout.maximumWidth: item ? item.Layout.maximumWidth : -1

            // Don't load async to prevent jumpy behaviour on slower devices as it loads in.
            // If the title delegate really needs to load async, it should be its responsibility to do it itself.
            asynchronous: false
            sourceComponent: page ? page.titleDelegate : null
        }

        Kirigami.ActionToolBar {
            id: toolBar

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: actions.length > 0
            alignment: pageRow ? pageRow.globalToolBar.toolbarActionAlignment : Qt.AlignRight
            heightMode: pageRow ? pageRow.globalToolBar.toolbarActionHeightMode : Kirigami.ToolBarLayout.ConstrainIfLarger

            actions: {
                if (!page) {
                    return []
                }

                const result = []

                if (page.actions.main) {
                    result.push(page.actions.main)
                }
                if (page.actions.left) {
                    result.push(page.actions.left)
                }
                if (page.actions.right) {
                    result.push(page.actions.right)
                }
                if (page.actions.contextualActions.length > 0) {
                    return result.concat(Array.prototype.map.call(page.actions.contextualActions, function(item) { return item }))
                }
                return result
            }

            Binding {
                target: page.actions.main
                property: "displayHint"
                value: page.actions.main ? (page.actions.main.displayHint | Kirigami.DisplayHint.KeepVisible) : null
                restoreMode: Binding.RestoreBinding
            }
            Binding {
                target: page.actions.left
                property: "displayHint"
                value: page.actions.left ? (page.actions.left.displayHint | Kirigami.DisplayHint.KeepVisible) : null
                restoreMode: Binding.RestoreBinding
            }
            Binding {
                target: page.actions.right
                property: "displayHint"
                value: page.actions.right ? (page.actions.right.displayHint | Kirigami.DisplayHint.KeepVisible) : null
                restoreMode: Binding.RestoreBinding
            }
        }
    }
}
