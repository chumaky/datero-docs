// mongo database intialization script
let objs = [
  {id: 1, user_id: 1, amount: 105},
  {id: 2, user_id: 2, amount: 5433.56},
  {id: 3, user_id: 3, amount: 87754}
];

db.orders.insertMany(objs);
