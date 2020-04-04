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

DROP TABLE IF EXISTS branches;

CREATE TABLE IF NOT EXISTS branches (
    id INTEGER PRIMARY KEY,
    _id TEXT,
    name TEXT,
    phone_number TEXT,
    hours JSON,
    notes JSON,
    address JSON,
    geocode JSON
);


DROP TABLE IF EXISTS atms;

    CREATE TABLE IF NOT EXISTS atms (
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

DROP VIEW IF EXISTS atms_x;

     CREATE VIEW IF NOT EXISTS atms_x AS
         SELECT  rowid as rowid, id,
                 name,
                 address,
                 printf('%s %s',
                    json_extract(address, '$.street_number'),
                    json_extract(address, '$.street_name'))
                 as street_full,
                 json_extract(geocode, '$.lat') as lat,
                 json_extract(geocode, '$.lng') as lon

         FROM atms;

---
--- Map Annotations

DROP VIEW IF EXISTS atm_locs;

    CREATE VIEW IF NOT EXISTS atm_locs AS
        SELECT  rowid as rowid, id,
                name as title,
                json_extract(address, '$.street_number') || ' '
                || json_extract(address, '$.street_name') as subtitle,
                json_extract(geocode, '$.lat') as lat,
                json_extract(geocode, '$.lng') as lon

        FROM atms
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
