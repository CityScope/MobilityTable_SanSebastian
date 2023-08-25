model Parameters 

import "./main.gaml" 

global {
	//----------------------Simulation Parameters------------------------
	
	//Simulation time step
	float step <- 2 #sec; //TODO: Change to 2 
	
	//Simulation starting date
	date starting_date <- date("2019-10-07 00:00:00"); 
	
	//Date for log files
	//date logDate <- #now;
	date logDate <- date("2023-08-25 09:00:00");
	
	date nowDate <- #now;
	
	//Duration of the simulation
	int numberOfWeeks <-2; //TODO: Doule check 
	int numberOfDays <- 7; //WARNING: If >1 set numberOfHours to 24h
	int numberOfHours <- 24; //WARNING: If one day, we can also specify the number of hours, otherwise set 24h
	
		
	//----------------------Simulation modes------------------------
	bool peopleEnabled <- true;
	bool packagesEnabled <- true;
	bool biddingEnabled <- true;
	bool dynamicFleetsizing <- false;
	
	//----------------------Logging Parameters------------------------
	bool loggingEnabled <- true parameter: "Logging" category: "Logs";
	bool printsEnabled <- false parameter: "Printing" category: "Logs";
	
	bool autonomousBikeEventLog <- false parameter: "Autonomous Bike Event/Trip Log" category: "Logs";
	
	bool peopleTripLog <-true parameter: "People Trip Log" category: "Logs";
	bool peopleEventLog <-false parameter: "People Event Log" category: "Logs";
	
	bool packageTripLog <-true parameter: "Package Trip Log" category: "Logs";
	bool packageEventLog <-false parameter: "Package Event Log" category: "Logs";
		
	bool stationChargeLogs <- true parameter: "Station Charge Log" category: "Logs";
	
	bool roadsTraveledLog <- false parameter: "Roads Traveled Log" category: "Logs";
	
	//-----------------Autonomous Bike Parameters-----------------------
	int numAutonomousBikes <- 0				min: 0 max: 2000 parameter: "Num Autonomous Bikes:" category: "Bike";
	float maxBatteryLifeAutonomousBike <- 70000.0 #m	min: 10000#m max: 70000#m parameter: "Autonomous Bike Battery Capacity (m):" category: "Bike"; //battery capacity in m
	float DrivingSpeedAutonomousBike <-  8/3.6 #m/#s min: 1/3.6 #m/#s max: 15/3.6 #m/#s parameter: "Autonomous Bike Driving Speed (m/s):" category:  "Bike";
	float minSafeBatteryAutonomousBike <- 0.25*maxBatteryLifeAutonomousBike #m; //Amount of battery at which we seek battery and that is always reserved when charging another bike
	
	
	//-----------------Bidding-----------------------
	int maxBiddingTime <- 0 min:0 max:60 parameter: "Maximum bidding time";
	float pack_bid_ct <- 100.00;
	float pack_bid_dist_coef <- 1/100;
	float pack_bid_queue_coef <- 2.0;
	float person_bid_ct <- 200.00;
	float person_bid_dist_coef <- 1/100;
	float person_bid_queue_coef <- 2.0;
	
	
	//----------------------numChargingStationsion Parameters------------------------
	int chargingStationCapacity <- 16; //Average number of docks in bluebikes stations in April 2022*/
	//float V2IChargingRate <- maxBatteryLifeAutonomousBike/(4.5*60*60) #m/#s; //4.5 h of charge
	float V2IChargingRate <- maxBatteryLifeAutonomousBike/(111) #m/#s;  // 111 s battery swapping -> average of the two reported by Fei-Hui Huang 2019 Understanding user acceptancd of battery swapping service of sustainable transport
		
	//--------------------------People Parameters----------------------------
	
	float maxWaitTimePeople <- 15 #mn		min: 3#mn max: 60#mn parameter: "Max Wait Time People:" category: "People";
	float maxDistancePeople_AutonomousBike <- maxWaitTimePeople*DrivingSpeedAutonomousBike #m; //The maxWaitTime is translated into a max radius taking into account the speed of the bikes
    float peopleSpeed <- 5/3.6 #m/#s	min: 1/3.6 #m/#s max: 10/3.6 #m/#s parameter: "People Speed (m/s):" category: "People";
    float RidingSpeedAutonomousBike <-  10.2/3.6  min: 1/3.6 #m/#s max: 15/3.6 #m/#s parameter: "Autonomous Bike Riding Speed (m/s):" category:  "Bike";
	
    //--------------------------Package Parameters----------------------------
    float maxWaitTimePackage <- 40 #mn		min: 3#mn max: 1440#mn parameter: "Max Wait Time Package:" category: "Package";
	float maxDistancePackage_AutonomousBike <- maxWaitTimePackage*DrivingSpeedAutonomousBike #m;
	 
    //--------------------------Demand Parameters-----------------------------
    string cityDemandFolder <- "./../includes/Demand";

    csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_demand_cambridge_oct7_2019_week.csv",true); 
    //csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_week_weekendfirst.csv",true);
    //csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week.csv",true);
    csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week_weekendfirst.csv",true);
    
    //High demand areas for rebalancing
    bool rebalEnabled <- true;
    csv_file food_hotspot_csv <- csv_file (cityDemandFolder+ "/food_top5density.csv",true);
    csv_file user_hotspot_csv <- csv_file (cityDemandFolder+ "/user_top10density.csv",true);
       
    //----------------------Map Parameters------------------------
	
	//Case - Cambridge
	string cityScopeCity <- "Cambridge";
	string residence <- "R";
	string office <- "O";
	string park <- "P";
	string health <- "H";
	string education <- "E";
	string usage <- "usage";
	
	 map<string, rgb> color_map <- [residence::#silver, office::#silver, "Other"::#silver];  
	
	//GIS FILES To Upload - Cambridge
	string cityGISFolder <- "./../includes/City/"+cityScopeCity;
	file bound_shapefile <- file(cityGISFolder + "/Bounds.shp")			parameter: "Bounds Shapefile:" category: "GIS";
	//file buildings_shapefile <- file(cityGISFolder + "/Buildings.shp")	parameter: "Building Shapefile:" category: "GIS";
	file roads_shapefile <- file(cityGISFolder + "/CambridgeRoads.shp")			parameter: "Road Shapefile:" category: "GIS";
	
	//Charging Stations - Cambridge
	csv_file chargingStations_csv <- csv_file(cityGISFolder+ "/bluebikes_stations_cambridge.csv",true);
	
	//Restaurants - Cambridge
	//csv_file restaurants_csv <- csv_file (cityGISFolder+ "/restaurants_cambridge.csv",true);


	
	
	// Show Layers
	//bool show_building <- true;
	bool show_road <- true;
	bool show_people <- true;
	//bool show_restaurant <- true;
	bool show_chargingStation <- true;
	bool show_package <- true;
	bool show_autonomousBike <- true;			
}	