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

    icon.name: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")

    enabled: {
        const pageStack = applicationWindow().pageStack;

        if (pageStack.layers.depth > 1) {
            return true;
        }

        if (pageStack.depth > 1) {
            if (pageStack.currentIndex > 0) {
                return true;
            }

            const view = pageStack.columnView;
            if (LayoutMirroring.enabled) {
                return view.contentWidth - view.width < view.contentX
            } else {
                return view.contentX > 0;
            }
        }

        return false;
    }

    property var showNavButtons: {
        try {
            return globalToolBar.showNavigationButtons
        } catch (_) {
            return false
        }
    }
    // The gridUnit wiggle room is used to not flicker the button visibility during an animated resize for instance due to a sidebar collapse
    visible: applicationWindow().pageStack.layers.depth > 1 || (applicationWindow().pageStack.contentItem.contentWidth > applicationWindow().pageStack.width + Kirigami.Units.gridUnit && (button.showNavButtons === true || (button.showNavButtons & Kirigami.ApplicationHeaderStyle.ShowBackButton)))

    onClicked: {
        applicationWindow().pageStack.goBack();
    }

    text: qsTr("Navigate Back")
    display: QQC2.ToolButton.IconOnly

    QQC2.ToolTip {
        visible: button.hovered
        text: button.text
        delay: Kirigami.Units.toolTipDelay
        timeout: 5000
        y: button.height
    }
}
