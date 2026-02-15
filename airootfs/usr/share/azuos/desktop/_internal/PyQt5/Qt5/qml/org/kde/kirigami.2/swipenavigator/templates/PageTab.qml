/*
 *  SPDX-FileCopyrightText: 2021 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import "../../private" as Private

// TODO?: refactor into abstractbutton
QQC2.Control {
    id: control

    enum Presentation {
        Normal,
        Large
    }

    property string title
    property bool active

    property Private.ActionIconGroup icon: Private.ActionIconGroup {}
    property int presentation: PageTab.Presentation.Normal
    property bool vertical: false
    property var progress // type: real?
    property bool needsAttention: false

    activeFocusOnTab: true

    Accessible.name: control.title
    Accessible.description: {
        if (!!control.progress) {
            if (control.active) {
                //: Accessibility text for a page tab. Keep the text as concise as possible and don't use a percent sign.
                return qsTr("Current page. Progress: %1 percent.").arg(Math.round(control.progress*100))
            } else {
                //: Accessibility text for a page tab. Keep the text as concise as possible.
                return qsTr("Navigate to %1. Progress: %2 percent.").arg(control.title).arg(Math.round(control.progress*100))
            }
        } else {
            if (control.active) {
                //: Accessibility text for a page tab. Keep the text as concise as possible.
                return qsTr("Current page.")
            } else if (control.needsAttention) {
                //: Accessibility text for a page tab that's requesting the user's attention. Keep the text as concise as possible.
                return qsTr("Navigate to %1. Demanding attention.", control.title)
            } else {
                //: Accessibility text for a page tab that's requesting the user's attention. Keep the text as concise as possible.
                return qsTr("Navigate to %1.", control.title)
            }
        }
    }
    Accessible.role: Accessible.PageTab
    Accessible.focusable: true
    Accessible.onPressAction: control.clicked()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            control.clicked()
        }
    }
}
