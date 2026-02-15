/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.12 as Kirigami

Rectangle {
    id: background
    color: {
        if (listItem.checked || listItem.highlighted || (listItem.down && !listItem.checked && !listItem.sectionDelegate))
            return listItem.activeBackgroundColor
        else if (listItem.alternatingBackground && index % 2)
            return listItem.alternateBackgroundColor
        return listItem.backgroundColor
    }

    visible: listItem.ListView.view === null || listItem.ListView.view.highlight === null
    Rectangle {
        id: internal
        anchors.fill: parent
        visible: !Kirigami.Settings.tabletMode && listItem.hoverEnabled
        color: listItem.activeBackgroundColor
        opacity: {
            if ((listItem.highlighted || listItem.ListView.isCurrentItem) && !listItem.down) {
                return .6
            } else if (listItem.hovered && !listItem.down) {
                return .3
            } else {
                return 0
            }
        }
    }

    Kirigami.Separator {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.largeSpacing
        }
        visible: {
            // Whether there is visual feedback (do not show the separator)
            const visualFeedback = listItem.highlighted || listItem.down || listItem.checked || listItem.ListView.isCurrentItem

            // Show the separator when activeBackgroundColor is set to "transparent",
            // when the item is hovered. Check commit 344aec26.
            const bgTransparent = !listItem.hovered || listItem.activeBackgroundColor.a === 0

            // Whether the next item is a section delegate or is from another section (do not show the separator)
            const anotherSection = listItem.ListView.view === null || listItem.ListView.nextSection === listItem.ListView.section

            // Whether this item is the last item in the view (do not show the separator)
            const lastItem = listItem.ListView.view === null || listItem.ListView.count - 1 !== index

            return listItem.separatorVisible && !visualFeedback && bgTransparent
                && !listItem.sectionDelegate && anotherSection && lastItem
        }
        weight: Kirigami.Separator.Weight.Light
    }
}

