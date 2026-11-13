import QtQuick
import QtQuick.Window
import org.kde.plasma.plasmoid
import "code/life.js" as Life

WallpaperItem {
    id: root

    readonly property var activeScreen: Window.window ? Window.window.screen : null
    readonly property rect currentScreenGeometry: Qt.rect(Screen.virtualX, Screen.virtualY, Screen.width, Screen.height)
    readonly property rect allScreensGeometry: activeScreen ? activeScreen.virtualGeometry : currentScreenGeometry
    readonly property bool connected: wallpaper.configuration.connectedCanvas
    readonly property real canvasOffsetX: connected ? currentScreenGeometry.x - allScreensGeometry.x : 0
    readonly property real canvasOffsetY: connected ? currentScreenGeometry.y - allScreensGeometry.y : 0
    readonly property real simulationWidth: connected ? allScreensGeometry.width : width
    readonly property real simulationHeight: connected ? allScreensGeometry.height : height
    readonly property bool simulationLeader: !connected || (currentScreenGeometry.x === allScreensGeometry.x && currentScreenGeometry.y === allScreensGeometry.y)

    readonly property var spawnOptions: ({
        singles: wallpaper.configuration.spawnSingles,
        clouds: wallpaper.configuration.spawnClouds,
        gliders: wallpaper.configuration.spawnGliders,
        ships: wallpaper.configuration.spawnShips,
        oscillators: wallpaper.configuration.spawnOscillators,
        cloudSize: wallpaper.configuration.cloudSize,
        cloudDensity: wallpaper.configuration.cloudDensity
    })
    property int seenResetSerial: wallpaper.configuration.resetSerial
    property int seenClearSerial: wallpaper.configuration.clearSerial
    property double lastFrameTime: 0

    function rebuild() {
        Life.resize(simulationWidth, simulationHeight, wallpaper.configuration.cellSize,
                    wallpaper.configuration.initialDensity, connected)
        gameCanvas.requestPaint()
    }

    function scheduleSpawn() {
        if (wallpaper.configuration.randomSpawnInterval) {
            var low = Math.min(wallpaper.configuration.spawnIntervalMin,
                               wallpaper.configuration.spawnIntervalMax)
            var high = Math.max(wallpaper.configuration.spawnIntervalMin,
                                wallpaper.configuration.spawnIntervalMax)
            spawnTimer.interval = low + Math.floor(Math.random() * (high - low + 1))
        } else {
            spawnTimer.interval = wallpaper.configuration.spawnInterval
        }
    }

    // Called by the user-local desktop containment for clicks on empty desktop
    // space. Plasma normally keeps wallpaper items below its input layer.
    function handleDesktopPointer(x, y, buttons, isPress) {
        var drawAlive = (buttons & Qt.RightButton) === 0
        Life.addAtPixel(x + canvasOffsetX, y + canvasOffsetY,
                        wallpaper.configuration.mousePattern, drawAlive, spawnOptions)
        gameCanvas.requestPaint()
    }

    Canvas {
        id: gameCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: Life.paint(getContext("2d"), width, height, {
            color: wallpaper.configuration.color,
            backgroundColor: wallpaper.configuration.backgroundColor,
            birthEffectColor: wallpaper.configuration.effectColor,
            deathEffectColor: wallpaper.configuration.deathEffectColor,
            cellShape: wallpaper.configuration.cellShape,
            cellGap: wallpaper.configuration.cellGap,
            cornerRadius: wallpaper.configuration.cornerRadius,
            fluidStrength: wallpaper.configuration.fluidStrength,
            birthAnimationType: wallpaper.configuration.animationType,
            birthDuration: wallpaper.configuration.animationDuration,
            birthIntensity: wallpaper.configuration.animationIntensity,
            deathAnimationType: wallpaper.configuration.deathAnimationType,
            deathDuration: wallpaper.configuration.deathAnimationDuration,
            deathIntensity: wallpaper.configuration.deathAnimationIntensity
        }, root.canvasOffsetX, root.canvasOffsetY)
        onWidthChanged: resizeDelay.restart()
        onHeightChanged: resizeDelay.restart()
    }

    Timer {
        id: resizeDelay
        interval: 100
        onTriggered: root.rebuild()
    }

    Timer {
        id: generationTimer
        interval: Math.max(20, wallpaper.configuration.generationInterval)
        repeat: true
        running: !wallpaper.configuration.paused && root.simulationLeader
        onTriggered: {
            var result = Life.advanceIfDue(interval)
            if (result === 0)
                Life.randomize(wallpaper.configuration.initialDensity)
            if (result >= 0 && !wallpaper.configuration.smoothCells
                    && wallpaper.configuration.cellShape !== 3)
                Life.snapVisuals()
            if (result >= 0)
                gameCanvas.requestPaint()
        }
    }

    Timer {
        id: spawnTimer
        repeat: false
        running: wallpaper.configuration.autoSpawn && !wallpaper.configuration.paused && root.simulationLeader
        onTriggered: {
            if (Life.spawnMixedIfDue(wallpaper.configuration.spawnCount, root.spawnOptions, interval))
                gameCanvas.requestPaint()
            root.scheduleSpawn()
            start()
        }
        onRunningChanged: if (running) root.scheduleSpawn()
    }

    Timer {
        id: animationTimer
        interval: Math.max(16, Math.round(1000 / Math.max(15, wallpaper.configuration.animationFps)))
        repeat: true
        // A secondary monitor must repaint the shared state even when visual
        // effects are disabled; only the leader advances that shared state.
        running: (wallpaper.configuration.animationType !== 0
                  || wallpaper.configuration.deathAnimationType !== 0
                  || wallpaper.configuration.smoothCells
                  || wallpaper.configuration.cellShape === 3
                  || root.connected)
                 && !wallpaper.configuration.paused
        onTriggered: {
            if (root.simulationLeader) {
                var updated = Life.updateVisualsIfDue(interval,
                                                      wallpaper.configuration.cellTransitionDuration,
                                                      wallpaper.configuration.fluidSpeed,
                                                      wallpaper.configuration.smoothCells
                                                      || wallpaper.configuration.cellShape === 3)
                if (updated)
                    Life.updateEffects(interval,
                                       wallpaper.configuration.animationDuration,
                                       wallpaper.configuration.deathAnimationDuration)
            }
            gameCanvas.requestPaint()
        }
    }

    Connections {
        target: wallpaper.configuration
        function onCellSizeChanged() { root.rebuild() }
        function onInitialDensityChanged() { root.rebuild() }
        function onConnectedCanvasChanged() { root.rebuild() }
        function onResetSerialChanged() {
            if (root.seenResetSerial !== wallpaper.configuration.resetSerial) {
                root.seenResetSerial = wallpaper.configuration.resetSerial
                Life.randomize(wallpaper.configuration.initialDensity)
                gameCanvas.requestPaint()
            }
        }
        function onClearSerialChanged() {
            if (root.seenClearSerial !== wallpaper.configuration.clearSerial) {
                root.seenClearSerial = wallpaper.configuration.clearSerial
                Life.clear()
                gameCanvas.requestPaint()
            }
        }
    }

    Component.onCompleted: {
        rebuild()
        scheduleSpawn()
    }
}
