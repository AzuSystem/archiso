/*
 *  SPDX-FileCopyrightText: 2021 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import "templates" as T

T.PageTab {
    id: control

    implicitWidth: vertical ? verticalTitleRow.implicitWidth : horizontalTitleRow.implicitWidth
    implicitHeight: vertical ? verticalTitleRow.implicitHeight : horizontalTitleRow.implicitHeight

    background: Rectangle {
        border {
            width: activeFocus ? 2 : 0
            color: Kirigami.Theme.textColor
        }
        color: {
            if (control.active) {
                return Kirigami.ColorUtils.adjustColor(Kirigami.Theme.activeTextColor, {"alpha": 0.2*255})
            } else if (control.needsAttention) {
                return Kirigami.ColorUtils.adjustColor(Kirigami.Theme.negativeTextColor, {"alpha": 0.2*255})
            } else {
                return "transparent"
            }
        }
    }

    PrivateSwipeHighlight {
        states: [
            State { name: "highlighted"; when: control.active },
            State { name: "requestingAttention"; when: control.needsAttention }
        ]
    }

    PrivateSwipeProgress {
        anchors.fill: parent
        visible: control.progress !== undefined
        progress: control.progress
    }

    RowLayout {
        id: verticalTitleRow
        anchors.fill: parent
        Accessible.ignored: true
        visible: vertical

        ColumnLayout {
            Layout.margins: Kirigami.Settings.isMobile ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignCenter

            Kirigami.Icon {
                visible: !!control.icon.name
                source: control.icon.name

                Layout.preferredHeight: (control.presentation === T.PageTab.Presentation.Large)
                    ? Kirigami.Units.iconSizes.medium
                    : (Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.small)
                Layout.preferredWidth: Layout.preferredHeight

                Layout.alignment: (Qt.AlignHCenter | Qt.AlignBottom)
            }
            Kirigami.Heading {
                level: (control.presentation === T.PageTab.Presentation.Large) ? 2 : 5
                text: control.title
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    RowLayout {
        id: horizontalTitleRow
        anchors.fill: parent
        Accessible.ignored: true
        visible: !vertical

        RowLayout {
            Layout.margins: (control.presentation === T.PageTab.Presentation.Large) ? Kirigami.Units.largeSpacing*2 : Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignVCenter

            Kirigami.Icon {
                visible: !!control.icon.name
                source: control.icon.name

                Layout.preferredHeight: (control.presentation === T.PageTab.Presentation.Large)
                    ? Kirigami.Units.iconSizes.medium
                    : (Kirigami.Settings.isMobile ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.small)
                Layout.preferredWidth: Layout.preferredHeight

                Layout.alignment: (Qt.AlignLeft | Qt.AlignVCenter)
            }
            Kirigami.Heading {
                level: (control.presentation === T.PageTab.Presentation.Large) ? 1 : 2
                text: control.title

                Layout.fillWidth: true
                Layout.alignment: (Qt.AlignLeft | Qt.AlignVCenter)
            }
        }
    }

    Layout.fillHeight: true
    Layout.alignment: Qt.AlignHCenter
}
