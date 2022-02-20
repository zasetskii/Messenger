#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStringListModel>
#include <QQuickStyle>
#include "tcpclient.h"
#include "imageitem.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QGuiApplication::setApplicationName("Messenger");
    QGuiApplication::setOrganizationName("QtProject");

    qmlRegisterType<ImageItem>("myextension", 1, 0, "ImageItem");

    QQuickStyle::setStyle("Universal");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    //TCPClient client("192.168.0.3", 2323);
    //TCPClient client("192.168.0.5", 2323);
    TCPClient client("localhost", 2323);
    engine.rootContext()->setContextProperty("client", &client);

    QStringList users;
    users << "Vlad" << "Sergey" << "Alex";

    engine.load(url);

    return app.exec();
}
