import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import jlqml

ApplicationWindow {
    width: 600
    height: 700
    visible: true
    title: "Luxor + QML.jl Viewer"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // 1. TOP: Buttons arranged side-by-side
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            Button {
                text: "Generate Pattern"
                
                // Added horizontal and vertical padding
                topPadding: 15
                bottomPadding: 15
                leftPadding: 30
                rightPadding: 30
                
                onClicked: Julia.generate_luxor_svg(luxor_view)
            }

            Button {
                text: "Save (PDF and JSON)"
                
                // Added horizontal and vertical padding
                topPadding: 15
                bottomPadding: 15
                leftPadding: 30
                rightPadding: 30
                
                onClicked: Julia.save_pdf_json()
            }
        }

        // 2. MIDDLE: Status Message
        Label {
            text: svgProps.status
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 14
            color: "dimgrey"
            font.italic: true
        }

        // 3. BOTTOM: The SVG Display Container
        Item {
            id: displayContainer
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: aspectFrame
                property real targetRatio: svgProps.width / svgProps.height

                width: parent.width / parent.height > targetRatio 
                       ? parent.height * targetRatio 
                       : parent.width
                height: parent.width / parent.height > targetRatio 
                        ? parent.height 
                        : parent.width / targetRatio
                anchors.centerIn: parent

                JuliaDisplay {
                    id: luxor_view
                    anchors.fill: parent
                    
                    Component.onCompleted: {
                        Julia.generate_luxor_svg(luxor_view)
                    }
                }
            }
        }
    }
}