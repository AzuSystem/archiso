/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.10
import org.kde.kirigami 2.4 as Kirigami


GridView {
    id: root

    property Component _delegateComponent


    QtObject {
        id: calculations

        // initialize array so length property can be read
        property var leftMargins: []
        readonly property int delegateWidth: Math.min(cellWidth, maximumColumnWidth) - Kirigami.Units.largeSpacing * 2 - ((Kirigami.Units.largeSpacing * 2) / root.columns)
        // We need to subtract ((Kirigami.Units.largeSpacing * 2) / root.columns) to consider space on the left and on the right spreaded trough all columns
    }

    delegate: Kirigami.DelegateRecycler {
        width: calculations.delegateWidth

        anchors.left: GridView.view.contentItem.left

        sourceComponent: root._delegateComponent
        onWidthChanged: {
            const columnIndex = index % root.columns
            if (index < root.columns) {
                // calulate left margin per column
                calculations.leftMargins[columnIndex] = Kirigami.Units.largeSpacing + (width + Kirigami.Units.largeSpacing * 2 )
                        * (columnIndex) + root.width / 2
                        - (root.columns * (width + Kirigami.Units.largeSpacing * 2)) / 2;
            }
            anchors.leftMargin = calculations.leftMargins[columnIndex];
        }
    }
    onWidthChanged: {
        if (calculations.leftMargins.length !== root.columns) {
            calculations.leftMargins = new Array(root.columns);
        }
    }
}
