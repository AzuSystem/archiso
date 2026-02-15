/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.4 as Kirigami

QQC2.ToolButton {
    id: button

    icon.name: (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")

    enabled: applicationWindow().pageStack.currentIndex < applicationWindow().pageStack.depth-1

    property var showNavButtons: {
        try {
            return globalToolBar.showNavigationButtons
        } catch (_) {
            return false
        }
    }
    // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
    visible: applicationWindow().pageStack.layers.depth === 1 && applicationWindow().pageStack.contentItem.contentWidth > applicationWindow().pageStack.width + Kirigami.Units.gridUnit && (showNavButtons === true || (showNavButtons & Kirigami.ApplicationHeaderStyle.ShowForwardButton))

    onClicked: applicationWindow().pageStack.goForward();

    text: qsTr("Navigate Forward")
    display: QQC2.ToolButton.IconOnly

    QQC2.ToolTip {
        visible: button.hovered
        text: button.text
        delay: Kirigami.Units.toolTipDelay
        timeout: 5000
        y: button.height
    }
}
