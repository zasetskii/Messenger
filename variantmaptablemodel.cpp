#include "variantmaptablemodel.h"
#include <QDebug>

VariantMapTableModel::VariantMapTableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

VariantMapTableModel::~VariantMapTableModel()
{
}

void VariantMapTableModel::registerColumn(Column *column)
{
    m_columns.append(column);
}

int VariantMapTableModel::colByName(QString name) const
{
    for(int col = 0; col < m_columns.count(); ++col)
    {
        if (nameByCol(col) == name)
            return col;
    }
    return -1;
}

QString VariantMapTableModel::nameByCol(int col) const
{
    return m_columns.at(col)->name();
}

int VariantMapTableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_columns.count();
}

QHash<int, QByteArray> VariantMapTableModel::roleNames() const
{
    QHash<int, QByteArray> roles = QAbstractTableModel::roleNames();
    for (int col = 0; col < m_columns.count(); col++)
    {
        roles.insert(Qt::UserRole + col, m_columns[col]->name().toUtf8()); //создаём новые роли для наших колонок
    }
    return roles;
}


Column::Column(QString name) : m_name(name)
{

}

QVariant Column::colData(const QVariantMap &row_data, int role)
{
    if (role != Qt::DisplayRole)
        return QVariant();
    return row_data.value(this->name());
}






VariantMapIdTableModel::VariantMapIdTableModel(QObject *parent): VariantMapTableModel(parent)
{
}

int VariantMapIdTableModel::rowById(const int id) const
{
    for(int i = 0; i < m_id_by_row.count(); ++i)
        if (m_id_by_row.at(i) == id)
            return i;
    return -1;
}

void VariantMapIdTableModel::addRow(const QVariantMap& row_data)
{
    beginInsertRows(QModelIndex(), m_data_hash.count(), m_data_hash.count());
    int id = row_data.value("id").toInt();
    m_data_hash.insert(id, row_data);//вставляем новую строку в модель
    m_id_by_row.append(id);
    endInsertRows();
}

void VariantMapIdTableModel::deleteRow(const int id)
{
    int remove_row = rowById(id);
    beginRemoveRows(QModelIndex(), remove_row, remove_row);
    m_data_hash.remove(id);
    m_id_by_row.remove(remove_row);
    endRemoveRows();
}

void VariantMapIdTableModel::clearHash()
{
    beginResetModel();
    m_data_hash.clear();
    m_id_by_row.clear();
    endResetModel();
}

int VariantMapIdTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data_hash.count();
}

QVariant VariantMapIdTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    //qDebug() << "Row: " << index.row() << ", Column: " << index.column() << "Role: " << role;
    int id = m_id_by_row.at(index.row());
    QVariantMap row_data = m_data_hash.value(id);
    const int column_number = role - Qt::UserRole;
    return m_columns.at(column_number)->colData(row_data, Qt::DisplayRole);
}







FriendsTableModel::FriendsTableModel(QObject *parent): VariantMapTableModel(parent)
{
}

void FriendsTableModel::addRow(const QVariantMap &row_data)
{
    beginInsertRows(QModelIndex(), m_data.count(), m_data.count());
    m_data.append(row_data);
    endInsertRows();
}

void FriendsTableModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}

bool FriendsTableModel::containsFriend(const QString& key_name, const QString& friend_name) const
{
    for(int i = 0; i < m_data.count(); ++i)
        if(m_data[i].value(key_name) == friend_name)
            return true;
    return false;
}

QVariant FriendsTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    QVariantMap row_data = m_data.at(index.row());
    const int column_number = role - Qt::UserRole;
    return m_columns.at(column_number)->colData(row_data, Qt::DisplayRole);
}

int FriendsTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data.count();
}


