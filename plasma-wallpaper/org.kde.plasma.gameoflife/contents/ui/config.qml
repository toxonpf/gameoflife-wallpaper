import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kquickcontrols as KQuickControls

ScrollView {
    id: root
    implicitWidth: 560
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    WheelHandler {
        id: scrollWheelHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: function(event) {
            var flickable = root.contentItem
            var maximum = Math.max(0, flickable.contentHeight - flickable.height)
            var pixelDelta = event.pixelDelta.y !== 0 ? event.pixelDelta.y : event.angleDelta.y / 2
            flickable.contentY = Math.max(0, Math.min(maximum, flickable.contentY - pixelDelta))
            event.accepted = true
        }
    }

    property alias cfg_color: cellColor.color
    property alias cfg_backgroundColor: backgroundColor.color
    property alias cfg_effectColor: effectColor.color
    property alias cfg_generationInterval: generationInterval.value
    property alias cfg_cellSize: cellSize.value
    property alias cfg_cellShape: cellShape.currentIndex
    property alias cfg_cellGap: cellGap.value
    property alias cfg_cornerRadius: cornerRadius.value
    property alias cfg_smoothCells: smoothCells.checked
    property alias cfg_cellTransitionDuration: cellTransitionDuration.value
    property alias cfg_fluidStrength: fluidStrength.value
    property alias cfg_fluidSpeed: fluidSpeed.value
    property alias cfg_initialDensity: initialDensity.value
    property alias cfg_paused: paused.checked
    property alias cfg_connectedCanvas: connectedCanvas.checked
    property alias cfg_autoSpawn: autoSpawn.checked
    property alias cfg_randomSpawnInterval: randomInterval.checked
    property alias cfg_spawnInterval: spawnInterval.value
    property alias cfg_spawnIntervalMin: spawnMin.value
    property alias cfg_spawnIntervalMax: spawnMax.value
    property alias cfg_spawnCount: spawnCount.value
    property alias cfg_spawnSingles: spawnSingles.checked
    property alias cfg_spawnClouds: spawnClouds.checked
    property alias cfg_spawnGliders: spawnGliders.checked
    property alias cfg_spawnShips: spawnShips.checked
    property alias cfg_spawnOscillators: spawnOscillators.checked
    property alias cfg_cloudSize: cloudSize.value
    property alias cfg_cloudDensity: cloudDensity.value
    property alias cfg_animationType: animationType.currentIndex
    property alias cfg_animationDuration: animationDuration.value
    property alias cfg_animationIntensity: animationIntensity.value
    property alias cfg_animationFps: animationFps.value
    property alias cfg_deathAnimationType: deathAnimationType.currentIndex
    property alias cfg_deathAnimationDuration: deathAnimationDuration.value
    property alias cfg_deathAnimationIntensity: deathAnimationIntensity.value
    property alias cfg_deathEffectColor: deathEffectColor.color
    property alias cfg_mousePattern: mousePattern.currentIndex
    property int cfg_resetSerial: 0
    property int cfg_clearSerial: 0

    component NumberSetting: RowLayout {
        id: numberSettingRoot
        property alias text: settingLabel.text
        property alias value: settingSpin.value
        property alias from: settingSpin.from
        property alias to: settingSpin.to
        property alias stepSize: settingSpin.stepSize
        property string suffix: ""
        Layout.fillWidth: true
        Label { id: settingLabel; Layout.fillWidth: true }
        SpinBox {
            id: settingSpin
            editable: true
            textFromValue: function(value, locale) {
                return Number(value).toLocaleString(locale, "f", 0) + numberSettingRoot.suffix
            }
            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, text.replace(numberSettingRoot.suffix, ""))
            }
        }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 10

        GroupBox {
            title: i18n("Simulation")
            Layout.fillWidth: true
            GridLayout {
                columns: 2; anchors.fill: parent
                Label { text: i18n("Cell color") }
                KQuickControls.ColorButton { id: cellColor; dialogTitle: i18n("Select cell color") }
                Label { text: i18n("Background color") }
                KQuickControls.ColorButton { id: backgroundColor; dialogTitle: i18n("Select background color") }
                NumberSetting { id: generationInterval; text: i18n("Generation interval"); from: 20; to: 5000; stepSize: 10; suffix: i18n(" ms"); Layout.columnSpan: 2 }
                NumberSetting { id: cellSize; text: i18n("Cell size"); from: 2; to: 40; suffix: i18n(" px"); Layout.columnSpan: 2 }
                Label { text: i18n("Cell shape") }
                ComboBox {
                    id: cellShape
                    model: [i18n("Square"), i18n("Rounded square"), i18n("Circle"), i18n("Fluid blobs")]
                    Layout.fillWidth: true
                }
                NumberSetting { id: cellGap; text: i18n("Gap between cells"); from: 0; to: 45; suffix: i18n("%"); Layout.columnSpan: 2 }
                NumberSetting { id: cornerRadius; text: i18n("Corner rounding"); from: 0; to: 100; suffix: i18n("%"); enabled: cellShape.currentIndex === 1; Layout.columnSpan: 2 }
                CheckBox { id: smoothCells; text: i18n("Smoothly grow and shrink cells"); Layout.columnSpan: 2 }
                NumberSetting { id: cellTransitionDuration; text: i18n("Growth and disappearance duration"); from: 50; to: 2000; stepSize: 50; suffix: i18n(" ms"); enabled: smoothCells.checked || cellShape.currentIndex === 3; Layout.columnSpan: 2 }
                NumberSetting { id: fluidStrength; text: i18n("Fluidity and blob connections"); from: 0; to: 100; suffix: i18n("%"); enabled: cellShape.currentIndex === 3; Layout.columnSpan: 2 }
                NumberSetting { id: fluidSpeed; text: i18n("Drop movement speed"); from: 1; to: 100; suffix: i18n("%"); enabled: cellShape.currentIndex === 3; Layout.columnSpan: 2 }
                NumberSetting { id: initialDensity; text: i18n("Initial fill"); from: 0; to: 100; suffix: i18n("%"); Layout.columnSpan: 2 }
                CheckBox { id: connectedCanvas; text: i18n("Combine all monitors into one continuous field"); Layout.columnSpan: 2 }
                CheckBox { id: paused; text: i18n("Pause simulation"); Layout.columnSpan: 2 }
            }
        }

        GroupBox {
            title: i18n("Automatic spawning")
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                CheckBox { id: autoSpawn; text: i18n("Add random objects automatically") }
                CheckBox { id: randomInterval; text: i18n("Use a random interval"); enabled: autoSpawn.checked }
                NumberSetting { id: spawnInterval; text: i18n("Fixed interval"); from: 100; to: 60000; stepSize: 100; suffix: i18n(" ms"); enabled: autoSpawn.checked && !randomInterval.checked }
                NumberSetting { id: spawnMin; text: i18n("Minimum interval"); from: 100; to: 60000; stepSize: 100; suffix: i18n(" ms"); enabled: autoSpawn.checked && randomInterval.checked }
                NumberSetting { id: spawnMax; text: i18n("Maximum interval"); from: 100; to: 60000; stepSize: 100; suffix: i18n(" ms"); enabled: autoSpawn.checked && randomInterval.checked }
                NumberSetting { id: spawnCount; text: i18n("Objects per spawn"); from: 1; to: 100; enabled: autoSpawn.checked }
                Label { text: i18n("Randomly mix the selected object groups:"); font.bold: true }
                Flow {
                    Layout.fillWidth: true; spacing: 6
                    CheckBox { id: spawnSingles; text: i18n("Single cells") }
                    CheckBox { id: spawnClouds; text: i18n("Clouds") }
                    CheckBox { id: spawnGliders; text: i18n("Gliders") }
                    CheckBox { id: spawnShips; text: i18n("Spaceships") }
                    CheckBox { id: spawnOscillators; text: i18n("Oscillators") }
                }
                NumberSetting { id: cloudSize; text: i18n("Cloud size"); from: 2; to: 40 }
                NumberSetting { id: cloudDensity; text: i18n("Cloud density"); from: 1; to: 100; suffix: i18n("%") }
            }
        }

        GroupBox {
            title: i18n("Birth animation")
            Layout.fillWidth: true
            GridLayout {
                columns: 2; anchors.fill: parent
                Label { text: i18n("Effect") }
                ComboBox {
                    id: animationType
                    model: [i18n("None"), i18n("Fade"), i18n("Flash"), i18n("Pulse"), i18n("Wave"), i18n("Color shift"), i18n("Pop"), i18n("Double ripple"), i18n("Sparks"), i18n("Dissolve")]
                    Layout.fillWidth: true
                }
                Label { text: i18n("Effect color") }
                KQuickControls.ColorButton { id: effectColor; dialogTitle: i18n("Select effect color"); enabled: animationType.currentIndex > 0 }
                NumberSetting { id: animationDuration; text: i18n("Duration"); from: 50; to: 5000; stepSize: 50; suffix: i18n(" ms"); enabled: animationType.currentIndex > 0; Layout.columnSpan: 2 }
                NumberSetting { id: animationIntensity; text: i18n("Intensity"); from: 1; to: 100; suffix: i18n("%"); enabled: animationType.currentIndex > 0; Layout.columnSpan: 2 }
                NumberSetting { id: animationFps; text: i18n("Animation FPS"); from: 15; to: 60; stepSize: 15; enabled: animationType.currentIndex > 0; Layout.columnSpan: 2 }
            }
        }

        GroupBox {
            title: i18n("Disappearance animation")
            Layout.fillWidth: true
            GridLayout {
                columns: 2; anchors.fill: parent
                Label { text: i18n("Effect") }
                ComboBox {
                    id: deathAnimationType
                    model: [i18n("None"), i18n("Fade"), i18n("Flash"), i18n("Pulse"), i18n("Wave"), i18n("Color shift"), i18n("Pop"), i18n("Double ripple"), i18n("Sparks"), i18n("Dissolve")]
                    Layout.fillWidth: true
                }
                Label { text: i18n("Effect color") }
                KQuickControls.ColorButton { id: deathEffectColor; dialogTitle: i18n("Select disappearance effect color"); enabled: deathAnimationType.currentIndex > 0 }
                NumberSetting { id: deathAnimationDuration; text: i18n("Duration"); from: 50; to: 5000; stepSize: 50; suffix: i18n(" ms"); enabled: deathAnimationType.currentIndex > 0; Layout.columnSpan: 2 }
                NumberSetting { id: deathAnimationIntensity; text: i18n("Intensity"); from: 1; to: 100; suffix: i18n("%"); enabled: deathAnimationType.currentIndex > 0; Layout.columnSpan: 2 }
                Label { text: i18n("Animation FPS is shared with the birth effect."); opacity: 0.7; Layout.columnSpan: 2 }
            }
        }

        GroupBox {
            title: i18n("Mouse and field")
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    Label { text: i18n("Left-click draws"); Layout.fillWidth: true }
                    ComboBox { id: mousePattern; model: [i18n("Cell"), i18n("Glider"), i18n("Spaceship"), i18n("Blinker"), i18n("Toad"), i18n("Beacon"), i18n("Pulsar"), i18n("Cloud")]; Layout.preferredWidth: 220 }
                }
                Label { text: i18n("Drag with the left button to draw; drag with the right button to erase."); wrapMode: Text.WordWrap; Layout.fillWidth: true }
                RowLayout {
                    Button { text: i18n("Fill randomly now"); onClicked: root.cfg_resetSerial++ }
                    Button { text: i18n("Clear field now"); onClicked: root.cfg_clearSerial++ }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: i18n("Restore defaults")
                        onClicked: {
                            cellColor.color = "#00ff66"; backgroundColor.color = "#000000"; effectColor.color = "#ffffff"
                            generationInterval.value = 250; cellSize.value = 10; cellShape.currentIndex = 0
                            cellGap.value = 0; cornerRadius.value = 35; smoothCells.checked = true
                            cellTransitionDuration.value = 350; fluidStrength.value = 65; fluidSpeed.value = 45
                            initialDensity.value = 10; connectedCanvas.checked = true; paused.checked = false
                            autoSpawn.checked = true; randomInterval.checked = true; spawnInterval.value = 3000
                            spawnMin.value = 1000; spawnMax.value = 5000; spawnCount.value = 1
                            spawnSingles.checked = true; spawnClouds.checked = true; spawnGliders.checked = true
                            spawnShips.checked = true; spawnOscillators.checked = true; cloudSize.value = 12; cloudDensity.value = 45
                            animationType.currentIndex = 1; animationDuration.value = 500; animationIntensity.value = 70; animationFps.value = 30
                            deathAnimationType.currentIndex = 7; deathAnimationDuration.value = 650
                            deathAnimationIntensity.value = 75; deathEffectColor.color = "#66ccff"
                            mousePattern.currentIndex = 0
                        }
                    }
                }
            }
        }
    }
}
