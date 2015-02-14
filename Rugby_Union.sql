create table rugby_union
(
  union_id int primary key,
  union_name varchar(100) not null,
  union_country varchar(100) not null,
  yearFounded date not null,
  numberOfMembers int not null,
  constraint check_numOfMems check (numberOfMembers > 0),
  constraint check_unionID check (union_id > 0 )
);
/*--------------------------------------------------------------------*/
create table leagueTable
(
  teamTable_id int not null,
  wins int not null,
  loses int not null,
  draws int not null,
  gamesplayed int not null,
  points int not null,
  constraint check_points check(points >= 0),
  constraint check_games_played check (gamesplayed >= 0),
  constraint check_winsLosesDraws check (wins >= 0 and loses >= 0 and draws >= 0),
  constraint check_id check (teamTable_id > 0)
);
/*--------------------------------------------------------------------*/
create table rugby_team
(
  team_id int primary key not null,
  team_name varchar(20) not null,
  unionID int not null,
  foreign key (unionID) references rugby_union(union_id),
  headCoachID int not null,
  constraint check_teamID check (team_id > 0 ),
  constraint check_headCoachID check (headCoachID > 0 )
);
/*--------------------------------------------------------------------*/
create table rugby_coach
(
  coach_id int primary key not null,
  firstnameC varchar(20) not null,
  surnameC varchar(20) not null,
  teamID int not null,
  trophiesWon int not null,
  gamesPlayed int not null,
  constraint check_coachID check (coach_id > 0 ),
  constraint check_trophiesWon check (trophiesWon >= 0 )
);
/*--------------------------------------------------------------------*/
create table rugby_player
(
  player_id int primary key not null,
  firstname varchar(20) not null,
  surname varchar(20) not null,
  teamID int not null,
  foreign key (teamID) references rugby_team(team_id),
  isCaptain int not null,
  gamesPlayedID int not null,
  constraint check_isCaptain check(isCaptain = 0 or isCaptain = 1),
  constraint check_playerID check (player_id > 0 )
);
/*--------------------------------------------------------------------*/
create table fixture_list
(
  fixtureID int primary key,
  winner int not null,
  loser int not null,
  draw int not null,
  constraint check_winner check (winner >= 0 ),
  constraint check_loser check (winner >= 0 ),
  constraint check_draw check (draw = 0 or draw = 1)
);
/*--------------------------------------------------------------------*/
create table rugby_supporter
(
  supporter_id int primary key not null,
  firstName varchar(20) not null,
  surname varchar(20) not null,
  favouritePlayer int references rugby_player(player_id) not null,
  favouriteTeam int references rugby_team(team_id) not null,
  happiness int not null,
  constraint check_happiness check(happiness > 0 and happiness < 100),
  constraint check_supporterID check (supporter_id > 0 )
);

create table participate
(
  fixtureID int not null,
  team int not null,
  fixtureDate date not null,
  primary key(fixtureId,team,fixtureDate)
);
/*--------------------------------------------------------------------*/
/*Triggers*/
/*
  Adds a team to the league table when a new team is added to the system
*/
create or replace trigger addTeamToTable after insert on rugby_team
  for each row
    declare
    begin
      insert into leagueTable values(:new.team_id,0,0,0,0,0);
    end addTeamToTable;
/
/*
  Trigger populate the league table with results
*/
create or replace trigger updateLeagueTableValues
  after insert on fixture_list
    for each row
    declare
      gamesCount int;
    begin
      update leagueTable
        set wins = wins + 1,
            points = (wins * 4) + (draws * 2)
        where teamTable_id = :new.winner and :new.draw = 0;
      update leagueTable
        set loses = loses + 1,
            points = (wins * 4) + (draws * 2)
        where teamTable_id = :new.loser and :new.draw = 0;
      update leagueTable
        set draws = draws + 1,
            points = (wins * 4) + (draws * 2)
        where teamTable_id = :new.loser and :new.draw = 1;
      update leagueTable
        set draws = draws + 1,
            points = (wins * 4) + (draws * 2)
        where teamTable_id = :new.winner and :new.draw = 1;
      update leagueTable
        set gamesplayed = gamesplayed + 1
        where teamTable_id = :new.loser;
      update leagueTable
        set gamesplayed = gamesplayed + 1
        where teamTable_id = :new.winner;
    end updateLeagueTableValues;
/

create or replace trigger updateGamesPlayed after insert on participate
  for each row
    begin
      update leagueTable
        set gamesplayed = wins + loses + draws
        where leagueTable.teamtable_id = :new.team;
    end updateGamesPlayed;
/

/*--------------------------------------------------------------------*/
/*Inserts*/
-- Add the rugby Unions
insert into rugby_union
  values(1,'Irish Rugby Football Union','Ireland',
                            (TO_DATE('01/01/1879','DD/MM/YYYY')),4);
insert into rugby_union
  values(2,'Welsh Rugby Union','Wales',
                            (TO_DATE('12/03/1881','DD/MM/YYYY')),8);
insert into rugby_union
  values(3,'Scottish Rugby Union','Scotland',
                            (TO_DATE('19/04/1881','DD/MM/YYYY')),8);
insert into rugby_union
  values(4,'English Rugby Union','England',
                            (TO_DATE('21/06/1881','DD/MM/YYYY')),20);
insert into rugby_union
  values(5,'Austrailian Rugby Union','Austrailia',
                            (TO_DATE('10/03/1880','DD/MM/YYYY')),20);
insert into rugby_union
  values(6,'New Zealand Rugby Union','New Zealand',
                            (TO_DATE('25/03/1872','DD/MM/YYYY')),8);
insert into rugby_union
  values(7,'French Rugby Federation','France',
                            (TO_DATE('05/05/1872','DD/MM/YYYY')),8);
/*--------------------------------------------------------------------*/
  -- Add the rugby coaches
insert into rugby_coach
  values(1000,'Matt','O Connor',100,0,9);
insert into rugby_coach
  values(1001,'Anthony','Foley',101,1,9);
insert into rugby_coach
  values(1003,'Pat','Lam',102,0,9);
insert into rugby_coach
  values(1002,'Neil','Doak',103,0,9);
 /*-----------------------------------------------------------------*/
insert into rugby_coach
  values(1004,'John','Jones',200,1,9);
insert into rugby_coach
  values(1005,'Simon','Foley',201,1,9);
insert into rugby_coach
  values(1006,'Glenn','Ethely',202,2,9);
insert into rugby_coach
  values(1007,'Lenny','Scarley',203,3,4);
 /*-----------------------------------------------------------------*/
insert into rugby_coach
  values(1008,'Peter','Evans',300,1,9);
insert into rugby_coach
  values(1009,'Simon','Miller',301,1,9);
insert into rugby_coach
  values(1010,'Paul','Easterby',302,2,9);
insert into rugby_coach
  values(1011,'David','Akyau',303,3,4);
 /*-----------------------------------------------------------------*/
insert into rugby_coach
  values(1012,'John','MacTavish',400,0,9);
insert into rugby_coach
  values(1013,'Willy','O Malley',401,0,9);
insert into rugby_coach
  values(1014,'Oscar','Paul',402,0,9);
insert into rugby_coach
  values(1015,'Gavin','Stevens',403,0,4);
 /*-----------------------------------------------------------------*/
-- Add the rugby teams
insert into rugby_team
  values(100,'Leinster',1,1000);
insert into rugby_team
  values(101,'Munster',1,1001);
insert into rugby_team
  values(102,'Ulster',1,1002);
insert into rugby_team
  values(103,'Connacht',1,1003);
 /*-----------------------------------------------------------------*/
insert into rugby_team
  values(200,'Cardiff',2,1004);
insert into rugby_team
  values(201,'Newport',2,1005);
insert into rugby_team
  values(202,'Swansea',2,1006);
insert into rugby_team
  values(203,'Rams',2,1007);
 /*-----------------------------------------------------------------*/
insert into rugby_team
  values(300,'London Legion',4,1008);
insert into rugby_team
  values(301,'Manchester Mercs',4,1009);
insert into rugby_team
  values(302,'Brighton Beasts',4,1010);
insert into rugby_team
  values(303,'Hull Heroes',4,1011);
 /*-----------------------------------------------------------------*/
insert into rugby_team
  values(400,'Edinburgh Eagles',3,1012);
insert into rugby_team
  values(401,'Glasgow Galloways',3,1013);
insert into rugby_team
  values(402,'Inverness Ivories',3,1014);
insert into rugby_team
  values(403,'Ullapool Underdogs',3,1015);
 /*-----------------------------------------------------------------*/

-- Add the rugby players
insert into rugby_player
  values(101,'Rob','Kearney',100,0,9);
insert into rugby_player
  values(102,'Devin','Toner',100,0,9);
insert into rugby_player
  values(103,'Ian','Madigan',100,0,9);
insert into rugby_player
  values(104,'Brendan','Macken',100,0,9);
insert into rugby_player
  values(105,'Mick','McGrath',100,0,9);
insert into rugby_player
  values(106,'Darragh','Fanning',100,0,9);
insert into rugby_player
  values(107,'Jimmy','Copperth',100,0,9);
insert into rugby_player
  values(108,'Eoin','Reddan',100,0,9);
insert into rugby_player
  values(109,'Isaac','Boss',100,0,9);
insert into rugby_player
  values(110,'Gordon','D Arcy',100,0,9);
insert into rugby_player
  values(111,'Eoin','Reddan',100,0,9);
insert into rugby_player
  values(112,'Micheal','Bent',100,0,9);
insert into rugby_player
  values(113,'Sean','Cronin',100,0,9);
insert into rugby_player
  values(114,'Bryan','Byrne',100,0,9);
insert into rugby_player
  values(115,'Mike','Ross',100,0,9);
insert into rugby_player
  values(116,'Tadgh','Furlong',100,0,9);
insert into rugby_player
  values(117,'Ed','Byrne',100,0,9);
insert into rugby_player
  values(118,'Mike','McCarthy',100,0,9);
insert into rugby_player
  values(119,'Kane','Douglas',100,0,9);
insert into rugby_player
  values(120,'Rhys','Ruddock',100,0,9);
insert into rugby_player
  values(121,'Dominic','Ryan',100,0,9);
insert into rugby_player
  values(122,'Jack','Conan',100,0,9);
insert into rugby_player
  values(123,'Jamie','Heaslip',100,1,9);
 /*-----------------------------------------------------------------*/
insert into rugby_player
  values(201,'Felix','Jones',101,1,9);
insert into rugby_player
  values(202,'Andrew','Conway',101,0,9);
insert into rugby_player
  values(203,'Gerhard','Van den Heever',101,0,9);
insert into rugby_player
  values(204,'Andrew','Smith',101,0,9);
insert into rugby_player
  values(205,'Denis','Hurley',101,0,9);
insert into rugby_player
  values(206,'Simon','Zebo',101,0,9);
insert into rugby_player
  values(207,'Ian','Keatley',101,0,9);
insert into rugby_player
  values(208,'J.J','Hanrahan',101,0,9);
insert into rugby_player
  values(209,'Conor','Murray',101,0,9);
insert into rugby_player
  values(210,'James','Cronin',101,0,9);
insert into rugby_player
  values(211,'David','Kilcoyne',101,0,9);
insert into rugby_player
  values(212,'Duncan','Casey',101,0,9);
insert into rugby_player
  values(213,'Damien','Varley',101,0,9);
insert into rugby_player
  values(214,'Stephen','Archer',101,0,9);
insert into rugby_player
  values(215,'BJ','Botha',101,0,9);
insert into rugby_player
  values(216,'Dave','Foley',101,0,9);
insert into rugby_player
  values(217,'Paul','O Connell',101,0,9);
insert into rugby_player
  values(218,'CJ','Stander',101,0,9);
insert into rugby_player
  values(219,'Tommy','O Donnell',101,0,9);
insert into rugby_player
  values(220,'Robin','Copeland',101,0,9);
insert into rugby_player
  values(221,'Peter','O Mahony',101,0,9);
insert into rugby_player
  values(222,'Billy','Holland',101,0,9);
 /*-----------------------------------------------------------------*/
insert into rugby_player
  values(301,'Darragh','Leader',102,0,9);
insert into rugby_player
  values(302,'Robbie','Henshaw',102,0,9);
insert into rugby_player
  values(303,'Denis','Buckley',102,0,9);
insert into rugby_player
  values(305,'Ian','Porter',102,0,9);
insert into rugby_player
  values(306,'Jack','Carty',102,0,9);
insert into rugby_player
  values(307,'Niyi','Adeolokun',102,0,9);
insert into rugby_player
  values(304,'John','Muldoon',102,0,9);
 /*-----------------------------------------------------------------*/
insert into rugby_player
  values(401,'Jared','Payne',103,0,9);
insert into rugby_player
  values(402,'Stuart','Olding',103,0,9);
insert into rugby_player
  values(403,'Craig','Gilroy',103,0,9);
insert into rugby_player
  values(404,'Roger','Wilson',103,1,9);
insert into rugby_player
  values(405,'Ian','Humphreys',103,0,9);
insert into rugby_player
  values(406,'Franco','van der Merwe',103,0,9);
 /*-----------------------------------------------------------------*/
-- Add the rugby players
insert into rugby_supporter
  values(100000,'Simon','Markham',221,101,85);
insert into rugby_supporter
  values(100001,'Ross','Masey',121,102,20);
insert into rugby_supporter
  values(100002,'Gavin','Furke',301,102,14);
insert into rugby_supporter
  values(100003,'Caleb','Rior',401,102,6);
insert into rugby_supporter
  values(100004,'Conur','MocQuillon',211,102,99);
insert into rugby_supporter
  values(100005,'Bin','Launch',111,101,50);
 /*-----------------------------------------------------------------*/
insert into participate
  values(1000,101,(TO_DATE('26/12/2014','DD/MM/YYYY')));
insert into participate
  values(1000,100,(TO_DATE('26/12/2014','DD/MM/YYYY')));

insert into participate
  values(1001,101,(TO_DATE('07/01/2014','DD/MM/YYYY')));
insert into participate
  values(1001,102,(TO_DATE('07/01/2014','DD/MM/YYYY')));

insert into participate
  values(1002,101,(TO_DATE('03/02/2012','DD/MM/YYYY')));
insert into participate
  values(1002,103,(TO_DATE('03/02/2012','DD/MM/YYYY')));

insert into participate
  values(1003,100,(TO_DATE('25/01/2014','DD/MM/YYYY')));
insert into participate
  values(1003,101,(TO_DATE('25/01/2014','DD/MM/YYYY')));

insert into participate
  values(1004,102,(TO_DATE('06/02/2014','DD/MM/YYYY')));
insert into participate
  values(1004,100,(TO_DATE('06/02/2014','DD/MM/YYYY')));

insert into participate
  values(1005,100,(TO_DATE('31/03/2014','DD/MM/YYYY')));
insert into participate
  values(1005,103,(TO_DATE('31/03/2014','DD/MM/YYYY')));

insert into participate
  values(1006,102,(TO_DATE('24/09/2014','DD/MM/YYYY')));
insert into participate
  values(1006,101,(TO_DATE('24/09/2014','DD/MM/YYYY')));

insert into participate
  values(1007,102,(TO_DATE('10/10/2014','DD/MM/YYYY')));
insert into participate
  values(1007,100,(TO_DATE('10/10/2014','DD/MM/YYYY')));

insert into participate
  values(1008,102,(TO_DATE('11/04/2014','DD/MM/YYYY')));
insert into participate
  values(1008,103,(TO_DATE('11/04/2014','DD/MM/YYYY')));

insert into participate
  values(1009,103,(TO_DATE('30/04/2014','DD/MM/YYYY')));
insert into participate
  values(1009,101,(TO_DATE('30/04/2014','DD/MM/YYYY')));

insert into participate
  values(1010,103,(TO_DATE('09/02/2014','DD/MM/YYYY')));
insert into participate
  values(1010,100,(TO_DATE('09/02/2014','DD/MM/YYYY')));

insert into participate
  values(1011,102,(TO_DATE('30/03/2014','DD/MM/YYYY')));
insert into participate
  values(1011,103,(TO_DATE('30/03/2014','DD/MM/YYYY')));



insert into participate
  values(1012,201,(TO_DATE('26/12/2014','DD/MM/YYYY')));
insert into participate
  values(1012,200,(TO_DATE('26/12/2014','DD/MM/YYYY')));

insert into participate
  values(1013,201,(TO_DATE('07/01/2014','DD/MM/YYYY')));
insert into participate
  values(1013,202,(TO_DATE('07/01/2014','DD/MM/YYYY')));

insert into participate
  values(1014,201,(TO_DATE('03/02/2012','DD/MM/YYYY')));
insert into participate
  values(1014,203,(TO_DATE('03/02/2012','DD/MM/YYYY')));

insert into participate
  values(1015,200,(TO_DATE('25/01/2014','DD/MM/YYYY')));
insert into participate
  values(1015,201,(TO_DATE('25/01/2014','DD/MM/YYYY')));

insert into participate
  values(1016,202,(TO_DATE('06/02/2014','DD/MM/YYYY')));
insert into participate
  values(1016,200,(TO_DATE('06/02/2014','DD/MM/YYYY')));

insert into participate
  values(1017,200,(TO_DATE('31/03/2014','DD/MM/YYYY')));
insert into participate
  values(1017,203,(TO_DATE('31/03/2014','DD/MM/YYYY')));

insert into participate
  values(1018,202,(TO_DATE('24/09/2014','DD/MM/YYYY')));
insert into participate
  values(1018,201,(TO_DATE('24/09/2014','DD/MM/YYYY')));

insert into participate
  values(1019,202,(TO_DATE('10/10/2014','DD/MM/YYYY')));
insert into participate
  values(1019,200,(TO_DATE('10/10/2014','DD/MM/YYYY')));

insert into participate
  values(1020,202,(TO_DATE('11/04/2014','DD/MM/YYYY')));
insert into participate
  values(1020,203,(TO_DATE('11/04/2014','DD/MM/YYYY')));

insert into participate
  values(1021,203,(TO_DATE('30/04/2014','DD/MM/YYYY')));
insert into participate
  values(1021,201,(TO_DATE('30/04/2014','DD/MM/YYYY')));

insert into participate
  values(1022,203,(TO_DATE('09/02/2014','DD/MM/YYYY')));
insert into participate
  values(1022,200,(TO_DATE('09/02/2014','DD/MM/YYYY')));

insert into participate
  values(1023,202,(TO_DATE('30/03/2014','DD/MM/YYYY')));
insert into participate
  values(1023,203,(TO_DATE('30/03/2014','DD/MM/YYYY')));



insert into participate
  values(1024,301,(TO_DATE('26/12/2014','DD/MM/YYYY')));
insert into participate
  values(1024,300,(TO_DATE('26/12/2014','DD/MM/YYYY')));

insert into participate
  values(1025,301,(TO_DATE('07/01/2014','DD/MM/YYYY')));
insert into participate
  values(1025,302,(TO_DATE('07/01/2014','DD/MM/YYYY')));

insert into participate
  values(1026,301,(TO_DATE('03/02/2012','DD/MM/YYYY')));
insert into participate
  values(1026,303,(TO_DATE('03/02/2012','DD/MM/YYYY')));

insert into participate
  values(1027,300,(TO_DATE('25/01/2014','DD/MM/YYYY')));
insert into participate
  values(1027,301,(TO_DATE('25/01/2014','DD/MM/YYYY')));

insert into participate
  values(1028,302,(TO_DATE('06/02/2014','DD/MM/YYYY')));
insert into participate
  values(1028,300,(TO_DATE('06/02/2014','DD/MM/YYYY')));

insert into participate
  values(1029,300,(TO_DATE('31/03/2014','DD/MM/YYYY')));
insert into participate
  values(1029,303,(TO_DATE('31/03/2014','DD/MM/YYYY')));

insert into participate
  values(1030,302,(TO_DATE('24/09/2014','DD/MM/YYYY')));
insert into participate
  values(1030,301,(TO_DATE('24/09/2014','DD/MM/YYYY')));

insert into participate
  values(1031,302,(TO_DATE('10/10/2014','DD/MM/YYYY')));
insert into participate
  values(1031,300,(TO_DATE('10/10/2014','DD/MM/YYYY')));

insert into participate
  values(1032,302,(TO_DATE('11/04/2014','DD/MM/YYYY')));
insert into participate
  values(1032,303,(TO_DATE('11/04/2014','DD/MM/YYYY')));

insert into participate
  values(1033,303,(TO_DATE('30/04/2014','DD/MM/YYYY')));
insert into participate
  values(1033,301,(TO_DATE('30/04/2014','DD/MM/YYYY')));

insert into participate
  values(1034,303,(TO_DATE('09/02/2014','DD/MM/YYYY')));
insert into participate
  values(1035,300,(TO_DATE('09/02/2014','DD/MM/YYYY')));

insert into participate
  values(1035,302,(TO_DATE('30/03/2014','DD/MM/YYYY')));
insert into participate
  values(1035,303,(TO_DATE('30/03/2014','DD/MM/YYYY')));



insert into participate
  values(1036,401,(TO_DATE('26/12/2014','DD/MM/YYYY')));
insert into participate
  values(1036,400,(TO_DATE('26/12/2014','DD/MM/YYYY')));

insert into participate
  values(1037,401,(TO_DATE('07/01/2014','DD/MM/YYYY')));
insert into participate
  values(1037,402,(TO_DATE('07/01/2014','DD/MM/YYYY')));

insert into participate
  values(1038,401,(TO_DATE('03/02/2012','DD/MM/YYYY')));
insert into participate
  values(1038,403,(TO_DATE('03/02/2012','DD/MM/YYYY')));

insert into participate
  values(1039,400,(TO_DATE('25/01/2014','DD/MM/YYYY')));
insert into participate
  values(1039,401,(TO_DATE('25/01/2014','DD/MM/YYYY')));

insert into participate
  values(1040,402,(TO_DATE('06/02/2014','DD/MM/YYYY')));
insert into participate
  values(1040,400,(TO_DATE('06/02/2014','DD/MM/YYYY')));

insert into participate
  values(1041,400,(TO_DATE('31/03/2014','DD/MM/YYYY')));
insert into participate
  values(1041,403,(TO_DATE('31/03/2014','DD/MM/YYYY')));

insert into participate
  values(1042,402,(TO_DATE('24/09/2014','DD/MM/YYYY')));
insert into participate
  values(1042,401,(TO_DATE('24/09/2014','DD/MM/YYYY')));

insert into participate
  values(1043,402,(TO_DATE('10/10/2014','DD/MM/YYYY')));
insert into participate
  values(1043,400,(TO_DATE('10/10/2014','DD/MM/YYYY')));

insert into participate
  values(1044,402,(TO_DATE('11/04/2014','DD/MM/YYYY')));
insert into participate
  values(1044,403,(TO_DATE('11/04/2014','DD/MM/YYYY')));

insert into participate
  values(1045,403,(TO_DATE('30/04/2014','DD/MM/YYYY')));
insert into participate
  values(1045,401,(TO_DATE('30/04/2014','DD/MM/YYYY')));

insert into participate
  values(1046,403,(TO_DATE('09/02/2014','DD/MM/YYYY')));
insert into participate
  values(1046,400,(TO_DATE('09/02/2014','DD/MM/YYYY')));

insert into participate
  values(1047,402,(TO_DATE('30/03/2014','DD/MM/YYYY')));
insert into participate
  values(1047,403,(TO_DATE('30/03/2014','DD/MM/YYYY')));


/*******************************************************************/
-- Add the rugby fixtures
insert into fixture_list values(1000,101,100,0);
insert into fixture_list values(1001,101,102,1);
insert into fixture_list values(1002,101,103,0);
insert into fixture_list values(1003,100,101,0);
insert into fixture_list values(1004,102,100,0);
insert into fixture_list values(1005,100,103,0);
insert into fixture_list values(1006,101,102,0);
insert into fixture_list values(1007,102,100,0);
insert into fixture_list values(1008,102,103,0);
insert into fixture_list values(1009,103,101,0);
insert into fixture_list values(1010,103,100,0);
insert into fixture_list values(1011,103,102,0);

insert into fixture_list values(1012,201,200,0);
insert into fixture_list values(1013,201,202,1);
insert into fixture_list values(1014,201,203,0);
insert into fixture_list values(1015,200,201,0);
insert into fixture_list values(1016,202,200,0);
insert into fixture_list values(1017,200,203,0);
insert into fixture_list values(1018,201,202,0);
insert into fixture_list values(1019,202,200,0);
insert into fixture_list values(1020,202,203,0);
insert into fixture_list values(1021,203,201,0);
insert into fixture_list values(1022,203,200,0);
insert into fixture_list values(1023,203,202,0);

insert into fixture_list values(1024,301,300,0);
insert into fixture_list values(1025,301,302,1);
insert into fixture_list values(1026,301,303,0);
insert into fixture_list values(1027,300,301,0);
insert into fixture_list values(1028,302,300,0);
insert into fixture_list values(1029,300,303,0);
insert into fixture_list values(1030,301,302,0);
insert into fixture_list values(1031,302,300,0);
insert into fixture_list values(1032,302,303,0);
insert into fixture_list values(1033,303,301,0);
insert into fixture_list values(1034,303,300,0);
insert into fixture_list values(1035,303,302,0);

insert into fixture_list values(1036,401,400,0);
insert into fixture_list values(1037,401,402,1);
insert into fixture_list values(1038,401,403,0);
insert into fixture_list values(1039,400,401,0);
insert into fixture_list values(1040,402,400,0);
insert into fixture_list values(1041,400,403,0);
insert into fixture_list values(1042,401,402,0);
insert into fixture_list values(1043,402,400,0);
insert into fixture_list values(1044,402,403,0);
insert into fixture_list values(1045,403,401,0);
insert into fixture_list values(1046,403,400,0);
insert into fixture_list values(1047,403,402,0);
 /*-----------------------------------------------------------------*/
---- Matt O Connor was fired and Seamus Lawless was hired
delete from rugby_coach where coach_id = 1000;
insert into rugby_coach values(1000,'Seamus','Lawless',100,0,0);

alter table rugby_team
  add foreign key (headCoachID) references rugby_coach(coach_id);
alter table rugby_coach
  add foreign key (teamID) references rugby_team(team_id);

alter table participate
  add foreign key (fixtureID) references fixture_list(fixtureID);
alter table participate
  add foreign key (team) references rugby_team(team_id);


-- Views
 create view LeinsterPlayers as
   select firstname, surname
   from rugby_player
   where teamID = '100';
  /*-----------------------------------------------------------------*/
 create view MunsterPlayers as
   select firstname, surname
   from rugby_player
   where teamID = '101';
  /*-----------------------------------------------------------------*/
 create view ConnachtPlayers as
   select firstname, surname
   from rugby_player
   where teamID = '102';
  /*-----------------------------------------------------------------*/
 create view UlsterPlayers as
   select firstname, surname
   from rugby_player
   where teamID = '103';
  /*-----------------------------------------------------------------*/
 create view getLeinsterCoach as
   select firstnameC, surnameC
   from rugby_coach
   where teamID = '100';
  /*-----------------------------------------------------------------*/
 create view getMunsterCoach as
   select firstnameC, surnameC
   from rugby_coach
   where teamID = '101';
  /*-----------------------------------------------------------------*/
 create view getUlsterCoach as
   select firstnameC, surnameC
   from rugby_coach
   where teamID = '103';
  /*-----------------------------------------------------------------*/
 create view getConnachtCoach as
   select firstnameC, surnameC
   from rugby_coach
   where teamID = '102';
  /*-----------------------------------------------------------------*/
 create view LeinsterTeam as
   select rugby_player.firstname, rugby_player.surname,
                         rugby_coach.firstnameC, rugby_coach.surnameC
   from rugby_player
   inner join rugby_coach
   on rugby_coach.teamID = '100' and rugby_player.teamID = '100';
  /*-----------------------------------------------------------------*/
 create view MunsterTeam as
   select rugby_player.firstname, rugby_player.surname,
                         rugby_coach.firstnameC, rugby_coach.surnameC
   from rugby_player
   inner join rugby_coach
   on rugby_coach.teamID = '101' and rugby_player.teamID = '101';
  /*-----------------------------------------------------------------*/
 create view UlsterTeam as
   select rugby_player.firstname, rugby_player.surname,
                         rugby_coach.firstnameC, rugby_coach.surnameC
   from rugby_player
   inner join rugby_coach
   on rugby_coach.teamID = '102' and rugby_player.teamID = '102';
  /*-----------------------------------------------------------------*/
 create view ConnachtTeam as
   select rugby_player.firstname, rugby_player.surname,
                         rugby_coach.firstnameC, rugby_coach.surnameC
   from rugby_player
   inner join rugby_coach
   on rugby_coach.teamID = '103' and rugby_player.teamID = '103';
 /*-----------------------------------------------------------------*/
 select * from LeinsterPlayers;
 select * from MunsterPlayers;
 select * from ConnachtPlayers;
 select * from UlsterPlayers;
  /*-----------------------------------------------------------------*/
 select * from getUlsterCoach;
 select * from getLeinsterCoach;
 select * from getConnachtCoach;
 select * from getMunsterCoach;
  /*-----------------------------------------------------------------*/
 select * from LeinsterTeam;
 select * from MunsterTeam;
 select * from UlsterTeam;
 select * from ConnachtTeam;
  /*-----------------------------------------------------------------*/
 -- drop view LeinsterTeam;
 -- drop view MunsterTeam;
 -- drop view UlsterTeam;
 -- drop view ConnachtTeam;
 --  /*-----------------------------------------------------------------*/
 -- drop view LeinsterPlayers;
 -- drop view MunsterPlayers;
 -- drop view ConnachtPlayers;
 -- drop view UlsterPlayers;
 --  /*-----------------------------------------------------------------*/
 -- drop view getLeinsterCoach;
 -- drop view getMunsterCoach;
 -- drop view getConnachtCoach;
 -- drop view getUlsterCoach;

 select * from rugby_union;
 select * from rugby_player;
 select * from rugby_team;
 select * from rugby_coach;
 select * from fixture_list;
 select * from participate;
 select * from leagueTable;
/*
  Drops the created tables, used for error testing
*/
 -- drop table leagueTable CASCADE CONSTRAINT;
 -- drop table participate CASCADE CONSTRAINT;
 -- drop table fixture_list CASCADE CONSTRAINT;
 -- drop table rugby_supporter CASCADE CONSTRAINT;
 -- drop table rugby_player CASCADE CONSTRAINT;
 -- drop table rugby_coach CASCADE CONSTRAINT;
 -- drop table rugby_team CASCADE CONSTRAINT;
 -- drop table rugby_union CASCADE CONSTRAINT;
