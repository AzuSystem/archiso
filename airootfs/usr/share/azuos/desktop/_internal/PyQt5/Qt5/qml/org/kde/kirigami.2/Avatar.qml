/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.13
import QtQuick.Window 2.15
import QtQuick.Controls 2.13 as QQC2
import QtGraphicalEffects 1.0 as GE
import org.kde.kirigami 2.14 as Kirigami
import org.kde.kirigami.private 2.14 as KP
import "templates/private" as TP

//TODO KF6: generic enough or belongs to a different framework?
/**
 * @brief An element that represents a user, either with initials, an icon, or a profile image.
 * @inherit QtQuick.Controls.Control
 */
QQC2.Control {
    id: avatarRoot

    enum ImageMode {
        AlwaysShowImage,
        AdaptiveImageOrInitals,
        AlwaysShowInitials
    }
    enum InitialsMode {
        UseInitials,
        UseIcon
    }

//BEGIN properties
    /**
     * @brief This property holds the given name of a user.
     *
     * The user's name will be used for generating initials and to provide the
     * accessible name for assistive technology.
     */
    property string name

    /**
     * @brief This property holds the source of the user's profile picture; an image.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-image.html#source-prop">Image.source</a>
     * @property url source
     */
    property alias source: avatarImage.source

    /**
     * @brief This property holds the avatar's icon source.
     *
     * The icon acts as a fallback in case the profile image set via `source`
     * takes too long to load or is undefined, or in case no `name` or `source`
     * has been set.
     *
     * To force display the icon when both ``name`` and ``source`` are set, you
     * may set ``imageMode`` to ``Kirigami.Avatar.ImageMode.AlwaysShowInitials``
     * to make it fallback to using initials, and then change ``initialsMode``
     * to ``Kirigami.Avatar.InitialsMode.UseIcon`` to display the icon.
     *
     * @see Icon::source
     * @property var iconSource
     */
    property alias iconSource: avatarIcon.source

    /**
     * @brief This property holds how the button should represent the user when no user-set image is available.
     *
     * The following values are allowed:
     * * ``Avatar.InitialsMode.UseInitials``: Show the user's initials.
     * * ``Avatar.InitialsMode.UseIcon``: Show a generic icon.
     *
     * @see ::InitialsMode
     */
    property int initialsMode: Kirigami.Avatar.InitialsMode.UseInitials

    /**
     * @brief This property holds how the avatar should be shown.
     *
     * This property holds whether the button should always show the image; show the image if one is
     * available and show initials when it is not; or always show initials.
     *
     * The following values are allowed:
     * * ``Avatar.ImageMode.AlwaysShowImage``: Always try to show the image; even if it hasn't loaded yet or is undefined.
     * * ``Avatar.ImageMode.AdaptiveImageOrInitals``: Show the image if it is valid; or show initials if it is not
     * * ``Avatar.ImageMode.AlwaysShowInitials``: Always show initials
     *
     * @see ::ImageMode
     */
    property int imageMode: Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals

    /**
     * @brief This property sets whether the provided image should be cached.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-image.html#cache-prop">Image.cache</a>
     * @property bool cache
     */
    property alias cache: avatarImage.cache

    /**
     * @brief This property holds the source size of the user's profile picture.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-image.html#sourceSize-prop">Image.sourceSize</a>
     * @property int sourceSize
     */
    property alias sourceSize: avatarImage.sourceSize

    /**
     * @brief This property holds whether the provided image should be smoothed.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-image.html#smooth-prop">Image.smooth</a>
     * @property bool smooth
     */
    property alias smooth: avatarImage.smooth

    /**
     * @brief This property holds the color to use for this avatar.
     *
     * If not explicitly set, this defaults to generating a color from the name.
     *
     * @property color color
     */
    property var color: Kirigami.NameUtils.colorsFromString(name)
    // We use a var instead of a color here to allow setting the colour
    // as undefined, which will result in a generated colour being used.

    /**
     * @brief This property holds the main and secondary actions associated with this avatar.
     * @code{.qml}
     * Kirigami.Avatar {
     *     actions.main: Kirigami.Action {}
     *     actions.secondary: Kirigami.Action {}
     * }
     * @endcode
     *
     * Actions associated with this avatar.
     *
     * @note The secondary action should only be used for shortcuts of actions
     * elsewhere in your application's UI, and cannot be accessed on mobile platforms.
     */
    property KP.AvatarGroup actions: KP.AvatarGroup {}

    /**
     * @brief This property holds the border properties group.
     *
     * Example usage:
     * @code{.qml}
     * Kirigami.Avatar {
     *     border.width: 10
     *     border.color: "red"
     * }
     * @endcode
     */
    property TP.BorderPropertiesGroup border: TP.BorderPropertiesGroup {
        width: 0
        color: Qt.rgba(0,0,0,0.2)
    }
//END properties

    padding: 0
    horizontalPadding: padding
    verticalPadding: padding
    leftPadding: horizontalPadding
    rightPadding: horizontalPadding
    topPadding: verticalPadding
    bottomPadding: verticalPadding

    implicitWidth: Kirigami.Units.iconSizes.large
    implicitHeight: Kirigami.Units.iconSizes.large

    activeFocusOnTab: !!actions.main

    Accessible.role: !!actions.main ? Accessible.Button : Accessible.Graphic
    Accessible.name: !!actions.main ? qsTr("%1 — %2").arg(name).arg(actions.main.text) : name
    Accessible.focusable: !!actions.main
    Accessible.onPressAction: __triggerMainAction()
    Keys.onReturnPressed: event => __triggerMainAction()
    Keys.onEnterPressed: event => __triggerMainAction()
    Keys.onSpacePressed: event => __triggerMainAction()

    function __triggerMainAction() {
        if (actions.main) {
            actions.main.trigger();
        }
    }

    background: Rectangle {
        radius: parent.width / 2

        color: __private.showImage ? Kirigami.Theme.backgroundColor : avatarRoot.color

        Rectangle {
            anchors.fill: parent
            anchors.margins: -border.width

            radius: width / 2

            color: "transparent"
            border.width: Kirigami.Units.smallSpacing
            border.color: Kirigami.Theme.focusColor
            visible: avatarRoot.focus
        }

        MouseArea {
            id: primaryMouse

            anchors.fill: parent
            hoverEnabled: true
            property bool mouseInCircle: {
                const x = avatarRoot.width / 2, y = avatarRoot.height / 2
                const xPrime = mouseX, yPrime = mouseY

                const distance = (x - xPrime) ** 2 + (y - yPrime) ** 2
                const radiusSquared = (Math.min(avatarRoot.width, avatarRoot.height) / 2) ** 2

                return distance < radiusSquared
            }

            onClicked: mouse =>{
                if (mouseY > avatarRoot.height - secondaryRect.height && !!avatarRoot.actions.secondary) {
                    avatarRoot.actions.secondary.trigger()
                    return
                }
                avatarRoot.__triggerMainAction()
            }

            enabled: !!avatarRoot.actions.main || !!avatarRoot.actions.secondary
            cursorShape: containsMouse && mouseInCircle && enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            QQC2.ToolTip {
                text: avatarRoot.actions.main && avatarRoot.actions.main.tooltip ? avatarRoot.actions.main.tooltip : ''
                visible: primaryMouse.containsMouse && text
            }

            states: [
                State {
                    name: "secondaryRevealed"
                    when: (!Kirigami.Settings.isMobile) && (!!avatarRoot.actions.secondary) && (primaryMouse.containsMouse && primaryMouse.mouseInCircle)
                    PropertyChanges {
                        target: secondaryRect
                        visible: true
                    }
                }
            ]
        }
    }

    QtObject {
        id: __private
        property color textColor: Kirigami.ColorUtils.brightnessForColor(avatarRoot.color) === Kirigami.ColorUtils.Light
                                ? "black"
                                : "white"
        property bool showImage: {
            return (avatarRoot.imageMode === Kirigami.Avatar.ImageMode.AlwaysShowImage) ||
                   (avatarImage.status === Image.Ready && avatarRoot.imageMode === Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals)
        }
    }

    contentItem: Item {
        Text {
            id: avatarText
            fontSizeMode: Text.Fit
            visible: avatarRoot.initialsMode === Kirigami.Avatar.InitialsMode.UseInitials &&
                    !__private.showImage &&
                    !Kirigami.NameUtils.isStringUnsuitableForInitials(avatarRoot.name) &&
                    avatarRoot.width > Kirigami.Units.gridUnit

            text: Kirigami.NameUtils.initialsFromString(name)
            color: __private.textColor

            anchors.fill: parent
            font {
                // this ensures we don't get a both point and pixel size are set warning
                pointSize: -1
                pixelSize: (avatarRoot.height - Kirigami.Units.largeSpacing) / 2
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Kirigami.Icon {
            id: avatarIcon
            visible: (avatarRoot.initialsMode === Kirigami.Avatar.InitialsMode.UseIcon && !__private.showImage) ||
                    (Kirigami.NameUtils.isStringUnsuitableForInitials(avatarRoot.name) && !__private.showImage)

            source: "user"

            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing

            color: __private.textColor
        }
        Image {
            id: avatarImage
            visible: __private.showImage

            mipmap: true
            smooth: true
            sourceSize {
                width: avatarRoot.width * Screen.devicePixelRatio
                height: avatarRoot.height * Screen.devicePixelRatio
            }

            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }

        Rectangle {
            color: "transparent"

            radius: width / 2
            anchors.fill: parent

            border {
                width: avatarRoot.border.width
                color: avatarRoot.border.color
            }
        }

        Rectangle {
            id: secondaryRect
            visible: false

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            height: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing*2

            color: Qt.rgba(0, 0, 0, 0.6)

            Kirigami.Icon {
                Kirigami.Theme.textColor: "white"
                source: (avatarRoot.actions.secondary || {iconName: ""}).iconName

                width: Kirigami.Units.iconSizes.small
                height: Kirigami.Units.iconSizes.small

                x: Math.round((parent.width/2)-(this.width/2))
                y: Math.round((parent.height/2)-(this.height/2))
            }
        }

        layer.enabled: true
        layer.effect: GE.OpacityMask {
            maskSource: Rectangle {
                height: avatarRoot.height
                width: avatarRoot.width
                radius: height / 2
                color: "black"
                visible: false
            }
        }
    }
}
