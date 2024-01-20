use ipl;
# 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

#Table Used:
select * from ipl_bidding_details ;

select Bidder_id, bid_status, count(BID_STATUS)/(select count(BID_STATUS)  from ipl_bidding_details i
where i.bidder_id = e.bidder_id) as percentage
from ipl_bidding_details e
where BID_STATUS = 'Won'
group by bidder_id
order by percentage desc;

#Display the number of matches conducted at each stadium with the stadium name and city.

#Table Used:
select * from ipl_stadium ;
select * from ipl_match_schedule;

select ist.stadium_id, ist.stadium_name, ist.city, count(*) as matches_conducted
from ipl_stadium ist join ipl_match_schedule ims 
on ist.STADIUM_ID = ims.STADIUM_ID
group by ist.stadium_id, ist.stadium_name, ist.city;

#3.	In a given stadium, what is the percentage of wins by a team which has won the toss?


# Table used
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_stadium;

select stadium_id, stadium_name,tm_winner, total_matches, tm_winner/total_matches *100 as perc_of_toss_match_wins 
from(
	select stadium_id, stadium_name ,count(*) tm_winner,(
						 select count(*) from  ipl_match_schedule y 
						 where b.stadium_id = y.stadium_id
						) total_matches
	 from IPL_match a
	join ipl_match_schedule b
	using(match_id)
    join ipl_stadium
    using(stadium_id)
	where toss_winner = match_winner
	group by stadium_id
	order by stadium_id
) a;

#4.	Show the total bids along with the bid team and team name.

#Table Used:
select * from ipl_bidding_details;
select * from  ipl_team ;

select ibd.bid_team, it.team_name, count(ibd.bidder_id) as total_bids
from ipl_bidding_details ibd join ipl_team it
on  ibd.bid_team = it.team_id
group by ibd.bid_team, it.team_name
order by  total_bids desc;

#5.	Show the team id who won the match as per the win details.

#Table Used:
select * from ipl_team;
select * from ipl_match;

select team_id,  im.win_details
from ipl_team it join ipl_match im
on  im.win_details like concat("%",it.remarks,"%");


#6.	Display total matches played, total matches won and total matches lost by the team along with its team name.

#Table Used:
select * from ipl_team;
select * from ipl_match;

SELECT it.team_id, it.team_name, count(*) as total_matches_played,
sum(case when   im.win_details like concat("%",it.remarks,"%") then 1 else 0 end) as total_matches_won,
sum(case when   im.win_details not like concat("%",it.remarks,"%") then 1 else 0 end) as total_matches_lost
from ipl_team it  join ipl_match im 
on it.team_id = im.team_id1 or it.team_id = im.team_id2
group by it.team_id, it.team_name;


#7.	Display the bowlers for the Mumbai Indians team.

#Table Used:
SELECT * FROM ipl.ipl_team_players;
SELECT * FROM ipl.ipl_player;
SELECT * FROM ipl.ipl_team;

select player_id, (select player_name from ipl_player where player_id = itp.player_id) as player_name,
player_role, team_id from ipl_team_players itp
where player_role like '%bowler%' and TEAM_ID in (select team_id from ipl_team where team_name like '%Mumbai Indians%');

#8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
# joined on Remarks

#Table Used:
select * from ipl_team_players;
select * from ipl_team;

select it.team_id, it.team_name, count(distinct player_id) as count_of_all_rounders 
from ipl_team_players itp join ipl_team it 
on itp.team_id = it.team_id
where player_role like '%All-Rounder%' 
group by it.team_id, it.team_name
having count_of_all_rounders>4
order by count_of_all_rounders desc;

#9.	 Write a query to get the total bidders points for each bidding status 
# of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
# Note the total bidders’ points in descending order and the year is bidding year.
# Display columns: bidding status, bid date as year, total bidder’s points

#Table Used:
select * from ipl_bidding_details;
select * from ipl_match_schedule;
select * from ipl_match;
select * from ipl_bidder_points;


select ibp.bidder_id, ibp.tournmt_id, ibp.total_points,  ibd.schedule_id, ibd.bid_date, ibd.bid_status
from ipl_bidder_points ibp join ipl_bidding_details ibd
on ibp.bidder_id = ibd.bidder_id
where ibd.bid_status like '%won%';


# method 2
select ibd.bid_status, ibd.bid_date, ibp.total_points, ims.match_id, ims.schedule_id, ims.match_date, ims.stadium_id, im.match_id, im.win_details
from ipl_bidder_points ibp join ipl_bidding_details ibd
on  ibp.bidder_id = ibd.bidder_id
join ipl_match_schedule ims
on ibd.schedule_id = ims.schedule_id
join ipl_match im
on ims.match_id = im.match_id
join ipl_stadium ips
using(stadium_id)
where ips.stadium_name like '%chinna%' and win_details like '%CSK won%' ;

# method 3

#Table Used:
select * from ipl_bidding_details;
select * from ipl_match_schedule;
select * from ipl_match;
select * from ipl_bidder_points;

select ibd.bid_status, year(ibd.bid_date) as bid_year, ibp.total_points as total_bidder_points
from ipl_bidder_points ibp join ipl_bidding_details ibd
on  ibp.bidder_id = ibd.bidder_id
join ipl_match_schedule ims
on ibd.schedule_id = ims.schedule_id
join ipl_match im
on ims.match_id = im.match_id
join ipl_stadium ips
using(stadium_id)
where ips.stadium_name like '%chinna%' and win_details like '%CSK won%' 
order by ibp.total_points desc;

#10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
#Note 
#1. use the performance_dtls column from ipl_player to get the total number of wickets
#2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
#3.	Do not use joins in any cases.
#4.	Display the following columns teamn_name, player_name, and player_role.

#Table Used:
SELECT * FROM ipl.ipl_player;
SELECT * FROM ipl.ipl_team;
SELECT * FROM ipl.ipl_team_players;


select player_id, player_name,
(select player_role
from ipl_team_players t
where t.player_id = p.player_id and (player_role like '%all%' or player_role like '%bowl%')) as player_role,
performance_dtls, Wickets, (select team_name from ipl_team where team_id = any ( select team_id from ipl_team_players itp where itp.player_id = p.player_id)) team_name
from (
			 select ip.player_id, ip.player_name, ip.performance_dtls,
			cast(substring_index(substring_index(ip.performance_dtls, 'Wkt-', -1), ' ', 1) as unsigned) as Wickets,
			dense_rank() over (order by cast(substring_index(substring_index(ip.performance_dtls, 'Wkt-', -1), ' ', 1) as unsigned) desc) as rnk
			from ipl_player ip
) as p
where p.rnk <= 5 ;



#11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

#Table used
select * from ipl_match_schedule;
select * from ipl_match;
select * from ipl_bidding_details;

select BIDDER_ID,total_toss_win,total_matches_bid,(total_toss_win/total_matches_bid)*100 percentage_toss_win from 
(select distinct *,count(case when toss_win_status ="won" then toss_win_status end )over(partition by BIDDER_ID) total_toss_win,
count(BIDDER_ID)over(partition by BIDDER_ID) total_matches_bid from
(select BIDDER_ID, if(team_that_won_the_toss=BID_TEAM,"won","lost") toss_win_status from
(select BIDDER_ID,m.MATCH_ID,SCHEDULE_ID, if(TOSS_WINNER=1,TEAM_ID1,TEAM_ID2) team_that_won_the_toss,BID_TEAM 
from ipl_match_schedule ms join ipl_match m using(MATCH_ID) join ipl_bidding_details bd using(SCHEDULE_ID))t)t1)t2 
where toss_win_status="won" or total_toss_win=0 order by percentage_toss_win desc;


#12.	find the IPL season which has min duration and max duration.Output columns should be like the below:
#Tournment_ID, Tourment_name, Duration column, Duration

#Table used
select * from ipl_tournament;

select * from(
select tournmt_id, tournmt_name, from_date, to_date, datediff(to_date, from_date) as Duration,
rank()over(order by datediff(to_date, from_date)) as rnk 
from ipl_tournament it 
order by Duration) t
where rnk=1 or rnk=10;

#13.	Write a query to display to calculate the total points month-wise for the 2017 bid year.
# sort the results based on total points in descending order and month-wise in ascending order.
#Note: Display the following columns:
#1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
#Only use joins for the above query queries.

#Table used
select * from ipl_bidder_details;
select * from ipl_bidding_details;
select * from ipl_bidder_points;

select brd.Bidder_id,brd.bidder_name,year(bid_date)bid_date_year,month(BID_DATE)bid_date_month, 
bp.total_points
from ipl_bidder_details brd join ipl_bidding_details bgd using(bidder_id)
join ipl_bidder_points bp using(bidder_id)
where year(bid_date)=2018
group by brd.Bidder_id,brd.bidder_name,year(bid_date),month(BID_DATE),bp.total_points
order by bp.total_points desc,month(BID_DATE) asc;

# 14.	Write a query for the above question using sub queries by having the same constraints as the above question.

#Table used
select * from ipl_bidder_points;
select * from ipl_bidder_details;
select * from ipl_bidding_details;


select bidder_id, (select bidder_name from ipl_bidder_details ibd where ibd.bidder_id=bd.bidder_id) as bidder_name,
year(bid_date)bid_date_year, monthname(bid_date)bid_date_month, 
(select total_points from ipl_bidder_points bp where bp.bidder_id=bd.bidder_id) total_points from ipl_bidding_details bd
where year(bid_date)=2018
group by bidder_id,bidder_name,bid_date_year,bid_date_month,total_points
order by total_points desc,bid_date_month asc;



# 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
# Output columns should be like:
# Bidder Id, Ranks (optional), Total points, Highest_3_Bidders 
-- > columns contains name of bidder, Lowest_3_Bidders  
-- > columns contains name of bidder;

#Table used
select * from ipl_bidder_points;
select * from ipl_bidder_details;

select *,if (drnk<=3,"top3_bidders","bottom3_bidders" )top3_and_bottom3_bidders from
(select bidder_id,total_points,dense_rank()over(order by total_points desc) drnk,
(select bidder_name from ipl_bidder_details where bidder_id=ibp.bidder_id) bidder_name
from  ipl_bidder_points ibp)t1 where drnk<=3 or drnk>13 ;

#16th question - triggers
#Table 1: Attributes 		Table 2: Attributes
#Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

create table if not exists student_details(
Student_id int primary key , 
Student_name varchar(10),
mail_id varchar(20),
mobile_no varchar(15));


create table if not exists Backup_student_details(
Student_id int primary key , 
Student_name varchar(10),
mail_id varchar(20),
mobile_no varchar(15),
    backup_timestamp timestamp default current_timestamp
);

delimiter //
create trigger Insert_Student_Backup
after insert on student_details
for each row
begin
    insert into Backup_student_details (Student_id, Student_name, mail_id, mobile_no)
    values (new.Student_id,new.Student_name, new.mail_id, new.mobile_no);
end;
//
delimiter ;

# 17 . List of RCB Batsmen in the season 

#Table used
select * from ipl_bidder_points;
select * from ipl_bidder_details;

select player_name from
ipl_player p join ipl_team_players tp
on p.player_id = tp.player_id
join ipl_team t 
on tp.team_id = t.team_id
where team_name like "%Royal Challengers Bangalore%" and player_role like "%Batsman%";

#18 Arrange no of matches played at stadium in 2018 and 2017 in descending order*/

#Tables used
select * from ipl_match_schedule;
select * from ipl_stadium;

select distinct ims.stadium_id,stadium_name, tournmt_id,count(ims.stadium_id) 
from ipl_match_schedule as ims join ipl_stadium as ips
on ims.stadium_id=ips.stadium_id
group by stadium_id,tournmt_id order by count(ims.stadium_id) desc;

#19 Display best bidders on a per bid basis */

#Table used
select * from ipl_bidder_points;
select *  from ipl_bidder_details;

select ibp.bidder_id, bidder_name, total_points, no_of_bids, total_points/no_of_bids as points_per_bid
from ipl_bidder_points as ibp join ipl_bidder_details as ibd 
on ibp.bidder_id=ibd.bidder_id
order by points_per_bid desc;

#20 Display ipl team squad strength and strength of player role per team_id in descending order */

#Table used
select * from ipl_team_players;
select * from ipl_team;

select distinct itp.team_id,team_name,player_role, 
count(player_id) over(partition by team_id,player_role)as count_player_role,
count(player_id) over(partition by team_id) as squad_strength
from ipl_team_players as itp join ipl_team as it
on itp.team_id=it.team_id
order by squad_strength desc;


    













