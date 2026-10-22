import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Ui
import qs.Commons

// Shows the tiling mode of the workspace active on this bar's monitor, as written by
// tile-mode (https://github.com/CavemanKiwi/hypr-tile-mode).
BarWidget {
  id: root
  moduleName: "caveman.tile-mode"

  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/tile-mode"
  readonly property var monitor: root.QsWindow.window && root.QsWindow.window.screen ? Hyprland.monitorFor(root.QsWindow.window.screen) : null
  readonly property int workspaceId: root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : 0
  property string mode: "1"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  visible: workspaceId > 0

  onWorkspaceIdChanged: refresh()
  Component.onCompleted: refresh()

  function refresh() {
    if (root.workspaceId <= 0) return
    probe.command = ["cat", root.stateDir + "/ws-" + root.workspaceId]
    probe.output = ""
    probe.running = false
    probe.running = true
  }

  // Read the state file with a process: FileView can't watch a file that doesn't
  // exist yet (new workspaces), and its watch can go quiet after quick rewrites.
  Process {
    id: probe
    property string output: ""
    stdout: SplitParser { onRead: function(line) { probe.output += line } }
    onExited: {
      var value = probe.output.trim()
      root.mode = /^[1234]$/.test(value) ? value : "1"
    }
  }

  // tile-mode always runs `hyprctl reload` after writing the state file.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "configreloaded" || event.name === "workspacev2" || event.name === "focusedmonv2")
        root.refresh()
    }
  }

  // Backup trigger: watch the state directory itself.
  FileView {
    path: root.stateDir
    watchChanges: true
    printErrors: false
    onFileChanged: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "T-" + root.mode
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: ({ "1": "Tiling: default", "2": "Tiling: 2/3 | 1/3", "3": "Tiling: 1/3 | 1/3 | 1/3", "4": "Tiling: 1/5 | 3/5 | 1/5" })[root.mode] + " (SUPER+ALT+1/2/3/4)"
    onPressed: function() {
      if (root.bar && root.workspaceId > 0) root.bar.run("tile-mode next --workspace " + root.workspaceId)
    }
  }
}
