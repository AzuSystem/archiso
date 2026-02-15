/*
 *  SPDX-FileCopyrightText: 2020 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.14
import QtQuick.Controls 2.4 as QQC2
import org.kde.kirigami 2.13 as Kirigami

/**
 * @brief An element that implements a shared element transition, otherwise known as a "hero animation".
 */
Item {
    id: root

//BEGIN properties
    /**
     * @brief This property holds the item to animate from in the Hero animation.
     */
    property Item source

    /**
     * @brief This property holds the item to animate to in the Hero animation.
     */
    property Item destination

    /**
     * @brief This property sets whether the source item will reappear
     * in the original position when the Hero animation completes.
     *
     * default: ``true``
     */
    property bool restore: true

    /**
     * Group of properties related to the mask of the object when performing a hero animation.
     * This contains the default mask as well as the properties required to create a custom mask.
     *
     * The default mask of the Hero will transition from a circle to a rectangle on open(), and
     * from a rectangle to a circle on close().
     *
     * This grouped property has the following sub-properties:
     * * ``sourceProgress: real`` the progress of the animation, where 0 is the start and 1 is the end.
     * * ``destinationProgress: real`` the progress of the animation, where 1 is the start and 0 is the end.
     * * ``mask.sourceHeight: real`` the height of the source item.
     * * ``mask.sourceWidth: real`` the width of the source item.
     * * ``mask.destinationWidth: real`` the width of the destination item.
     * * ``mask.destinationHeight: real`` the height of the destination item.
     * * ``item: Rectangle`` the item used to mask the Hero during animation. This should bind to the sourceProgress and destinationProgress to change as the animation progresses.
     *
     */
    readonly property QtObject mask: QtObject {
        /**
         * @brief This property holds the progress of the animation,
         * where 0 is the start and 1 is the end.
         */
        readonly property real sourceProgress: sourceEffect.progress

        /**
         * @brief This property holds the progress of the animation,
         * where 1 is the start and 0 is the end.
         */
        readonly property real destinationProgress: destinationEffect.progress

        /**
         * @brief This property holds the height of the source item.
         */
        readonly property real sourceHeight: sourceEffect.height

        /**
        * @brief This property holds the width of the source item.
        */
        readonly property real sourceWidth: sourceEffect.width

        /**
         * @brief This property holds the width of the destination item.
         */
        readonly property real destinationWidth: destinationEffect.width

        /**
         * @brief This property holds the height of the destination item.
         */
        readonly property real destinationHeight: destinationEffect.height

        /**
         * @brief This property holds the item used to mask the Hero during animation.
         *
         * This should bind to the sourceProgress and destinationProgress to change as the animation progresses.
         */
        property Item item: Rectangle {
            visible: false
            color: "white"

            radius: (width/2) * mask.destinationProgress
            width: (mask.sourceWidth * mask.sourceProgress) + (mask.destinationWidth * mask.destinationProgress)
            height: (mask.sourceHeight * mask.sourceProgress) + (mask.destinationHeight * mask.destinationProgress)

            layer.enabled: true
            layer.smooth: true
        }
    }

    property alias duration: sourceAni.duration
    readonly property QtObject easing: QtObject {
        property alias amplitude: sourceAni.easing.amplitude
        property alias bezierCurve: sourceAni.easing.bezierCurve
        property alias overshoot: sourceAni.easing.overshoot
        property alias period: sourceAni.easing.period
        property alias type: sourceAni.easing.type
    }
//END properties

    function open() {
        if (source !== null && destination !== null && !heroAnimation.running) {
            heroAnimation.source = source
            heroAnimation.destination = destination
            heroAnimation.restart()
        }
    }
    function close() {
        if (source !== null && destination !== null && !heroAnimation.running) {
            // doing a switcheroo simplifies the code
            heroAnimation.source = destination
            heroAnimation.destination = source
            heroAnimation.restart()
        }
    }

    SequentialAnimation {
        id: heroAnimation

        property Item source: Item {}
        property Item destination: Item {}

        ScriptAction {
            script: {
                heroAnimation.source.layer.enabled = true
                heroAnimation.source.layer.smooth = true
                heroAnimation.destination.layer.enabled = true
                heroAnimation.destination.layer.smooth = true
                sourceEffect.visible = true
                destinationEffect.visible = true
                sourceEffect.source = null
                sourceEffect.source = heroAnimation.source
                destinationEffect.source = null
                destinationEffect.source = heroAnimation.destination
                heroAnimation.source.opacity = 0
                heroAnimation.destination.opacity = 0
                sourceEffect.parent.visible = true
            }
        }
        ParallelAnimation {
            NumberAnimation {
                id: sourceAni

                target: sourceEffect
                property: "progress"
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: destinationEffect
                property: "progress"
                from: 1
                to: 0
                duration: root.duration
                easing.amplitude: root.easing.amplitude
                easing.bezierCurve: root.easing.bezierCurve
                easing.overshoot: root.easing.overshoot
                easing.period: root.easing.period
                easing.type: root.easing.type
            }
        }
        ScriptAction {
            script: {
                sourceEffect.visible = false
                destinationEffect.visible = false
                heroAnimation.source.layer.enabled = false
                heroAnimation.source.layer.smooth = false
                heroAnimation.destination.layer.enabled = false
                heroAnimation.destination.layer.smooth = false
                heroAnimation.destination.opacity = 1
                if (root.restore) {
                    heroAnimation.source.opacity = 1
                }
                sourceEffect.parent.visible = false
            }
        }

    }

    QtObject {
        id: __privateShaderSources
        readonly property string vertexShader: `
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
uniform highp float startX;
uniform highp float startY;
uniform highp float targetX;
uniform highp float targetY;
uniform highp float scaleWidth;
uniform highp float scaleHeight;
uniform highp float progress;

highp mat4 morph = mat4(1.0 + (scaleWidth - 1.0) * progress, 0.0, 0.0, startX*(1.0-progress) + targetX*progress,
                        0.0, 1.0 + (scaleHeight - 1.0) * progress, 0.0, startY*(1.0-progress) + targetY*progress,
                        0.0, 0.0, 1.0, 0.0,
                        0.0, 0.0, 0.0, 1.0);

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    gl_Position = qt_Matrix * qt_Vertex * morph;
}
        `
    }

    ShaderEffect {
        id: sourceEffect
        x: 0
        y: 0
        parent: heroAnimation.source.QQC2.Overlay.overlay
        width: heroAnimation.source.width
        height: heroAnimation.source.height
        visible: false
        property variant source: heroAnimation.source
        property real progress: 0
        property real startX: heroAnimation.source.Kirigami.ScenePosition.x / (applicationWindow().width / 2)
        property real startY: -heroAnimation.source.Kirigami.ScenePosition.y / (applicationWindow().height / 2)

        property real targetX: scaleWidth - 1 + (heroAnimation.destination.Kirigami.ScenePosition.x * 2) / applicationWindow().width
        property real targetY: 1-scaleHeight - (heroAnimation.destination.Kirigami.ScenePosition.y * 2) / applicationWindow().height
        property real scaleWidth: heroAnimation.destination.width/heroAnimation.source.width
        property real scaleHeight: heroAnimation.destination.height/heroAnimation.source.height
        vertexShader: __privateShaderSources.vertexShader
        fragmentShader: `
varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform lowp float qt_Opacity;
uniform lowp float progress;
void main() {
    gl_FragColor = texture2D(source, qt_TexCoord0) * qt_Opacity * (1.0 - progress);
}
        `
    }

    ShaderEffect {
        id: destinationEffect
        x: 0
        y: 0
        parent: heroAnimation.destination.QQC2.Overlay.overlay
        width: heroAnimation.destination.width
        height: heroAnimation.destination.height
        visible: false
        property variant source: heroAnimation.destination
        property real progress: sourceEffect.progress
        property real startX: heroAnimation.destination.Kirigami.ScenePosition.x / (applicationWindow().width / 2)
        property real startY: -heroAnimation.destination.Kirigami.ScenePosition.y / (applicationWindow().height / 2)

        property real targetX: scaleWidth - 1 + (heroAnimation.source.Kirigami.ScenePosition.x * 2) / applicationWindow().width
        property real targetY: 1-scaleHeight - (heroAnimation.source.Kirigami.ScenePosition.y * 2) / applicationWindow().height
        property real scaleWidth: heroAnimation.source.width/heroAnimation.destination.width
        property real scaleHeight: heroAnimation.source.height/heroAnimation.destination.height

        property variant maskSource: root.mask.item

        vertexShader: __privateShaderSources.vertexShader
        fragmentShader: `
varying highp vec2 qt_TexCoord0;
uniform sampler2D source;
uniform sampler2D maskSource;
uniform lowp float qt_Opacity;
uniform lowp float progress;
void main() {
    gl_FragColor = texture2D(source, qt_TexCoord0) * texture2D(maskSource, qt_TexCoord0).a * qt_Opacity *  (1.0 - progress);
}
        `
    }
}
