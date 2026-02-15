/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15

AbstractPageHeader {
    id: root

    Loader {
        id: titleLoader

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        height: Math.min(root.height, item
            ? (item.Layout.preferredHeight > 0 ? item.Layout.preferredHeight : item.implicitHeight)
            : 0)

        // Don't load async to prevent jumpy behaviour on slower devices as it loads in.
        // If the title delegate really needs to load async, it should be its responsibility to do it itself.
        asynchronous: false
        sourceComponent: page ? page.titleDelegate : null
    }
}
