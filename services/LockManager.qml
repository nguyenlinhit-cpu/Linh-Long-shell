pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pam

Singleton {
    id: root

    // Lock Screen Active State
    property bool isLocked: false
    property bool authenticating: false
    property bool authFailed: false
    property string authErrorMessage: ""
    property string currentPassword: ""

    // Native Linux PAM Authentication Service
    PamContext {
        id: pam

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentPassword);
            }
        }

        onCompleted: result => {
            root.authenticating = false;
            if (result === PamResult.Success) {
                root.authFailed = false;
                root.currentPassword = "";
                root.unlock();
            } else {
                root.authFailed = true;
                root.currentPassword = "";
                root.authErrorMessage = "Incorrect password, try again";
            }
        }

        onError: error => {
            root.authenticating = false;
            root.authFailed = true;
            root.currentPassword = "";
            root.authErrorMessage = "Authentication error occurred";
        }
    }

    function lock() {
        root.authFailed = false;
        root.authErrorMessage = "";
        root.currentPassword = "";
        root.isLocked = true;
    }

    function unlock() {
        root.isLocked = false;
    }

    function submitPassword(password) {
        if (root.authenticating) return;
        root.authenticating = true;
        root.authFailed = false;
        root.currentPassword = password;
        pam.start();
    }
}
