/*
 *  SPDX-FileCopyrightText: 2019 Björn Feber <bfeber@protonmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

/**
 * @brief A section delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * Example usage:
 * @code{.qml}
 * import QtQuick 2.5
 * import QtQuick.Controls 2.5 as QQC2
 *
 * import org.kde.kirigami 2.10 as Kirigami
 *
 * ListView {
 *  [...]
 *     section.delegate: Kirigami.ListSectionHeader {
 *         label: section
 *
 *         QQC2.Button {
 *             text: "Button 1"
 *         }
 *         QQC2.Button {
 *             text: "Button 2"
 *         }
 *     }
 *  [...]
 * }
 * @endcode
 * @inherit kirigami::AbstractListItem
 */
Kirigami.AbstractListItem {
    id: listSection

    /**
     * @brief This property sets the text of the ListView's section header.
     * @property string label
     */
    property alias label: listSection.text

    /** @internal */
    default property alias _contents: rowLayout.data

    separatorVisible: false
    sectionDelegate: true
    hoverEnabled: false

    activeFocusOnTab: false

    // we do not need a background
    background: Item {}

    topPadding: Kirigami.Units.largeSpacing + Kirigami.Units.smallSpacing

    contentItem: RowLayout {
        id: rowLayout
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            Layout.fillWidth: rowLayout.children.length === 1
            Layout.alignment: Qt.AlignVCenter

            opacity: 0.7
            level: 5
            type: Kirigami.Heading.Primary
            text: listSection.text
            elide: Text.ElideRight

            // we override the Primary type's font weight (DemiBold) for Bold for contrast with small text
            font.weight: Font.Bold
        }

        Kirigami.Separator {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
