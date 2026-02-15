/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import org.kde.kirigami 2.12 as Kirigami

//TODO KF6: this seems to have ended up barely used if at all. can be removed?
// Investigate why almost identical api is used a lot on different frameworks
// like Flutter but not in plamo apps.

/**
 * @brief An ApplicationWindow with a preconfigured PageRouter.
 *
 * In order to call functions on the PageRouter, use @link PageRouterAttached  the attached Kirigami.PageRouter object @endlink.
 *
 * @warning This might be removed in KF6 due to not being used a lot.
 * @inherit kirigami::ApplicationWindow
 */
Kirigami.ApplicationWindow {
    id: __kirigamiApplicationWindow

    /**
     * @see kirigami::PageRouter::routes
     * @property list<Kirigami.PageRoute> route
     */
    default property alias routes: __kirigamiPageRouter.routes

    /**
     * @see kirigami::PageRouter::initialRoute
     * @property string initialRoute
     */
    property alias initialRoute: __kirigamiPageRouter.initialRoute

    /**
     * @brief This property holds this window's PageRouter.
     * @property kirigami::PageRouter
     */
    property alias router: __kirigamiPageRouter

    Kirigami.PageRouter {
        id: __kirigamiPageRouter
        pageStack: __kirigamiApplicationWindow.pageStack.columnView
    }
}
