
``` JSON
// Object Shape
Branch {
    _id,  name, phone_number: String
    hours: [String]
    notes: [String]
    address: {
        street_number, street_name, city, state, zip: String
    }
    geocode: { lat, lng }
}
```


``` JSON
// Exemplar JSON Data
{
  "_id": "56c66be5a73e4927415071a4",
  "name": "LEE HIGHWAY/GEORGE MASON",
  "phone_number": "(703) 237-0146",
  "hours": [
    "Sun",
    "Mon 9 AM - 5 PM",
    "Tue 9 AM - 5 PM",
    "Wed 9 AM - 5 PM",
    "Thu 9 AM - 5 PM",
    "Fri 9 AM - 6 PM",
    "Sat 9 AM - 1 PM"
  ],
  "notes": [
    "Safe Deposit Box",
    "Branch Drive-Up",
    "ATM Available",
    "Open on Saturday"
  ],
  "address": {
    "street_number": "5222",
    "state": "VA",
    "street_name": "Lee Highway",
    "zip": "22207",
    "city": "Arlington"
  },
  "geocode": {
    "lng": -77.1333157,
    "lat": 38.8960952
  }
},
```

