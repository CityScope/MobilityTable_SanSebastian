model Parameters 

import "./main.gaml" 

global {
	//----------------------Simulation Parameters------------------------
	
	//Simulation time step
	float step <- 2 #sec; 
	
	//Simulation starting date
	date starting_date <- date("2019-10-01 00:00:00"); //SS //TODO: ADAPT DATE
	//date starting_date <- date("2019-10-07 00:00:00");  // CAMBRIDGE
	
	//Date for log files
	date logDate <- date("2023-12-06 10:00:00");
	
	date nowDate <- #now;
	
	//Duration of the simulation
	int numberOfWeeks <-1;
	int numberOfDays <- 7; //WARNING: If >1 set numberOfHours to 24h
	int numberOfHours <- 24; //WARNING: If one day, we can also specify the number of hours, otherwise set 24h
	
		
	//----------------------Simulation modes------------------------
	bool peopleEnabled <- true;
	bool packagesEnabled <- true;
	bool biddingEnabled <- true;
	bool dynamicFleetsizing <- false;
	
	//----------------------Logging Parameters------------------------
	bool loggingEnabled <- true; 
	bool printsEnabled <- false; 
	bool autonomousBikeEventLog <- false;
	bool peopleTripLog <-true ;
	bool peopleEventLog <-false;
	bool packageTripLog <-true;
	bool packageEventLog <-false; 	
	bool stationChargeLogs <- true; 
	bool roadsTraveledLog <- false; 
	
	//-----------------Autonomous Bike Parameters-----------------------
	int numAutonomousBikes <- 0;
	float maxBatteryLifeAutonomousBike <- 70000.0 #m; //battery capacity in m
	float DrivingSpeedAutonomousBike <-  8/3.6 #m/#s;
	float minSafeBatteryAutonomousBike <- 0.3*maxBatteryLifeAutonomousBike #m; //Amount of battery at which we seek battery and that is always reserved when charging another bike
	
	
	//-----------------Bidding Parameters-----------------------
	float maxBiddingTime <- 0.5;
	int UrgencyPerson <- 1; 
	int UrgencyPackage <- 0;
	float w_urgency <- 0.25 min:0.0 max: 1.0 parameter: "Urgency weight";
	float w_wait <- 0.0 min:0.0 max: 1.0 parameter: "Wait weight";
	float w_proximity <-0.75 min:0.0 max: 1.0 parameter: "Proximity weight"; 


	
	//----------------------Charging Parameters------------------------
	int stationCapacity <- 16; //Average number of docks in bluebikes stations in April 2022*/
	int numChargingStations <- 78;
	//float V2IChargingRate <- maxBatteryLifeAutonomousBike/(4.5*60*60) #m/#s; //4.5 h of charge
	float V2IChargingRate <- maxBatteryLifeAutonomousBike/(111) #m/#s;  // 111 s battery swapping -> average of the two reported by Fei-Hui Huang 2019 Understanding user acceptancd of battery swapping service of sustainable transport
		
	//--------------------------User Parameters----------------------------
	float maxWaitTimePeople <- 15 #mn;
	float maxDistancePeople_AutonomousBike <- maxWaitTimePeople*DrivingSpeedAutonomousBike #m; //The maxWaitTime is translated into a max radius taking into account the speed of the bikes
    float peopleSpeed <- 5/3.6 #m/#s;
    float RidingSpeedAutonomousBike <-  10.2/3.6;
	
    //--------------------------Package Parameters----------------------------
    float maxWaitTimePackage <- 40 #mn;
	float maxDistancePackage_AutonomousBike <- maxWaitTimePackage*DrivingSpeedAutonomousBike #m;
	 

    
       
    //----------------------Input Files------------------------


	//************* CASE CAMBRIDGE ***************
	//TODO: ADAPT DATE
	
	/*string cityScopeCity <- "Cambridge"; 
	//GIS FILES To Upload - Cambridge
	string cityGISFolder <- "./../includes/City/"+cityScopeCity;
	file bound_shapefile <- file(cityGISFolder + "/Bounds.shp");
	file buildings_shapefile <- file(cityGISFolder + "/Buildings-2.shp");
	file roads_shapefile <- file(cityGISFolder + "/CambridgeRoads.shp");
	//Charging Stations - Cambridge
	csv_file chargingStations_csv <- csv_file(cityGISFolder+ "/bluebikes_stations_cambridge.csv",true);
	
    string cityDemandFolder <- "./../includes/Demand";

    //csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_demand_cambridge_oct7_2019_week.csv",true); 
    csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_week_weekendfirst.csv",true);
    //csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week.csv",true);
    csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week_weekendfirst.csv",true);

    
    //High demand areas for rebalancing
    bool rebalEnabled <- true;
    csv_file food_hotspot_csv <- csv_file (cityDemandFolder+ "/food_top5density.csv",true);
    csv_file user_hotspot_csv <- csv_file (cityDemandFolder+ "/user_top10density.csv",true);*/
	
	
	
 	//************* CASE SAN SEBASTIAN *************** 
 	//TODO: ADAPT DATE
 	
 	string cityScopeCity <- "SanSebastian";
	string cityGISFolder <- "./../../DataSS";
	file bound_shapefile <-file(cityGISFolder + "/boundary/SquareBoundarySS.shp");
	file roads_shapefile <- file(cityGISFolder + "/roads/ss_bike.shp/edges.shp");
	file buildings_shapefile <- file(cityGISFolder + "/buildings/buildings_ss.shp");
	csv_file chargingStations_csv <- csv_file(cityGISFolder+ "/Rides/stations_hexcell.csv",true);
	//csv_file demand_csv <- csv_file (cityGISFolder+ "/Rides/ride_demand_ss_1week_scattered.csv",true); 
	csv_file demand_csv <- csv_file (cityGISFolder+ "/Rides/ride_demand_ss_1week_scattered_fipped.csv",true); 
	//csv_file pdemand_csv <- csv_file (cityGISFolder+ "/Deliveries/delivery_demand_ss_1week_scattered.csv",true);
	csv_file pdemand_csv <- csv_file (cityGISFolder+ "/Deliveries/delivery_demand_ss_flipped_scattered.csv",true);
	bool rebalEnabled <- false;
    csv_file food_hotspot_csv <- csv_file (cityGISFolder+ "/Deliveries/deliveries_ss_top10density.csv",true);
    csv_file user_hotspot_csv <- csv_file (cityGISFolder+ "/Rides/rides_ss_top10density.csv",true);
    
	
	// --------- Layers --------- 
	
	
	// Show Layers
	bool show_building <- true;
	bool show_road <- true;
	bool show_people <- true;
	bool show_chargingStation <- true;
	bool show_package <- true;
	bool show_autonomousBike <- true;			
}	