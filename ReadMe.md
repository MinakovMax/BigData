# Проект: Витрина данных для отчетности мастеров

## Описание проекта
Этот проект предназначен для работы с витриной данных `dwh.craftsman_report_datamart`, которая содержит аналитическую информацию по мастерам, их заказам, а также финансовым показателям. Система построена на базе DWH (Data Warehouse) и поддерживает загрузку данных с использованием Docker и Spark.

## Быстрый старт

Если вы хотите запустить проект локально, выполните следующие шаги:

1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/MinakovMax/BigData.git
   ```

2. Перейдите в директорию проекта:
   ```bash
   cd <папка проекта>
   ```

3. Запустите контейнеры с помощью Docker Compose:
   ```bash
   docker-compose up
   ```

4. Загрузите данные в базу данных в таблицы источников. И измените структуру таблиц DWH и Витрины. Подробные инструкции по изменению таблиц находятся ниже.

5. Скопируйте код из файла ETL.ipynb в ноутбук Spark и запустите вычисления для анализа данных, возможно потребуется заменить IP адрес на ваш или localhost. Видео работы отправил в личку в телеге, мой ник https://t.me/MaxMinakov.

## Структура базы данных

### Витрина данных (`dwh.craftsman_report_datamart`)

```sql
CREATE TABLE dwh.craftsman_report_datamart (
    id int8 GENERATED ALWAYS AS IDENTITY NOT NULL,
    craftsman_id int8 NOT NULL,
    craftsman_name varchar NOT NULL,
    craftsman_address varchar NOT NULL,
    craftsman_birthday date NOT NULL,
    craftsman_email varchar NOT NULL,
    craftsman_money numeric(15, 2) NOT NULL,
    platform_money int8 NOT NULL,
    count_order int8 NOT NULL,
    avg_price_order numeric(10, 2) NOT NULL,
    avg_age_customer numeric(3, 1) NOT NULL,
    median_time_order_completed numeric(10, 1) NULL,
    top_product_category varchar NOT NULL,
    count_order_created int8 NOT NULL,
    count_order_in_progress int8 NOT NULL,
    count_order_delivery int8 NOT NULL,
    count_order_done int8 NOT NULL,
    count_order_not_done int8 NOT NULL,
    report_period varchar NOT NULL,
    source_system_code varchar DEFAULT 'S1' NOT NULL,
    CONSTRAINT craftsman_report_datamart_pk PRIMARY KEY (id),
    CONSTRAINT craftsman_report_dm_uq UNIQUE (craftsman_id, source_system_code, report_period)
);
```

Дополнительная таблица для учета времени загрузки данных:

```sql
CREATE TABLE dwh.load_dates_craftsman_report_datamart (
    id int8 GENERATED ALWAYS AS IDENTITY NOT NULL,
    load_dttm timestamp NOT NULL,
    CONSTRAINT load_dates_craftsman_report_datamart_pk PRIMARY KEY (id)
);
```

### Структура DWH (Data Warehouse)

**Таблицы измерений:**

1. `dwh.d_craftsmans` — информация о мастерах.

```sql
CREATE TABLE dwh.d_craftsmans (
    source_system_code varchar NOT NULL,
    craftsman_id int8 NOT NULL,
    craftsman_name varchar NOT NULL,
    craftsman_address varchar NOT NULL,
    craftsman_birthday date NOT NULL,
    craftsman_email varchar NOT NULL,
    load_dttm timestamp NOT NULL,
    CONSTRAINT d_craftsmans_pk PRIMARY KEY (source_system_code, craftsman_id)
);
```

2. `dwh.d_customers` — информация о клиентах.

```sql
CREATE TABLE dwh.d_customers (
    source_system_code varchar NOT NULL,
    customer_id int8 NOT NULL,
    customer_name varchar NULL,
    customer_address varchar NULL,
    customer_birthday date NULL,
    customer_email varchar NOT NULL,
    load_dttm timestamp NOT NULL,
    CONSTRAINT d_customers_pk PRIMARY KEY (source_system_code, customer_id)
);
```

3. `dwh.d_products` — информация о продуктах.

```sql
CREATE TABLE dwh.d_products (
    source_system_code varchar NOT NULL,
    product_id int8 NOT NULL,
    product_name varchar NOT NULL,
    product_description varchar NOT NULL,
    product_type varchar NOT NULL,
    product_price int8 NOT NULL,
    load_dttm timestamp NOT NULL,
    CONSTRAINT d_products_pk PRIMARY KEY (source_system_code, product_id)
);
```

**Таблица фактов:**

1. `dwh.f_orders` — информация о заказах.

```sql
CREATE TABLE dwh.f_orders (
    f_order_pk bigserial NOT NULL,
    source_system_code varchar NOT NULL,
    order_id int8 NOT NULL,
    product_id int8 NOT NULL,
    craftsman_id int8 NOT NULL,
    customer_id int8 NOT NULL,
    order_created_date date NULL,
    order_completion_date date NULL,
    order_status varchar NOT NULL,
    load_dttm timestamp NOT NULL,
    CONSTRAINT f_orders_pk PRIMARY KEY (f_order_pk),
    CONSTRAINT f_orders_uq UNIQUE (source_system_code, order_id)
);
```

## Примечания
- **Видео**: Видео работы кода прислал в Telegram. Мой ник https://t.me/MaxMinakov
- **Обновления схемы**: Структура таблиц базы данных может изменяться в процессе разработки. Следите за последними изменениями в репозитории.