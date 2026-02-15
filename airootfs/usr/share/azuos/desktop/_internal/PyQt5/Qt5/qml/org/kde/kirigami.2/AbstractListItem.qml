/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "private" as P
import "templates" as T

//TODO KF6: not have list items at all (except perhaps swipelistitem which is an unuque ui) but rather have a set of layouts for lists items to be put inside standard QQC2 Delegate
/**
 * @brief An item delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * @see <a href="https://develop.kde.org/hig/components/editing/list">KDE Human Interface Guidelines on List Views and List Items</a>
 * @inherit kirigami::templates::AbstractListItem
 */
T.AbstractListItem {
    id: listItem

    background: P.DefaultListItemBackground {}
}
