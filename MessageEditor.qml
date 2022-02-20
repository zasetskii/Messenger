import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3

Rectangle
{
    id: root
    height: 60
    color: "lightgray"
    property color colorBtnSend
    property color colorBtnSendHovered: "#248566"
    property int marginWidth: 10
    property int sizeText: 11
    property int sizeSubmit: 12
    signal submitMessage(string text)

    RowLayout
    {
        anchors.fill: parent
        anchors.rightMargin: marginWidth
        TextField
        {
            id: editor
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            font.pointSize: sizeText
            selectByMouse: true
            background: Rectangle
            {
                anchors.fill: parent
                color: root.color
            }
            placeholderText: "Напишите сообщение"
            onAccepted:
            {
                if (editor.text.length)
                {
                    submitMessage(editor.text)
                    editor.clear()
                }
            }
        }
        RoundButton
        {
            id: btnSubmit
            text: "\u2713"
            font.pointSize: sizeSubmit
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: 0.8 * root.height
            Layout.preferredWidth: 0.8 * root.height
            background: Rectangle
            {
                id: bgRect
                anchors.fill: parent
                radius: parent.height / 2
                color: colorBtnSend
            }
            onClicked:
            {
                if (editor.text.length)
                {
                    submitMessage(editor.text)
                    editor.clear()
                }
            }
            hoverEnabled: true
            onHoveredChanged: (hovered == true) ? bgRect.color = colorBtnSendHovered : bgRect.color = colorBtnSend
        }
    }
}
