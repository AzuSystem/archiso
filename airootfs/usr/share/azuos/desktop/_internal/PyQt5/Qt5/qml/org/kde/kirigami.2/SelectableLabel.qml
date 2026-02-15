/*
 *  SPDX-FileCopyrightText: 2022 Fushan Wen <qydwhotmail@gmail.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

/**
 * @brief This is a label which supports text selection.
 *
 * You can use all elements of QtQuick.Controls.TextArea,
 * in particular the "text" property to define the label text.
 *
 * Example usage:
 * @code{.qml}
 * ...
 *     Kirigami.SelectableLabel {
 *         text: "Label"
 *     }
 * ...
 * @endcode
 * @see https://bugreports.qt.io/browse/QTBUG-14077
 * @since KDE Frameworks 5.95
 * @since org.kde.kirigami 2.20
 * @inherit QtQuick.Controls.TextArea
 */
QQC2.TextArea {
    id: selectableLabel

    /**
     * @brief This property holds the cursor shape that will appear whenever
     * the mouse is hovering over the label.
     *
     * default: @c Qt.IBeamCursor
     *
     * @property Qt::CursorShape cursorShape
     */
    property alias cursorShape: hoverHandler.cursorShape

    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    activeFocusOnTab: false
    readOnly: true
    wrapMode: Text.WordWrap
    textFormat: TextEdit.AutoText
    verticalAlignment: TextEdit.AlignTop

    Accessible.selectableText: true
    Accessible.editable: false

    background: Item {}

    HoverHandler {
        id: hoverHandler
        // By default HoverHandler accepts the left button while it shouldn't accept anything,
        // causing https://bugreports.qt.io/browse/QTBUG-106489.
        // Qt.NoButton unfortunately is not a valid value for acceptedButtons.
        // Disabling masks the problem, but
        // there is no proper workaround other than an upstream fix
        // See qqc2-desktop-style Label.qml
        enabled: false
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.IBeamCursor
    }
}
