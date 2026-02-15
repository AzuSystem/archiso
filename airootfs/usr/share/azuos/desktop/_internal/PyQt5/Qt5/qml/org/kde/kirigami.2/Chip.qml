// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

/**
 * @brief A compact element that represents an attribute, action, or filter.
 *
 * Should be used in a group of multiple elements. e.g when displaying tags in a image viewer.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.19 as Kirigami
 *
 * Flow {
 *     Repeater {
 *         model: chipsModel
 *
 *         Kirigami.Chip {
 *             text: model.text
 *             icon.name: "tag-symbolic"
 *             closable: model.closable
 *             onClicked: {
 *                 [...]
 *             }
 *             onRemoved: {
 *                 [...]
 *             }
 *         }
 *     }
 * }
 * @endcode
 *
 * @since org.kde.kirigami 2.19
 * @inherit kirigami::AbstractChip
 */
Kirigami.AbstractChip {
    id: chip

    implicitWidth: layout.implicitWidth
    implicitHeight: toolButton.implicitHeight

    checkable: !closable

    /**
     * @brief This property holds the label item; used for accessing the usual QtQuick.Text properties.
     * @property QtQuick.Controls.Label labelItem
     */
    property alias labelItem: label

    contentItem: RowLayout {
        id: layout
        spacing: 0

        Kirigami.Icon {
            id: icon
            visible: icon.valid
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            Layout.leftMargin: Kirigami.Units.smallSpacing
            color: chip.icon.color
            source: chip.icon.name || chip.icon.source
        }
        QQC2.Label {
            id: label
            Layout.fillWidth: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 1.5
            Layout.leftMargin: icon.visible ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            Layout.rightMargin: chip.closable ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: chip.text
            color: Kirigami.Theme.textColor
            elide: Text.ElideRight
        }
        QQC2.ToolButton {
            id: toolButton
            visible: chip.closable
            text: qsTr("Remove Tag")
            icon.name: "edit-delete-remove"
            icon.width: Kirigami.Units.iconSizes.sizeForLabels
            icon.height: Kirigami.Units.iconSizes.sizeForLabels
            display: QQC2.AbstractButton.IconOnly
            onClicked: chip.removed()
        }
    }
}
