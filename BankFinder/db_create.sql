/*
 Branch {
     _id,  name, phone_number: String
     hours: [String]
     notes: [String]
     address: {
         street_number, street_name, city, state, zip: String
     }
     geocode: { lat, lng }
 }
 */

DROP TABLE IF EXISTS _branches;

CREATE TABLE IF NOT EXISTS _branches (
    id INTEGER PRIMARY KEY,
    _id TEXT,
    name TEXT,
    phone_number TEXT,
    hours JSON,
    notes JSON,
    address JSON,
    geocode JSON
);

DROP VIEW IF EXISTS branches;

CREATE VIEW IF NOT EXISTS branches AS
    SELECT rowid as rowid, *,
        printf('%s %s',
           json_extract(address, '$.street_number'),
           json_extract(address, '$.street_name'))
        as street_full,
        json_extract(geocode, '$.lat') as lat,
        json_extract(geocode, '$.lng') as lon

    FROM _branches
;

DROP TABLE IF EXISTS _atms;

    CREATE TABLE IF NOT EXISTS _atms (
        id INTEGER PRIMARY KEY,
        _id TEXT,
        name TEXT,
        geocode JSON,
        accessibility BOOL,
        hours JSON,
        address JSON,
        language_list JSON,
        amount_left INTEGER
    );

--- Adaptor Views

DROP VIEW IF EXISTS atms;

     CREATE VIEW IF NOT EXISTS atms AS
         SELECT  rowid as rowid, id,
                 name,
                 address,
                 printf('%s %s',
                    json_extract(address, '$.street_number'),
                    json_extract(address, '$.street_name'))
                 as street_full,
                 json_extract(geocode, '$.lat') as lat,
                 json_extract(geocode, '$.lng') as lon

         FROM _atms;

---
--- Map Annotations

DROP VIEW IF EXISTS locations;

    CREATE VIEW IF NOT EXISTS locations AS
        SELECT  rowid as rowid, id,
                name as title,
                street_full as subtitle,
                lat, lon
        FROM atms
        UNION
        SELECT  rowid as rowid, id,
                name as title,
                street_full as subtitle,
                lat, lon
        FROM branches

    ;
--        WHERE title like (select '%' ||
--            (select value from app where key = "search") || '%');

---

---
--- Accounts
DROP TABLE IF EXISTS accounts;

CREATE TABLE IF NOT EXISTS accounts (
    id INTEGER PRIMARY KEY,
    _id TEXT,
    balance INTEGER,
    customer_id TEXT,
    account_number TEXT,
    nickname TEXT,
    rewards TEXT,
    type TEXT
);

/*

   "_id": "string",
   "last_name": "string",
   "first_name": "string",
   "account_ids": [
     "string"
   ],
   "address": {
     "street_name": "string",
     "zip": "string",
     "state": "string",
     "city": "string",
     "street_number": "string"
   }
 }
 */
---
--- Customers
DROP TABLE IF EXISTS _customers;

CREATE TABLE IF NOT EXISTS _customers (
    id INTEGER PRIMARY KEY,
    _id TEXT,
    last_name TEXT,
    first_name TEXT,
    customer_ids JSON TEXT,
    address JSON TEXT
);

DROP VIEW IF EXISTS customers;

CREATE VIEW IF NOT EXISTS customers AS
    SELECT  rowid as rowid, *,
            first_name || ' ' || last_name as full_name,
            json_extract(address, '$.street_number') || ' '
            || json_extract(address, '$.street_name') as street,
            json_extract(address, '$.city') || ', '
            || json_extract(address, '$.state') as city_state

    FROM _customers
;
