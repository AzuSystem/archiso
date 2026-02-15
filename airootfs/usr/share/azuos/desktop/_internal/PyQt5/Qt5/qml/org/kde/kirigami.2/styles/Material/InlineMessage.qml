/*
 *  SPDX-FileCopyrightText: 2018 Eike Hein <hein@kde.org>
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2018 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtGraphicalEffects 1.0 as GE
import org.kde.kirigami 2.5 as Kirigami
import "../../templates" as T

T.InlineMessage {
    id: root

    background: Rectangle {
        id: bgBorderRect

        color: {
            if (root.type == Kirigami.MessageType.Positive) {
                return Kirigami.Theme.positiveTextColor;
            } else if (root.type == Kirigami.MessageType.Warning) {
                return Kirigami.Theme.neutralTextColor;
            } else if (root.type == Kirigami.MessageType.Error) {
                return Kirigami.Theme.negativeTextColor;
            }

            return Kirigami.Theme.activeTextColor;
        }

        radius: Kirigami.Units.smallSpacing / 2

        Rectangle {
            id: bgFillRect

            anchors.fill: parent
            anchors.margins: 1

            color: Kirigami.Theme.backgroundColor

            radius: bgBorderRect.radius * 0.60
        }

        Rectangle {
            anchors.fill: bgFillRect

            color: bgBorderRect.color

            opacity: 0.20

            radius: bgFillRect.radius
        }

        layer.enabled: true
        layer.effect: GE.DropShadow {
            horizontalOffset: 0
            verticalOffset: 1
            radius: 12
            samples: 32
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }
}
