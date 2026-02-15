/*
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

/**
 * This component is used as a default representation for a page title within
 * page's header/toolbar. It is just a Heading item with shrinking + eliding
 * behavior.
 *
 * \private
 */
Item {
    property alias text: heading.text

    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.maximumWidth: implicitWidth

    implicitWidth: Math.ceil(metrics.advanceWidth)
    implicitHeight: metrics.height

    Kirigami.Heading {
        id: heading

        anchors.fill: parent
        maximumLineCount: 1
        elide: Text.ElideRight
        textFormat: Text.PlainText
    }

    TextMetrics {
        id: metrics

        font: heading.font
        text: heading.text
    }
}
