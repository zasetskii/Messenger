#include "variantmaptablemodel.h"
#include <QDebug>

VariantMapTableModel::VariantMapTableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
}

VariantMapTableModel::~VariantMapTableModel()
{
}

void VariantMapTableModel::registerColumn(AbstractColumn *column)
{
    m_columns.append(column);
}

void VariantMapTableModel::addRow(QVariantMap row_data)
{
    beginInsertRows(QModelIndex(), m_data_hash.count(), m_data_hash.count());
    int id = row_data.value("id").toInt();
    m_data_hash.insert(id, row_data);//вставляем новую строку в модель
    m_id_by_row.append(id);
    endInsertRows();
}

void VariantMapTableModel::deleteRow(const int id)
{
    int remove_row = rowById(id);
    beginRemoveRows(QModelIndex(), remove_row, remove_row);
    m_data_hash.remove(id);
    m_id_by_row.remove(remove_row);
    endRemoveRows();
}

void VariantMapTableModel::clearHash()
{
    beginResetModel();
    m_data_hash.clear();
    m_id_by_row.clear();
    endResetModel();
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

int VariantMapTableModel::rowById(const int id) const
{
    for(int i = 0; i < m_id_by_row.count(); ++i)
        if (m_id_by_row.at(i) == id)
            return i;
}

int VariantMapTableModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_columns.count();
}

int VariantMapTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_data_hash.count();
}

QVariant VariantMapTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();
    //qDebug() << "Row: " << index.row() << ", Column: " << index.column() << "Role: " << role;
    int id = m_id_by_row.at(index.row());
    QVariantMap row_data = m_data_hash.value(id);
    const int column_number = role - Qt::UserRole;
    return m_columns.at(column_number)->colData(row_data, Qt::DisplayRole);
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


SimpleColumn::SimpleColumn(QString name) : AbstractColumn(name)
{

}

QVariant SimpleColumn::colData(const QVariantMap &row_data, int role)
{
    if (role != Qt::DisplayRole)
        return QVariant();
    return row_data.value(this->name());
}



AbstractColumn::AbstractColumn(QString name) : m_name(name)
{

}


