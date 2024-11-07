model Parameters 

import "./main.gaml"

global {
	//----------------------Simulation Parameters------------------------
	
	//Simulation time step
	float step <- 5 #sec; 
	
	//Simulation starting date
	date starting_date <- date("2019-10-01 00:00:00"); //SS 
	
	//Date for log files
	date logDate <- date("2024-01-30 11:00:00");
	
	date nowDate <- #now;
	
	//Duration of the simulation
	int numberOfDays <- 1; //WARNING: If >1 set numberOfHours to 24h
	int numberOfHours <- 24; //WARNING: If one day, we can also specify the number of hours, otherwise set 24h
	
		
	//----------------------Simulation modes------------------------
	bool peopleEnabled <- true;
	bool packagesEnabled <- false; //Initially, we will only have people (dBizi data)
	bool biddingEnabled <- false; //Ignore bidding for the tangible model
	bool dynamicFleetsizing <- false; //Ignore this process too
	bool rebalEnabled <- false; // Ignore rebalancing for now, this is a rebalancing for autonomous vehicles
	
	//----------------------Logging Parameters ------------------------
	//ALL SET TO FALSE, set to true if you want to save csv
	bool loggingEnabled <- false; 
	bool printsEnabled <- false; 
	bool autonomousBikeEventLog <- false;
	bool peopleTripLog <-false;
	bool peopleEventLog <-false;
	bool packageTripLog <-false;
	bool packageEventLog <-false; 	
	bool stationChargeLogs <- false; 
	bool roadsTraveledLog <- false; 
	
	//-----------------Autonomous Bike Parameters-----------------------
	int numAutonomousBikes <- 0 min:1 max: 3000 parameter: "Number of Autonomous Bikes";
	float maxBatteryLifeAutonomousBike <- 70000.0 #m min:30000.0 #m max: 140000.0 #m parameter: "Battery size"; //battery capacity in m
	float DrivingSpeedAutonomousBike <-  8/3.6 #m/#s min: 1/3.6 #m/#s  max: 15/3.6 #m/#s parameter: "Autonomous Driving Speed";
	float minSafeBatteryAutonomousBike <- 0.3*maxBatteryLifeAutonomousBike #m; //Amount of battery at which we seek battery and that is always reserved when charging another bike
	
	
	//-----------------Bidding Parameters-----------------------
	//I don't think this will be used in the tangible table
	float maxBiddingTime <- 0.5;
	int UrgencyPerson <- 1; 
	int UrgencyPackage <- 0;
	//float w_urgency <- 0.0 min:0.0 max: 1.0 parameter: "Urgency weight";
	//float w_wait <- 0.75 min:0.0 max: 1.0 parameter: "Wait weight";
	//float w_proximity <-0.25 min:0.0 max: 1.0 parameter: "Proximity weight"; 
	float w_urgency <- 0.0 min:0.0 max: 1.0;
	float w_wait <- 0.75 min:0.0 max: 1.0;
	float w_proximity <-0.25 min:0.0 max: 1.0; 


	
	//----------------------Charging Parameters------------------------
	int stationCapacity <- 16; //Average number of docks in bluebikes stations in April 2022*/
	int numChargingStations <- 78;
	//float V2IChargingRate <- maxBatteryLifeAutonomousBike/(4.5*60*60) #m/#s; //4.5 h of charge
	float V2IChargingRate <- maxBatteryLifeAutonomousBike/(111) #m/#s;  // 111 s battery swapping -> average of the two reported by Fei-Hui Huang 2019 Understanding user acceptancd of battery swapping service of sustainable transport
		
	//--------------------------User Parameters----------------------------
	float maxWaitTimePeople <- 15 #mn;
	float maxDistancePeople_AutonomousBike <- maxWaitTimePeople*60*DrivingSpeedAutonomousBike #m; //The maxWaitTime is translated into a max radius taking into account the speed of the bikes
    //TODO REVIEW MAX DISTANCE PEOPLE (IT DOESNT UPDATE THE VALUE FROM HERE)
    float peopleSpeed <- 5/3.6 #m/#s; 
    float RidingSpeedAutonomousBike <-  10.2/3.6;
	
    //--------------------------Package Parameters----------------------------
    float maxWaitTimePackage <- 40 #mn;
	float maxDistancePackage_AutonomousBike <- maxWaitTimePackage*DrivingSpeedAutonomousBike #m;
	 

    
       
    //----------------------Input Files------------------------
	
	
 	//************* CASE SAN SEBASTIAN *************** 
 	string cityScopeCity <- "SanSebastian";
	string cityGISFolder <- "./../includes/DataSS";
	file bound_shapefile <-file(cityGISFolder + "/boundary/SquareBoundarySS.shp");
	//file bound_shapefile <-file(cityGISFolder + "/boundary/small_boundary.shp");
	file roads_shapefile <- file(cityGISFolder + "/roads/ss_bike.shp/edges.shp");
	//file roads_shapefile <- file(cityGISFolder + "/roads/ss_bike_small.shp/edges.shp");
	//file buildings_shapefile <- file(cityGISFolder + "/buildings/buildings_ss.shp");
	csv_file chargingStations_csv <- csv_file(cityGISFolder+ "/Rides/stations_hexcell.csv",true);
	csv_file demand_csv <- csv_file (cityGISFolder+ "/Rides/ride_demand_ss_1week_scattered.csv",true);  
	//csv_file pdemand_csv <- csv_file (cityGISFolder+ "/Deliveries/delivery_demand_ss_1week_scattered.csv",true);
    //csv_file food_hotspot_csv <- csv_file (cityGISFolder+ "/Deliveries/deliveries_ss_top10density.csv",true);
    csv_file user_hotspot_csv <- csv_file (cityGISFolder+ "/Rides/rides_ss_top10density.csv",true);
    
	
	// --------- Layers --------- 
	
	
	// Show Layers
	bool show_building <- true;
	bool show_road <- true;
	bool show_people <- true;
	bool show_chargingStation <- true;
	bool show_package <- true;
	bool show_autonomousBike <- true;	
	
	
	//rgb 
	rgb foodwastecolor;	
}	