/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Templates 2.0 as T2
import org.kde.kirigami 2.15 as Kirigami
import "private" as P
import "templates" as T

/**
 * @brief Overlay drawers are used to expose additional UI elements needed for
 * small secondary tasks for which the main UI elements are not needed.
 *
 * Overlay drawers can be used to create two kinds of components, a modal drawer
 * and an inline drawer. A modal drawer darkens the rest of the application and
 * grabs focus until confirmed, whereas an inline drawer does not.
 *
 * Unlike an OverlaySheet that appears in the center of the application, an OverlayDrawer
 * can be attached to an edge of the application, usually the top or the bottom edges.
 *
 * @see Visit https://develop.kde.org/docs/getting-started/kirigami/components-drawers to read more
 * about modal and non-modal drawers.
 *
 * Example usage:
 * @include overlaydrawer.qml
 *
 * @inherit kirigami::templates::OverlayDrawer
 */
T.OverlayDrawer {
    id: root

//BEGIN Properties
    focus: false
    modal: true
    drawerOpen: !modal
    closePolicy: modal ? T2.Popup.CloseOnEscape | T2.Popup.CloseOnReleaseOutside : T2.Popup.NoAutoClose
    handleVisible: interactive && (modal || !drawerOpen) && (typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true)

    // FIXME: set to false when it does not lead to blocking closePolicy.
    // See Kirigami bug: 454119
    interactive: true

    onPositionChanged: {
        if (!modal && !root.peeking && !root.animating) {
            position = 1;
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor

        Item {
            parent: root.handle
            anchors.fill: parent

            Kirigami.ShadowedRectangle {
                id: handleGraphics
                anchors.centerIn: parent

                Kirigami.Theme.colorSet: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.colorSet : Kirigami.Theme.Button

                Kirigami.Theme.backgroundColor: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.backgroundColor : undefined

                Kirigami.Theme.textColor: parent.parent.handleAnchor && parent.parent.handleAnchor.visible ? parent.parent.handleAnchor.Kirigami.Theme.textColor : undefined

                Kirigami.Theme.inherit: false
                color: root.handle.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

                visible: !parent.parent.handleAnchor || !parent.parent.handleAnchor.visible || root.handle.pressed || (root.modal && root.position > 0)

                shadow.color: Qt.rgba(0, 0, 0, root.handle.pressed ? 0.6 : 0.4)
                shadow.yOffset: 1
                shadow.size: Kirigami.Units.gridUnit / 2

                width: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
                height: width
                radius: 2
                Behavior on color {
                    ColorAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Loader {
                anchors.centerIn: handleGraphics
                width: height
                height: Kirigami.Units.iconSizes.smallMedium

                Kirigami.Theme.colorSet: handleGraphics.Kirigami.Theme.colorSet
                Kirigami.Theme.backgroundColor: handleGraphics.Kirigami.Theme.backgroundColor
                Kirigami.Theme.textColor: handleGraphics.Kirigami.Theme.textColor

                asynchronous: true

                source: {
                    let edge = root.edge;
                    if (Qt.application.layoutDirection === Qt.RightToLeft) {
                        if (edge === Qt.LeftEdge) {
                            edge = Qt.RightEdge;
                        } else {
                            edge = Qt.LeftEdge;
                        }
                    }

                    if ((root.handleClosedIcon.source || root.handleClosedIcon.name)
                        && (root.handleOpenIcon.source || root.handleOpenIcon.name)) {
                        return Qt.resolvedUrl("templates/private/GenericDrawerIcon.qml");
                    } else if (edge === Qt.LeftEdge ) {
                        return Qt.resolvedUrl("templates/private/MenuIcon.qml");
                    } else if(edge === Qt.RightEdge && root.hasOwnProperty("actions")) {
                        return Qt.resolvedUrl("templates/private/ContextIcon.qml");
                    } else {
                        return "";
                    }
                }
                onItemChanged: {
                    if (item) {
                        item.drawer = Qt.binding(function(){return root});
                        item.color = Qt.binding(function(){return root.handle.pressed ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor});
                    }
                }
            }
        }

        Kirigami.Separator {
            LayoutMirroring.enabled: false
            // LayoutMirroring.childrenInherit: true
            anchors {
                right: root.edge === Qt.RightEdge ? parent.left : (root.edge === Qt.LeftEdge ? undefined : parent.right)
                left: root.edge === Qt.LeftEdge ? parent.right : (root.edge === Qt.RightEdge ? undefined : parent.left)
                top: root.edge === Qt.TopEdge ? parent.bottom : (root.edge === Qt.BottomEdge ? undefined : parent.top)
                bottom: root.edge === Qt.BottomEdge ? parent.top : (root.edge === Qt.TopEdge ? undefined : parent.bottom)
            }
            visible: !root.modal
        }
        P.EdgeShadow {
            z: -2
            visible: root.modal
            edge: root.edge
            anchors {
                right: root.edge === Qt.RightEdge ? parent.left : (root.edge === Qt.LeftEdge ? undefined : parent.right)
                left: root.edge === Qt.LeftEdge ? parent.right : (root.edge === Qt.RightEdge ? undefined : parent.left)
                top: root.edge === Qt.TopEdge ? parent.bottom : (root.edge === Qt.BottomEdge ? undefined : parent.top)
                bottom: root.edge === Qt.BottomEdge ? parent.top : (root.edge === Qt.TopEdge ? undefined : parent.bottom)
            }

            opacity: root.position === 0 ? 0 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
