/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQml 2.1


/**
 * @brief This is an action group that defines actions in a kirigami page.
 */
QtObject {
    /**
     * @brief This is the main action of a page.
     *
     * This action will be displayed horizontally centered at the bottom of the
     * page when page stack's global toolbar style is set to breadcrumb mode.
     *
     * @see kirigami::PageRow::globalToolBar
     */
    property QtObject main

    /**
     * @brief This is the left action in a page.
     *
     * This action will be left of the main action when page stack's global
     * toolbar style is set to breadcrumb mode.
     *
     * @see kirigami::PageRow::globalToolBar
     */
    property QtObject left

    /**
     * @brief This is the right action in a page.
     *
     * This action will be right of the main action when page stack's global
     * toolbar style is set to breadcrumb mode.
     *
     * @see kirigami::PageRow::globalToolBar
     */
    property QtObject right

    /**
     * @brief These actions are inside a ContextDrawer which will be shown
     * by swiping from the right side.
     *
     * @see kirigami::ContextDrawer
     */
    property list<QtObject> contextualActions
}

