/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.3
import QtQuick.Controls 2.3 as QQC2
import org.kde.kirigami 2.4 as Kirigami

QQC2.MenuItem {
    id: menuItem

    visible: action.visible === undefined || action.visible
    height: visible ? implicitHeight : 0
    autoExclusive: {
        const g = action.QQC2.ActionGroup.group;
        return g && g.exclusive;
    }

    QQC2.ToolTip.text: action.tooltip || ""
    QQC2.ToolTip.visible: menuItem.hovered && QQC2.ToolTip.text.length > 0
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
}
