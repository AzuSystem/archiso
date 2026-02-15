/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
/**
 * CardsListView is a ListView intended to be used with
 * AbstractCard component as its delegate.
 *
 * It will automatically assign the proper spacings and margins around the
 * cards adhering to the design guidelines.
 *
 * CardsListView should be used only with cards which can look good at any
 * horizontal size, so it is recommended to directly use AbstractCard with an
 * appropriate layout inside, because they are stretching for the whole list width.
 *
 * Therefore, it is discouraged to use it with the Card type, unless it has
 * AbstractCard::headerOrientation set to ``Qt.Horizontal``.
 *
 * The choice between using this view with AbstractCard or a normal QtQuick.ListView
 * with AbstractListItem / BasicListItem is purely a choice based on aesthetics alone.
 *
 * It is recommended to use default values.
 *
 * @since org.kde.kirigami 2.4
 * @inherit QtQuick.ListView
 */
ListView {
    id: root
    spacing: Kirigami.Units.largeSpacing * 2
    topMargin: headerPositioning !== ListView.InlineHeader ? spacing : 0
    rightMargin: Kirigami.Units.largeSpacing * 2
    leftMargin: Kirigami.Units.largeSpacing * 2
    reuseItems: true

    headerPositioning: ListView.OverlayHeader

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) {
            positionViewAtBeginning();
            currentIndex = 0;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_End) {
            positionViewAtEnd();
            currentIndex = count - 1;
            event.accepted = true;
        }
    }
}
