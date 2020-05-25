
let downgrade_1_to_0 = [
  {|drop table accounts|};
  {|drop table sessions|};
]

let upgrade_0_to_1 dbh version =
  EzPG.upgrade ~dbh ~version ~downgrade:downgrade_1_to_0 [
    {|create table accounts(
      id serial unique,
      username varchar primary key,
      pwhash varchar not null)|};
    {|create table sessions(
      user_id int not null,
      token varchar not null,
      tsp timestamp not null)|};
  ]

let upgrades = [
  0, upgrade_0_to_1
]

let downgrades = [
  1, downgrade_1_to_0
]
