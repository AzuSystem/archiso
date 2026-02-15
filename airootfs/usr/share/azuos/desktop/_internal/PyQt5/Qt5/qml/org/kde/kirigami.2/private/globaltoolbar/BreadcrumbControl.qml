/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

Flickable {
    id: root

    property Kirigami.PageRow pageRow: parent.pageRow

    readonly property Item currentItem: mainLayout.children[pageRow.currentIndex] || null

    contentHeight: height
    contentWidth: mainLayout.width
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: Kirigami.Settings.hasTransientTouchInput

    contentX: currentItem
        ? Math.max(0,
            Math.min(currentItem.x + currentItem.width/2 - root.width/2,
                     root.contentWidth - root.width))
        : 0

    RowLayout {
        id: mainLayout
        height: parent.height
        spacing: 0
        Repeater {
            id: mainRepeater
            readonly property bool useLayers: pageRow.layers.depth > 1
            model: useLayers ? pageRow.layers.depth - 1 : pageRow.depth
            delegate: MouseArea {
                Layout.preferredWidth: delegateLayout.implicitWidth
                Layout.fillHeight: true
                onClicked: mouse => {
                    if (mainRepeater.useLayers) {
                        while (pageRow.layers.depth > modelData + 1) {
                            pageRow.layers.pop();
                        }
                    } else {
                        pageRow.currentIndex = modelData;
                    }
                }
                hoverEnabled: !Kirigami.Settings.tabletMode
                Rectangle {
                    color: Kirigami.Theme.highlightColor
                    anchors.fill: parent
                    radius: 3
                    opacity: mainRepeater.count > 1 && parent.containsMouse ? 0.1 : 0
                }
                RowLayout {
                    id: delegateLayout
                    anchors.fill: parent
                    // We can't use Kirigami.Page here instead of Item since we now accept pushing PageRow to a new layer
                    readonly property Item page: mainRepeater.useLayers ? pageRow.layers.get(modelData + 1) : pageRow.get(modelData)
                    spacing: 0

                    Kirigami.Icon {
                        visible: modelData > 0
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        Layout.preferredWidth: Layout.preferredHeight
                        isMask: true
                        color: Kirigami.Theme.textColor
                        source: LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic"
                    }
                    Kirigami.Heading {
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.rightMargin: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.textColor
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                        text: delegateLayout.page ? delegateLayout.page.title : ""
                        opacity: modelData === pageRow.currentIndex ? 1 : 0.4
                    }
                }
            }
        }
    }

    Behavior on contentX {
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
}
