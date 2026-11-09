pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: view
    property var payload: ({})
    property string problem: ""
    property bool busy: false
    property color accent: "#1dc544"
    property string selectedDate: ""
    readonly property var days: payload.days || []
    readonly property var selected: days.find(function(d) { return d.date === view.selectedDate; }) || null
    signal moveMonth(int delta)
    signal todayRequested()
    signal refreshRequested()
    onDaysChanged: {
        if (!days.some(function(d) { return d.date === view.selectedDate; }))
            selectedDate = days.some(function(d) { return d.date === view.payload.today; }) ? payload.today : payload.first || "";
    }
    component Action: Button {
        id: action
        implicitWidth: Math.max(27, contentItem.implicitWidth + 12)
        implicitHeight: 27
        enabled: !view.busy
        contentItem: Text { text: action.text; color: action.hovered ? view.accent : "#f2f2f2"; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { color: "transparent"; radius: 0; border.width: 1; border.color: action.activeFocus ? view.accent : "#55ffffff" }
    }
    Rectangle { anchors.fill: parent; color: Qt.rgba(10/255,10/255,10/255,.58); radius: 0; border.color: "#d9ffffff" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 12; spacing: 9
        RowLayout {
            Rectangle {
                implicitWidth: heading.implicitWidth+16; implicitHeight: 29; color: "#47000000"; border.color: "#d9ffffff"
                Text { id: heading; anchors.centerIn: parent; text: "CALENDARIO"; color: view.accent; font.pixelSize: 12; font.letterSpacing: 1.5; font.weight: Font.DemiBold }
            }
            Item { Layout.fillWidth: true }
            Action { text: "OGGI"; onClicked: { view.selectedDate = view.payload.today || ""; view.todayRequested(); } }
            Action { text: "↻"; Accessible.name: "Aggiorna calendario"; onClicked: view.refreshRequested() }
        }
        RowLayout {
            Action { text: "‹"; Accessible.name: "Mese precedente"; onClicked: view.moveMonth(-1) }
            Text { Layout.fillWidth: true; text: (view.payload.month || "Skykeep").toUpperCase(); color: "#f2f2f2"; font.pixelSize: 13; font.letterSpacing: 1; horizontalAlignment: Text.AlignHCenter }
            Action { text: "›"; Accessible.name: "Mese successivo"; onClicked: view.moveMonth(1) }
        }
        GridLayout {
            Layout.fillWidth: true; columns: 7; rowSpacing: 3; columnSpacing: 3
            Repeater {
                model: ["L","M","M","G","V","S","D"]
                Text { required property string modelData; Layout.fillWidth: true; text: modelData; color: "#a3a3a3"; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 10 }
            }
            Repeater {
                model: view.days
                Rectangle {
                    id: day
                    required property var modelData
                    Layout.fillWidth: true; implicitHeight: 27
                    color: modelData.date === view.selectedDate ? Qt.rgba(view.accent.r,view.accent.g,view.accent.b,.2) : "transparent"
                    border.width: modelData.date === view.selectedDate || modelData.date === view.payload.today ? 1 : 0
                    border.color: view.accent
                    Text { anchors.centerIn: parent; text: day.modelData.number; color: day.modelData.currentMonth ? "#f2f2f2" : "#b3b3b3"; font.pixelSize: 11 }
                    Rectangle { width: 3; height: 3; anchors.bottom: parent.bottom; anchors.bottomMargin: 2; anchors.horizontalCenter: parent.horizontalCenter; color: view.accent; visible: day.modelData.count > 0 }
                    MouseArea { anchors.fill: parent; onClicked: view.selectedDate = day.modelData.date }
                    Accessible.role: Accessible.Button
                    Accessible.name: modelData.date + ", " + modelData.count + " impegni"
                    Accessible.onPressAction: view.selectedDate = modelData.date
                }
            }
        }
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#47ffffff" }
        Text { text: view.selected ? view.selected.label.toUpperCase() : "AGENDA"; color: view.accent; font.pixelSize: 11; font.letterSpacing: .8 }
        Text { visible: view.problem !== ""; text: view.problem; textFormat: Text.PlainText; color: "#f2f2f2"; wrapMode: Text.Wrap; Layout.fillWidth: true; font.pixelSize: 11 }
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 6
            model: view.selected ? view.selected.events : []
            ScrollBar.vertical: ScrollBar { }
            delegate: Rectangle {
                id: eventCard
                required property var modelData
                width: ListView.view.width; implicitHeight: eventContent.implicitHeight+16
                color: "#47000000"; border.color: "#47ffffff"; radius: 0
                RowLayout {
                    id: eventContent; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 8; spacing: 9
                    Rectangle { Layout.preferredWidth: 2; Layout.fillHeight: true; color: view.accent }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 3
                        Text { text: eventCard.modelData.time; color: view.accent; font.pixelSize: 10; font.letterSpacing: .5 }
                        Text { text: eventCard.modelData.title || "Senza titolo"; textFormat: Text.PlainText; color: eventCard.modelData.past ? "#a3a3a3" : "#f2f2f2"; font.pixelSize: 12; font.weight: Font.DemiBold; wrapMode: Text.Wrap; Layout.fillWidth: true }
                        Text { text: eventCard.modelData.calendar + (eventCard.modelData.location ? " · " + eventCard.modelData.location : ""); textFormat: Text.PlainText; color: "#a3a3a3"; font.pixelSize: 10; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    }
                }
            }
            Text { anchors.centerIn: parent; visible: !view.problem && (!view.selected || view.selected.count === 0); text: view.busy ? "CARICAMENTO…" : "NESSUN IMPEGNO"; color: "#a3a3a3"; font.pixelSize: 11; font.letterSpacing: 1 }
        }
        Text { Layout.fillWidth: true; text: "SKYKEEP  ·  " + (view.payload.synced || "sincronizzazione in attesa"); color: "#a3a3a3"; font.pixelSize: 9; elide: Text.ElideRight }
    }
}
