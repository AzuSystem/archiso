/*
 *  SPDX-FileCopyrightText: 2011 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.0 as QQC2

QQC2.Label {
    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false

    Component.onCompleted: {
        console.warn("Kirigami.Label is deprecated. Use QQC2.Label instead")
    }
}
