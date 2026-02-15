/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.20 as Kirigami

Controls.ToolButton {
    id: control

    signal menuAboutToShow()

    hoverEnabled: true

    display: Controls.ToolButton.TextBesideIcon

    property bool showMenuArrow: !Kirigami.DisplayHint.displayHintSet(action, Kirigami.DisplayHint.HideChildIndicator)

    property var menuActions: {
        if (action && action.hasOwnProperty("children")) {
            return Array.prototype.slice.call(action.children)
        }
        return []
    }

    property Component menuComponent: ActionsMenu {
        submenuComponent: ActionsMenu { }
    }

    property QtObject menu: null

    // We create the menu instance only when there are any actual menu items.
    // This also happens in the background, avoiding slowdowns due to menu item
    // creation on the main thread.
    onMenuActionsChanged: {
        if (menuComponent && menuActions.length > 0) {
            if (!menu) {
                const setupIncubatedMenu = incubatedMenu => {
                    menu = incubatedMenu
                    // Important: We handle the press on parent in the parent, so ignore it here.
                    menu.closePolicy = Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutsideParent
                    menu.closed.connect(() => control.checked = false)
                    menu.actions = control.menuActions
                }
                const incubator = menuComponent.incubateObject(control, {"actions": menuActions})
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = status => {
                        if (status === Component.Ready) {
                            setupIncubatedMenu(incubator.object)
                        }
                    }
                } else {
                    setupIncubatedMenu(incubator.object);
                }
            } else {
                menu.actions = menuActions
            }
        }
    }

    visible: (action && action.hasOwnProperty("visible")) ? action.visible : true

    // Workaround for QTBUG-85941
    Binding {
        target: control
        property: "checkable"
        value: (control.action && control.action.checkable) || (control.menuActions && control.menuActions.length > 0)
        restoreMode: Binding.RestoreBinding
    }

    onToggled: {
        if (menuActions.length > 0 && menu) {
            if (checked) {
                control.menuAboutToShow();
                menu.popup(control, 0, control.height)
            } else {
                menu.dismiss()
            }
        }
    }

    Controls.ToolTip {
        visible: control.hovered && text.length > 0 && !(control.menu && control.menu.visible) && !control.pressed
        text: {
            const a = control.action;
            if (a) {
                if (a.tooltip) {
                    return a.tooltip;
                } else if (control.display === Controls.Button.IconOnly) {
                    return a.text;
                }
            }
            return "";
        }
    }

    // This will set showMenuArrow when using qqc2-desktop-style.
    Accessible.role: (control.showMenuArrow && control.menuActions.length > 0) ? Accessible.ButtonMenu : Accessible.Button
    Accessible.ignored: !visible
}
