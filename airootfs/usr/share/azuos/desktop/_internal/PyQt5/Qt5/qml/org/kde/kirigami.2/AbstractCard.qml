/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import "templates" as T
import "private" as P

/**
 * @brief AbstractCard is the base for cards.
 *
 * A Card is a visual object that serves as an entry point for more detailed information.
 * An abstractCard is empty, providing just the look and the base properties and signals
 * for a QtQuick.Controls.ItemDelegate.
 * It can be filled with any custom layout of items, its content is organized in
 * 3 properties: ::header, contentItem and ::footer.
 * Use this only when you need particular custom contents, for a standard layout
 * for cards, use the Card component.
 *
 * @see kirigami::Card
 * @see <a href="https://develop.kde.org/hig/components/editing/card">KDE Human Interface Guidelines on Cards</a>
 * @since org.kde.kirigami 2.4
 * @inherit kirigami::templates::AbstractCard
 */
T.AbstractCard {
    id: root

    background: P.DefaultCardBackground {
        clickFeedback: root.showClickFeedback
        hoverFeedback: root.hoverEnabled
    }
}
