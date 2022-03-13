# Messenger

## Краткое описание
Данное приложение – подобие клиента мессенджера, работающее в связке с приложением-сервером. <br>
Подключение осуществляется по локальной сети, все данные подгружаются с сервера. Приложение сервер работает с SQL таблицами, пересылая данные по сети в ответ на запросы приложения-клиента. Взаимодействие между сервером и клиентом осуществляется посредством набора команд, заданных перечислением `enum`.

## Хранение данных
Используются 3 SQL таблицы: message (хранение сообщений), user (хранение информации о пользователях), friends (хранение информации о друзьях).<br>
Таблица: message<br>
`message_id (INT PRIMARY KEY) | text (VARCHAR(200)) | time (VARCHAR(5)) | sender (VARCHAR(30)) | receiver (VARCHAR(30)) | date (VARCHAR(200))`<br>

Таблица: user<br>
`user_id (INT PRIMARY KEY) | name (VARCHAR(30)) | image_url (VARCHAR(150))`

Таблица: friends<br>
`friends_id (INT PRIMARY KEY) | user_name (VARCHAR(30)) | friend_name (VARCHAR(30))`

## Внешний вид
Приложение состоит из двух экранов:

### Экран со списком друзей
Файлы: [FriendsPage.qml](https://github.com/zasetskii/Messenger/blob/main/FriendsPage.qml), [PageHeader.qml](https://github.com/zasetskii/Messenger/blob/main/PageHeader.qml) – нижняя часть страницы

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/1.png">

### Экран с диалогом
Файлы: [MessengerPage.qml](https://github.com/zasetskii/Messenger/blob/main/MessengerPage.qml), [PageHeader.qml](https://github.com/zasetskii/Messenger/blob/main/PageHeader.qml), [MessageEditor.qml](https://github.com/zasetskii/Messenger/blob/main/MessageEditor.qml) – нижняя часть страницы, [MessageItem.qml](https://github.com/zasetskii/Messenger/blob/main/MessageItem.qml) – делегат для задания вида одного сообщения

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/2.png">

#### В меню-шторке можно сменить пользователя или создать нового.
<b>Компоненты</b>: Drawer

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/3.png">

#### Нажатие на кнопку «+» вызывает диалог добавления в друзья пользователя.
<b>Компоненты</b>: Dialog и ComboBox

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/4.png">

#### Аватар можно загрузить из меню настроек.
<b>Компоненты</b>: ToolButton, Menu, MenuItem, FileDialog

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/5.png">

#### В окне диалога есть возможность скопировать или удалить сообщение.
<b>Компоненты</b>: MouseArea, Menu, MenuItem

<img src="https://github.com/zasetskii/Messenger/blob/main/readme_images/6.png">

## Описание файлов/классов
[`commands.h`](https://github.com/zasetskii/Messenger/blob/main/commands.h) – содержит `enum` команд, используемых для взаимодействия приложений клиента и сервера<br>
[`ImageItem`](https://github.com/zasetskii/Messenger/blob/main/imageitem.h) – класс, используемый для отрисовки в QML присланных сервером объектов `QImage`<br>
[`VariantMapTableModel` и производные классы](https://github.com/zasetskii/Messenger/blob/main/variantmaptablemodel.h) – классы моделей данных. Работают с данными типа `QVariantMap`. Используются в качестве моделей для представлений в QML.<br>
[`TCPClient`](https://github.com/zasetskii/Messenger/blob/main/tcpclient.h) – класс клиента. Принимает и отправляет команды серверу, взаимодействует с QML-стороной приложения: предоставляет данные, обрабатывает сигналы.<br>

## Скачать
[Клиент мессенджера](https://disk.yandex.ru/d/2gBawk91K8sngw)
