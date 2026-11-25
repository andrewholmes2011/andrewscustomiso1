// Andrew OS Plasma 6 first-run desktop layout.
// The centered panel acts as the Chromebook-style shelf. The right-aligned
// panel holds the status area (network, sound, Bluetooth, clock and power).
var desktopsList = desktops();
for (var i = 0; i < desktopsList.length; i++) {
    var desktop = desktopsList[i];
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "/usr/share/backgrounds/andrew-os/wallpaper.svg");
}

var oldPanels = panels();
for (var j = oldPanels.length - 1; j >= 0; j--) {
    oldPanels[j].remove();
}

var shelf = new Panel;
shelf.location = "bottom";
shelf.height = 58;
shelf.lengthMode = "fit";
shelf.alignment = "center";
shelf.hiding = "none";

var launcher = "org.kde.plasma.kickoff";
if (knownWidgetTypes.indexOf("org.kde.plasma.kickerdash") !== -1) {
    launcher = "org.kde.plasma.kickerdash";
}
shelf.addWidget(launcher);
shelf.addWidget("org.kde.plasma.icontasks");

var statusPanel = new Panel;
statusPanel.location = "bottom";
statusPanel.height = 48;
statusPanel.lengthMode = "fit";
statusPanel.alignment = "right";
statusPanel.offset = 12;
statusPanel.hiding = "none";
statusPanel.addWidget("org.kde.plasma.systemtray");
statusPanel.addWidget("org.kde.plasma.digitalclock");
