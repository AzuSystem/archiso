/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.19 as Kirigami

/**
 * @warning This will probably be deprecated in KF6.
 */
// TODO KF6 deprecated
QQC2.TabBar {
    id: root
    property Kirigami.PageRow pageRow: parent.pageRow

    Repeater {
        id: mainRepeater
        model: pageRow.depth
        delegate: QQC2.TabButton {
            anchors {
                top:parent.top
                bottom:parent.bottom
            }
            width: mainRepeater.count === 1 ? implicitWidth : Math.max(implicitWidth, Math.round(root.width/mainRepeater.count))
            height: root.height
            readonly property Kirigami.Page page: pageRow.get(modelData)
            text: page ? page.title : ""
            checked: modelData === pageRow.currentIndex
            onClicked: pageRow.currentIndex = modelData;
        }
    }
}
