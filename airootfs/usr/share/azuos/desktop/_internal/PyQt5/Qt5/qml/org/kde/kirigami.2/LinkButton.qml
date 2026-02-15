/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.2
import QtQuick.Controls 2.1 as QQC2
import org.kde.kirigami 2.14 as Kirigami

/**
 * @brief A button that looks like a link.
 *
 * It uses the link color settings and triggers an action when clicked.
 *
 * Maps to the Command Link in the HIG:
 * https://develop.kde.org/hig/components/navigation/commandlink/
 *
 * @since KDE Frameworks 5.52
 * @since org.kde.kirigami 2.6
 * @inherit QtQuick.Controls.Label
 */
QQC2.Label {
    id: control

    property Action action: null

    /**
     * @brief This property holds the mouse buttons that the mouse area reacts to.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-mousearea.html#acceptedButtons-prop">MouseArea.acceptedButtons</a>
     * @property Qt::MouseButton acceptedButtons
     */
    property alias acceptedButtons: area.acceptedButtons

    /**
     * @brief This property holds the mouse area element covering the button.
     * @property MouseArea area
     */
    property alias mouseArea: area

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: control.clicked({"button": Qt.LeftButton})

    text: action ? action.text : ""
    enabled: !action || action.enabled
    onClicked: mouse => {
        if (action) {
            action.trigger();
        }
    }

    font.bold: activeFocus
    font.underline: control.enabled
    color: enabled ? Kirigami.Theme.linkColor : Kirigami.Theme.textColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight

    signal pressed(var mouse)
    signal clicked(var mouse)

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Space:
        case Qt.Key_Enter:
        case Qt.Key_Return:
        case Qt.Key_Select:
            control.clicked({"button": Qt.LeftButton});
            event.accepted = true;
            break;
        case Qt.Key_Menu:
            control.pressed({"button": Qt.RightButton});
            event.accepted = true;
            break;
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => control.clicked(mouse)
        onPressed: mouse => control.pressed(mouse)
    }
}
