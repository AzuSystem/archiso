/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.19 as Kirigami

Kirigami.AbstractApplicationHeader {
    id: root
    // anchors.fill: parent
    property Item container
    property bool current

    minimumHeight: pageRow ? pageRow.globalToolBar.minimumHeight : Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
    maximumHeight: pageRow ? pageRow.globalToolBar.maximumHeight : minimumHeight
    preferredHeight: pageRow ? pageRow.globalToolBar.preferredHeight : minimumHeight

    separatorVisible: pageRow ? pageRow.globalToolBar.separatorVisible : true

    Kirigami.Theme.colorSet: pageRow ? pageRow.globalToolBar.colorSet : Kirigami.Theme.Header

    leftPadding: pageRow
        ? Math.min(
            width / 2,
            Math.max(
                (page.title.length > 0 ? pageRow.globalToolBar.titleLeftPadding : 0),
                Qt.application.layoutDirection === Qt.LeftToRight
                    ? (pageRow.Kirigami.ScenePosition.x
                        - page.Kirigami.ScenePosition.x
                        + pageRow.globalToolBar.leftReservedSpace
                        + Kirigami.Units.smallSpacing)
                    : (-pageRow.width
                        + pageRow.Kirigami.ScenePosition.x
                        + page.Kirigami.ScenePosition.x
                        + page.width
                        + pageRow.globalToolBar.leftReservedSpace
                        + Kirigami.Units.smallSpacing)))
        : Kirigami.Units.smallSpacing

    rightPadding: pageRow
        ? Math.max(0,
            Qt.application.layoutDirection === Qt.LeftToRight
            ? (-pageRow.width
                - pageRow.Kirigami.ScenePosition.x
                + page.width
                + page.Kirigami.ScenePosition.x
                + pageRow.globalToolBar.rightReservedSpace)
            : (pageRow.Kirigami.ScenePosition.x
                - page.Kirigami.ScenePosition.x
                + pageRow.globalToolBar.rightReservedSpace))
        : 0
}
