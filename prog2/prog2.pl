% PROGRAMMING PARTNER: Sabrina Au

% %test :-
% %   print_trip( depart, nyc, 'New York City', time( 9, 3)),
% %   print_trip( arrive, lax, 'Los Angeles', time( 14, 22)).

% %doSomething(nyc,lax) :- test.

flight( bos, nyc, time( 7,30 ) ).
flight( dfw, den, time( 8, 0 ) ).
flight( atl, lax, time( 8,30 ) ).
flight( chi, den, time( 8,45 ) ).
flight( mia, atl, time( 9, 0 ) ).
flight( sfo, lax, time( 9, 0 ) ).
flight( sea, den, time( 10, 0 ) ).
flight( nyc, chi, time( 11, 0 ) ).
flight( sea, lax, time( 11, 0 ) ).
flight( den, dfw, time( 11,15 ) ).
flight( sjc, lax, time( 11,15 ) ).
flight( atl, lax, time( 11,30 ) ).
flight( atl, mia, time( 11,30 ) ).
flight( chi, nyc, time( 12, 0 ) ).
flight( lax, atl, time( 12, 0 ) ).
flight( lax, sfo, time( 12, 0 ) ).
flight( lax, sjc, time( 12,15 ) ).
flight( nyc, bos, time( 12,15 ) ).
flight( bos, nyc, time( 12,30 ) ).
flight( den, chi, time( 12,30 ) ).
flight( dfw, den, time( 12,30 ) ).
flight( mia, atl, time( 13, 0 ) ).
flight( sjc, lax, time( 13,15 ) ).
flight( lax, sea, time( 13,30 ) ).
flight( chi, den, time( 14, 0 ) ).
flight( lax, nyc, time( 14, 0 ) ).
flight( sfo, lax, time( 14, 0 ) ).
flight( atl, lax, time( 14,30 ) ).
flight( lax, atl, time( 15, 0 ) ).
flight( nyc, chi, time( 15, 0 ) ).
flight( nyc, lax, time( 15, 0 ) ).
flight( den, dfw, time( 15,15 ) ).
flight( lax, sjc, time( 15,30 ) ).
flight( lax, sea, time( 16,45 ) ).
flight( chi, nyc, time( 18, 0 ) ).
flight( lax, atl, time( 18, 0 ) ).
flight( lax, sfo, time( 18, 0 ) ).
flight( nyc, bos, time( 18, 0 ) ).
flight( sfo, lax, time( 18, 0 ) ).
flight( sjc, lax, time( 18,15 ) ).
flight( atl, mia, time( 18,30 ) ).
flight( den, chi, time( 18,30 ) ).
flight( lax, sjc, time( 19,30 ) ).
flight( lax, sfo, time( 20, 0 ) ).
flight( sea, den, time( 21, 0 ) ).
flight( lax, sea, time( 22,30 ) ).

airport( atl, 'Atlanta         ', degmin(  33,39 ), degmin(  84,25 ) ).
airport( bos, 'Boston-Logan    ', degmin(  42,22 ), degmin(  71, 2 ) ).
airport( chi, 'Chicago         ', degmin(  42, 0 ), degmin(  87,53 ) ).
airport( den, 'Denver-Stapleton', degmin(  39,45 ), degmin( 104,52 ) ).
airport( dfw, 'Dallas-Ft.Worth ', degmin(  32,54 ), degmin(  97, 2 ) ).
airport( lax, 'Los Angeles     ', degmin(  33,57 ), degmin( 118,24 ) ).
airport( mia, 'Miami           ', degmin(  25,49 ), degmin(  80,17 ) ).
airport( nyc, 'New York City   ', degmin(  40,46 ), degmin(  73,59 ) ).
airport( sea, 'Seattle-Tacoma  ', degmin(  47,27 ), degmin( 122,17 ) ).
airport( sfo, 'San Francisco   ', degmin(  37,37 ), degmin( 122,23 ) ).
airport( sjc, 'San Jose        ', degmin(  37,22 ), degmin( 121,56 ) ).

print_trip( Action, Code, Name, time( Hour, Minute)) :-
   upcase_atom( Code, Upper_code),
   format( "~6s  ~3s  ~s~26|  ~`0t~d~30|:~`0t~d~33|",
           [Action, Upper_code, Name, Hour, Minute]),
   nl.

degmin_to_rad( Deg, Min, Radians) :- 
	Radians is (Deg + Min / 60)*pi/180.

dist( Lat1,Long1,Lat2,Long2,D) :- 
	Dlon is Long2-Long1, 
	Dlat is Lat2-Lat1,
    A is  sin(Dlat/2)^2 + cos(Lat1) * cos(Lat2) * sin(Dlon/2)^2,
    C is  2 * atan(sqrt(A) / sqrt(1-A)),
    D is C * 3956.

is_after( time(H,_),time(AH, _)) :- H > AH.
is_after( time(H,M),time(AH, AM)) :- H == AH, M > AM.

add_time( time(H1,M1),time(H2,M2),time(H3,M3)) :- 
	M3 is (M1+M2) mod 60, 
	H3 is (H1+H2)+(M1+M2) div 60.

mins_to_hours( Minutes,time(H,M)) :- M is Minutes mod 60, H is Minutes div 60.

flight_time( From, To, Transit) :- 
	airport( From,_,degmin(D1,M1),degmin(D2,M2)),
    airport( To,_,degmin(D3,M3),degmin(D4,M4)),
    degmin_to_rad( D1,M1,R1),degmin_to_rad(D2,M2,R2),
    degmin_to_rad( D3,M3,R3), degmin_to_rad(D4,M4,R4), 
    dist( R1,R2,R3,R4,Dist), 
    TransitMinutes is round( Dist * 60 / 500), 
    mins_to_hours( TransitMinutes, Transit).

route( City1, City2, After, [leg(City1,City2,Depart,Arrive)]) :- 
	flight( City1, City2, Depart), 
	is_after( Depart, After),
   	flight_time( City1,City2,Transit), 
   	add_time( Depart,Transit,Arrive).
route( City1, City2, After, [leg(City1,Stop,Depart1,Arrive2)|OtherLegs]) :- 
   direct( City1, Stop, After, 
   leg( City1,Stop,Depart1,Arrive2)),
   add_time( Arrive2,time(0,30),After2),
   route( Stop, City2, After2, OtherLegs).

direct( From, To, After, leg(From,To,Depart,Arrive)) :- 
	flight( From, To, Depart), 
	is_after( Depart, After),
    flight_time( From,To,Transit), 
    add_time( Depart,Transit,Arrive).

printLeg( leg(From,To,Depart,Arrive)) :-
   airport( From,FromCity,_,_), airport(To,ToCity,_,_),
   print_trip( depart, From, FromCity, Depart),
   print_trip( arrive, To, ToCity, Arrive).

printTrip([Leg]) :- printLeg(Leg),!.
printTrip([Leg1|Rest]) :- printLeg(Leg1),printTrip(Rest).

main :- read( From),read( To), \+ From = To, route( From, To, time(0,0), Route), printTrip( Route).