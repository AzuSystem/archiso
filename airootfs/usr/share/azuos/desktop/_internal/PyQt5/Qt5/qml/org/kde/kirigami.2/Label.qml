/*
 *  SPDX-FileCopyrightText: 2011 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.0 as QQC2

// TODO KF6: Remove!
/**
 * This is a label which uses the current Theme.
 *
 * The characteristics of the text will be automatically set according to the
 * current Theme. If you need a more customized text item use the Text component
 * from QtQuick.
 *
 * You can use all elements of the QML Text component, in particular the "text"
 * property to define the label text.
 *
 * @inherit QtQuick.Templates.Label
 * @deprecated This will be removed in KF6. Use QtQuick.Controls.Label directly, it will be styled appropriately.
 */
QQC2.Label {
    height: Math.round(Math.max(paintedHeight, Kirigami.Units.gridUnit * 1.6))
    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false

    Component.onCompleted: {
        console.warn("Kirigami.Label is deprecated. Use QtQuickControls2.Label instead")
    }
}
