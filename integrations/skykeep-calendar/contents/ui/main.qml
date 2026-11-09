pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    property var payload: ({})
    property string problem: ""
    property bool busy: false
    property int offset: 0
    readonly property string reader: decodeURIComponent(String(Qt.resolvedUrl("../code/calendar_reader.py"))).replace(/^file:\/\//, "")
    function refresh() {
        if (busy) return;
        busy = true;
        process.connectSource("python3 '" + reader.replace(/'/g, "'\\''") + "' --month-offset " + offset);
    }
    Plasma5Support.DataSource {
        id: process
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
            root.busy = false;
            try {
                const result = JSON.parse(data.stdout);
                if (data["exit code"] !== 0 || result.error) throw new Error(result.error || "Lettura non riuscita");
                root.payload = result;
                root.problem = "";
            } catch (error) { root.problem = String(error.message || error); }
        }
    }
    Timer { interval: 120000; running: root.visible; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
    fullRepresentation: CalendarView {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 410
        Layout.preferredWidth: 360
        Layout.preferredHeight: 520
        payload: root.payload
        problem: root.problem
        busy: root.busy
        accent: Kirigami.Theme.highlightColor
        onMoveMonth: function(delta) { if (!root.busy) { root.offset += delta; root.refresh(); } }
        onTodayRequested: { if (!root.busy) { root.offset = 0; root.refresh(); } }
        onRefreshRequested: root.refresh()
    }
}
