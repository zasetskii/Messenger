#include "tcpclient.h"

TCPClient::TCPClient(const QString& connecting_host, int port_num, QObject *parent)
    : QObject(parent), m_cur_user(QString(""))
{
    m_tcp_socket = new QTcpSocket(this);
    m_tcp_socket->connectToHost(connecting_host, port_num);
    connect(m_tcp_socket, &QTcpSocket::connected, this, &TCPClient::onConnected);
    connect(m_tcp_socket, &QTcpSocket::readyRead, this, &TCPClient::slotReadServer);
    connect(m_tcp_socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(slotError(QAbstractSocket::SocketError)));

    m_message_model = new VariantMapIdTableModel;
    //Инициализируем табличную модель
    m_message_model->registerColumn(new Column("id"));
    m_message_model->registerColumn(new Column("text"));
    m_message_model->registerColumn(new Column("time"));
    m_message_model->registerColumn(new Column("sender"));
    m_message_model->registerColumn(new Column("receiver"));
    m_message_model->registerColumn(new Column("date"));

    m_friends_model = new FriendsTableModel;
    //Инициализируем модель друзей
    m_friends_model->registerColumn(new Column("text"));
    m_friends_model->registerColumn(new Column("time"));
    m_friends_model->registerColumn(new Column("sender"));
    m_friends_model->registerColumn(new Column("friend_name"));
    m_friends_model->registerColumn(new Column("avatar"));
    m_friends_model->registerColumn(new Column("hasAvatar"));

    //Инициализируем модель пользователей
    m_users_model = new QStringListModel;

}

//Чтение данных с сервера (вызывается каждый раз, когда новые данные доступны для чтения)
void TCPClient::slotReadServer()
{
    QDataStream in(m_tcp_socket);
    while(1)
    {
        if (m_next_block_size == 0)
        {
            if (m_tcp_socket->bytesAvailable() < sizeof(m_next_block_size)) //если размер следующего блока ещё не подгрузился
                break;
            in >> m_next_block_size;
        }
        if (m_tcp_socket->bytesAvailable() < m_next_block_size) //если подгрузились ещё не все данные блока
        {
            break;
        }
        if (m_command == NO_COMMAND_CLIENT)
        {
            in >> m_command;
            m_next_block_size = 0;
            continue;
        }
        else if (m_command == MESSAGE)
        {
            QVariantMap record;
            in >> record;
            m_message_model->addRow(record);
            emit messageModelChanged();
        }
        else if (m_command == USERS)
        {
            QStringList users;
            in >> users;
            m_users_model->setStringList(users);
            m_cur_user = users[0];
            sendFriendsRequest();
            sendAvatarRequest();
            emit usersModelChanged();
            emit curUserChanged();
        }
        else if (m_command == FRIEND)
        {
            QVariantMap record;
            in >> record;
            m_friends_model->addRow(record);
            emit friendsModelChanged();
        }
        else if (m_command == AVATAR)
        {
            in >> m_avatar;
            if (m_avatar.size() == QSize(0, 0))
                emit avatarMissing();
            else
                emit avatarChanged();
        }
        else if (m_command == FRIEND_AVATAR)
        {
            in >> m_friend_avatar;
            if (m_friend_avatar.size() == QSize(0, 0))
                emit friendAvatarMissing();
            else
                emit friendAvatarChanged();
        }
        m_command = NO_COMMAND_CLIENT;
        m_next_block_size = 0;
    }
}

void TCPClient::slotError(QAbstractSocket::SocketError error) const
{
    QString str_error = "Error: " + (error == QAbstractSocket::HostNotFoundError ? "Host not found" :
                                     error == QAbstractSocket::RemoteHostClosedError ? "Remote host closed" :
                                     error == QAbstractSocket::ConnectionRefusedError ? "Connection was refused" :
                                     QString(m_tcp_socket->errorString()));
    qDebug() << str_error;
}

void TCPClient::onConnected() const
{
    qDebug() << "Connected to server";
    sendUsersRequest();
}

void TCPClient::addMessageLocally(const QVariantMap &message)
{
    m_message_model->addRow(message);
    emit messageModelChanged();
}

void TCPClient::clearMessageModel()
{
    m_message_model->clearHash();
}

void TCPClient::clearFriendsModel()
{
    m_friends_model->clear();
}

void TCPClient::onUserChosen(const QString &username)
{
    m_cur_user = username;
    m_friends_model->clear();
    sendFriendsRequest();
    sendAvatarRequest();
    emit curUserChanged();
}

void TCPClient::onNewUser(const QString &username)
{
    //Проверяем, свободно ли имя
    if (m_users_model->stringList().contains(username))
    {
        emit userAlreadyExists();
        qDebug() << "User already exists";
        return;
    }
    //Добавляем пользователя локально
    m_users_model->insertRow(m_users_model->rowCount());
    QModelIndex insert_index = m_users_model->index(m_users_model->rowCount() - 1, 0);
    m_users_model->setData(insert_index, username);
    //Отправляем имя на сервер в БД
    sendNewUser(username);
    qDebug() << "User " << username << " created!";
    emit usersModelChanged();
}

void TCPClient::onNewFriend(const QString &username, const QString &new_friend)
{
    //Проверяем, существует ли друг
    if (!m_users_model->stringList().contains(new_friend))
    {
        emit userDoesNotExist();
        qDebug() << "User doesn't exist";
        return;
    }
    //Проверяем, есть ли уже в друзьях
    if (m_friends_model->containsFriend("friend_name", new_friend))
    {
        emit alreadyFriend();
        qDebug() << "User already a friend";
        return;
    }

    //Отправляем информацию на сервер
    sendNewFriend(username, new_friend);
    //Сбрасываем текущий список друзей
    m_friends_model->clear();
    //Запрашиваем новые данные друзей
    sendFriendsRequest();
}

void TCPClient::sendStringList(const QStringList& string_list) const
{
    for (const QString& str : string_list)
    {
        QByteArray sending_data;
        QDataStream out(&sending_data, QIODevice::WriteOnly);
        out << 0 << str;
        out.device()->seek(0);
        out << sending_data.size() - sizeof(int);
        m_tcp_socket->write(sending_data);
    }
}

void TCPClient::sendCommand(const ServerCommand &command) const
{
    QByteArray sending_data;
    QDataStream out(&sending_data, QIODevice::WriteOnly);
    out << 0 << command;
    out.device()->seek(0);
    out << sending_data.size() - sizeof(int);
    m_tcp_socket->write(sending_data);
}

void TCPClient::sendMessage(const QVariantMap& message) const
{
    sendCommand(MESSAGE_WRITE);

    QByteArray block_message;
    QDataStream out_message(&block_message, QIODevice::WriteOnly);
    out_message << 0 << message;
    out_message.device()->seek(0);
    out_message << block_message.size() - sizeof(int);
    m_tcp_socket->write(block_message);
}

void TCPClient::sendAvatar(const QString &username, QString image_url)
{
    image_url.remove("file:///");
    qDebug() << m_avatar.load(image_url);
    emit avatarChanged();

    sendCommand(AVATAR_UPDATE);
    sendStringList({username});
    QByteArray block_image;
    QDataStream out_image(&block_image, QIODevice::WriteOnly);
    out_image << 0 << m_avatar;
    out_image.device()->seek(0);
    out_image << block_image.size() - sizeof(int);
    m_tcp_socket->write(block_image);
}

void TCPClient::sendMessageRequest(const QString& sender, const QString& receiver) const
{
    sendCommand(MESSAGES_READ);
    sendStringList({sender, receiver});
}

void TCPClient::sendUsersRequest() const
{
    sendCommand(USERS_GET);
}

void TCPClient::sendFriendsRequest() const
{
    sendCommand(FRIENDS_GET);
    sendStringList({m_cur_user});
}

void TCPClient::sendAvatarRequest() const
{
    sendCommand(AVATAR_GET);
    sendStringList({m_cur_user});
}

void TCPClient::sendFriendAvatarRequest(const QString &friend_name) const
{
    sendCommand(FRIEND_AVATAR_GET);
    sendStringList({friend_name});
}

void TCPClient::sendRemoveMessage(const int id) const
{
    sendCommand(MESSAGE_REMOVE);
    QByteArray block_id;
    QDataStream out(&block_id, QIODevice::WriteOnly);
    out << sizeof(id) << id;
    m_tcp_socket->write(block_id);
}

void TCPClient::removeMessageLocally(const int id)
{
    m_message_model->deleteRow(id);
    emit messageModelChanged();
}

void TCPClient::sendNewUser(const QString &username) const
{
    sendCommand(USER_APPEND);
    sendStringList({username});
}

void TCPClient::sendNewFriend(const QString &username, const QString &new_friend) const
{
    sendCommand(FRIEND_APPEND);
    sendStringList({username, new_friend});
}

void TCPClient::setCurUser(const QString &username)
{
    m_cur_user = username;
    emit curUserChanged();
}


VariantMapIdTableModel* TCPClient::getMessageModel() const
{
    return m_message_model;
}

QStringListModel* TCPClient::getUsersModel() const
{
    return m_users_model;
}

FriendsTableModel* TCPClient::getFriendsModel() const
{
    return m_friends_model;
}

QString TCPClient::getCurUser() const
{
    return m_cur_user;
}

QImage TCPClient::getAvatar() const
{
    return m_avatar;
}

QImage TCPClient::getFriendAvatar() const
{
    return m_friend_avatar;
}

TCPClient::~TCPClient()
{
}
