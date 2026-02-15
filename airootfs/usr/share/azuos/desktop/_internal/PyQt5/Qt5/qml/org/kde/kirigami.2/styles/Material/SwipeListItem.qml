/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls.Material 2.1 as Mat
import QtQuick.Controls.Material.impl 2.1 as MatImp
import "../../private" as P
import "../../templates" as T

T.SwipeListItem {
    id: listItem

    background: P.DefaultListItemBackground {
        MatImp.Ripple {
            anchors.fill: parent
            clip: visible
            pressed: listItem.pressed
            anchor: listItem
            active: listItem.down || listItem.visualFocus
            color: Qt.rgba(0,0,0,0.2)
        }
    }
    implicitHeight: contentItem.implicitHeight + Kirigami.Units.smallSpacing * 6
}
