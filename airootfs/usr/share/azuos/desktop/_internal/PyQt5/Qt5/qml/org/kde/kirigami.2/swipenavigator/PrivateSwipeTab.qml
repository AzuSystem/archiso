/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.17 as Kirigami

Kirigami.PageTab {
    id: tabRoot

    active: index === columnView.currentIndex
    title: modelData.title
    progress: modelData.progress
    needsAttention: modelData.needsAttention
    icon: modelData.icon

    signal indexChanged(real xPos, real tabWidth)

    onActiveFocusChanged: {
        if (activeFocus) {
            tabRoot.indexChanged(tabRoot.x, tabRoot.width)
        }
    }
    TapHandler {
        onTapped: eventPoint => {
            columnView.currentIndex = index;
        }
    }
    Connections {
        target: columnView
        function onCurrentIndexChanged() {
            if (index === columnView.currentIndex) {
                tabRoot.indexChanged(tabRoot.x, tabRoot.width)
            }
        }
    }
}
