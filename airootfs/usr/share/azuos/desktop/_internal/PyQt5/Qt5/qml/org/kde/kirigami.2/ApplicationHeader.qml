/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "templates" as T

//TODO KF6: remove
/**
 * @brief An item that can be used as a title for the application.
 *
 * Scrolling the main page will make it taller or shorter (through the point of going away)
 * It's a behavior similar to the typical mobile web browser addressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * ``minimumHeight``: Default is 0, i.e. hidden
 * * ``preferredHeight``: Default is Kirigami.Units.gridUnit * 1.6
 * * ``maximumHeight``: Default is Kirigami.Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 *
 * @deprecated This will be removed in KF6.
 * @inherit kirigami::templates::ApplicationHeader
 */
T.ApplicationHeader {
    id: header
}
