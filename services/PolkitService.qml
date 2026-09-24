pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    property alias agent: polkitAgent
    property alias active: polkitAgent.isActive
    property alias flow: polkitAgent.flow
    property bool interactionAvailable: false
    property string errorMessage: ""

    property string messageText: {
        if (!root.flow) return "";
        let msg = root.flow.message || "";
        return msg.endsWith(".") ? msg.slice(0, -1) : msg;
    }

    property string promptText: {
        if (!root.flow) return "Password";
        let p = root.flow.inputPrompt || "";
        p = p.trim();
        if (p.endsWith(":")) p = p.slice(0, -1);
        return p || "Password";
    }

    function cancel() {
        if (root.flow) {
            root.flow.cancelAuthenticationRequest();
        }
        root.interactionAvailable = false;
        root.errorMessage = "";
    }

    function submit(pwd) {
        if (root.flow) {
            root.flow.submit(pwd);
        }
        root.interactionAvailable = false;
    }

    Connections {
        target: root.flow
        function onAuthenticationFailed() {
            root.interactionAvailable = true;
            root.errorMessage = "Authentication failed. Please try again.";
        }
        function onAuthenticationSucceeded() {
            root.interactionAvailable = false;
            root.errorMessage = "";
        }
        function onAuthenticationRequestCancelled() {
            root.interactionAvailable = false;
            root.errorMessage = "";
        }
    }

    PolkitAgent {
        id: polkitAgent
        onAuthenticationRequestStarted: {
            root.interactionAvailable = true;
            root.errorMessage = "";
        }
    }
}
