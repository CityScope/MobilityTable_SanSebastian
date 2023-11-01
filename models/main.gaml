model main 

import "./Agents.gaml" 
import "./Loggers.gaml"
import "./Parameters.gaml"

global {
	//---------------------------------------------------------Performance Measures-----------------------------------------------------------------------------
	//------------------------------------------------------------------Necessary Variables--------------------------------------------------------------------------------------------------

	// GIS FILES
	geometry shape <- envelope(bound_shapefile);
	graph roadNetwork;
	list<int> chargingStationLocation;
	
	
    // ---------------------------------------Agent Creation----------------------------------------------
	init{
    	// ---------------------------------------Buildings-----------------------------i----------------
		do logSetUp;
		
	    //create building from: buildings_shapefile;
	    
		// ---------------------------------------The Road Network----------------------------------------------
		create road from: roads_shapefile;
		
		roadNetwork <- as_edge_graph(road) ;
		
					   
		// -------------------------------------Location of the charging stations----------------------------------------   
		
		
		create chargingStation from: chargingStations_csv with:
			[lat::float(get("Latitude")),
			lon::float(get("Longitude")),
			capacity::int(get("Total docks"))
			]
			{
				location <- to_GAMA_CRS({lon,lat},"EPSG:4326").location;
			 	chargingStationCapacity <- chargingStationCapacity;
			}
			
		// -------------------------------------------The Bikes -----------------------------------------
		
		
		create autonomousBike number:numAutonomousBikes{					
			location <- point(one_of(roadNetwork.vertices));
			batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
		}
		
		
		int week <-0; //Start from week 0
		
	    loop times: numberOfWeeks{//Loop over the number of weeks, because the dataset is one week
	    	
	    	// -------------------------------------------The Packages -----------------------------------------
			if packagesEnabled{create package from: pdemand_csv with:
			[start_hour::date(get("start_time")),
					start_lat::float(get("start_latitude")),
					start_lon::float(get("start_longitude")),
					target_lat::float(get("end_latitude")),
					target_lon::float(get("end_longitude")),
					start_d::int(get("day"))
			]{
				
				start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location;
				target_point  <- to_GAMA_CRS({target_lon,target_lat},"EPSG:4326").location;
				location <- start_point;
				
				if (cityScopeCity = "SanSebastian") {
					start_day <- start_d;
					
				} else{
					start_day <- start_d + 6;	
				}
				
				start_day <- week*7 + start_day; //Add days depending on week number
				write  'week '+ week + ' day '+(start_day);
				write 'current '+ (current_date.day);
				
				string start_h_str <- string(start_hour,'kk');
				start_h <-  int(start_h_str);
				if start_h = 24 {
					start_h <- 0;
				}
				string start_min_str <- string(start_hour,'mm');
				start_min <- int(start_min_str);
				

			}}
			
			// -------------------------------------------The People -----------------------------------------
		    if peopleEnabled{create people from: demand_csv with:
			[start_hour::date(get("starttime")), //'yyyy-MM-dd hh:mm:s'
					start_lat::float(get("start_lat")),
					start_lon::float(get("start_lon")),
					target_lat::float(get("target_lat")),
					target_lon::float(get("target_lon"))
				]{
	
		        speed <- peopleSpeed;
		        start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location; // (lon, lat) var0 equals a geometry corresponding to the agent geometry transformed into the GAMA CRS
				target_point <- to_GAMA_CRS({target_lon,target_lat},"EPSG:4326").location;
				location <- start_point;
				
				
				string start_day_str <- string(start_hour, 'dd');
				if (cityScopeCity = "SanSebastian") {
					start_day <- int(start_day_str) -18;
					
				} else{
					start_day <- int(start_day_str);	
				}
					
				
				start_day <- week*7 + start_day; //Add days depending on week number

				
				string start_h_str <- string(start_hour,'kk');
				start_h <- int(start_h_str);
				string start_min_str <- string(start_hour,'mm');
				start_min <- int(start_min_str);
				
				
				}}
			
			week <- week +1; //Update week for next loop
		}    
		
			
			//Create hotspots for rebalancing
	 		create foodhotspot from: food_hotspot_csv with:[
	 			lat::float(get("center_y")),
	 			lon::float(get("center_x")),
	 			dens::int(get("density"))
	 		]{
	 			
	 			location  <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
	 		}
	 		
	 		
	 		create userhotspot from: user_hotspot_csv with:[
	 			lat::float(get("center_y")),
	 			lon::float(get("center_x")),
	 			dens::int(get("density"))
	 		]{
	 			
	 			location  <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
	 		}
	 		
	 					
			write "FINISH INITIALIZATION";
    }
    
	reflex stop_simulation when: cycle >=  numberOfWeeks *numberOfDays * numberOfHours * 3600 / step {
		do pause ;
	}

	
	
	
}

experiment numreps_fleetSizing type: batch repeat: 19 parallel: 19 until: (cycle >= numberOfWeeks * numberOfDays * numberOfHours * 3600 / step){
	
	parameter var: step init: 5.0 #sec;

	parameter var: rebalEnabled init: true; 
	
	parameter var: numAutonomousBikes among: [337,337];
	//CAMBRIDGE: Food only 164, users only 86, both 217 
	//DONOSTI: Food only 81, User only 95, both 119
	
	parameter var: dynamicFleetsizing init: false; //TODO: REMEMBER to adapt weekendfirst or not!
	
	parameter var: peopleEnabled init: true;//TODO: REMEMBER to adapt weekendfirst or not!
	parameter var: packagesEnabled init: true; 
	parameter var: biddingEnabled init: true;
	
	parameter var: loggingEnabled init: true;
	parameter var: autonomousBikeEventLog init: true; 
	parameter var: peopleTripLog init: true; 
	parameter var: packageTripLog init: true; 
	parameter var: stationChargeLogs init: false; 
	
	
}




experiment multifunctionalVehiclesVisual type: gui {

	//parameter var: starting_date init: date("2019-10-01 9:00:00");
	
	parameter var: step init: 15.0#sec;
	
	parameter var: numAutonomousBikes init: 81;
	parameter var: dynamicFleetsizing init: true;
	
	parameter var: rebalEnabled init:true;
	parameter var: peopleEnabled init:false;
	parameter var: packagesEnabled init:true;
	parameter var: biddingEnabled init: false;
	
	parameter var: loggingEnabled init: true;
	parameter var: autonomousBikeEventLog init: true; 
	parameter var: peopleTripLog init: true; 
	parameter var: packageTripLog init: true; 
	parameter var: stationChargeLogs init: false; 
	
	
    output {
		display multifunctionalVehiclesVisual type:opengl background: #black axes: false{	 
			//species building aspect: type visible: show_building position:{0,0,-0.001};
		
			//grid cell border: #black;
			species road aspect: base visible:show_road;
			//species building aspect: type visible: show_building;
			species people aspect: base visible:show_people;
			species chargingStation aspect: base visible:show_chargingStation ;
			//species autonomousBike aspect: realistic visible:show_autonomousBike trace:30 fading: true position:{0,0,0.001};
			species autonomousBike aspect: realistic visible:show_autonomousBike position: {0,0,0.001}  trace: 5 fading: true ;
			species package aspect:base visible:show_package;
			species userhotspot aspect:base;
			species foodhotspot aspect: base;
			
			

			event "b" {show_building<-!show_building;}
			event "r" {show_road<-!show_road;}
			event "p" {show_people<-!show_people;}
			event "s" {show_chargingStation<-!show_chargingStation;}
			event "d" {show_package<-!show_package;}
			event "a" {show_autonomousBike<-!show_autonomousBike;}
			
			graphics Strings{
			list date_time <- string(current_date) split_with (" ",true);
			string day <- string(current_date.day);
			draw ("Day"+ day + " " + date_time[1]) at: {15000, 5000} color: #white font: font("Helvetica", 30, #bold);

				
			}
		}
		
		
    }
}

experiment param_search type: batch repeat: 15 parallel: 15 keep_seed: true until: (cycle >= numberOfWeeks * numberOfDays * numberOfHours * 3600 / step) {

	//TODO: adapt for the most critical day
	
	parameter var: numberOfDays init: 1; 
	
	parameter var: step init: 5.0#sec;
	
	parameter var: numAutonomousBikes init: 337; //TODO: Set final 
	parameter var: dynamicFleetsizing init: false; 
	
	
	parameter var: rebalEnabled init:true;
	parameter var: peopleEnabled init:true;
	parameter var: packagesEnabled init:true;
	parameter var: biddingEnabled init: true;
	
	parameter var: loggingEnabled init: true;
	parameter var: autonomousBikeEventLog init: false; 
	parameter var: peopleTripLog init: true; 
	parameter var: packageTripLog init: true; 
	parameter var: stationChargeLogs init: false; 

	//method exploration from:"./../includes/w_params.csv";
	
	method exploration with: [
	 // ["maxBiddingTime"::0, "w_urgency"::0.0, "w_wait"::0.0, "w_proximity"::0.0], //REF with nobid
	  ["maxBiddingTime"::0.5, "w_urgency"::0.0, "w_wait"::0.0, "w_proximity"::1.0],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.0, "w_wait"::0.25, "w_proximity"::0.75],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.0, "w_wait"::0.5, "w_proximity"::0.5],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.0, "w_wait"::0.75, "w_proximity"::0.25],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.0, "w_wait"::1.0, "w_proximity"::0.0],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.25, "w_wait"::0.0, "w_proximity"::0.75],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.25, "w_wait"::0.25, "w_proximity"::0.5],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.25, "w_wait"::0.5, "w_proximity"::0.25],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.25, "w_wait"::0.75, "w_proximity"::0.0],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.5, "w_wait"::0.0, "w_proximity"::0.5],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.5, "w_wait"::0.25, "w_proximity"::0.25],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.5, "w_wait"::0.5, "w_proximity"::0.0],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.75, "w_wait"::0.0, "w_proximity"::0.25],
	  ["maxBiddingTime"::0.5, "w_urgency"::0.75, "w_wait"::0.25, "w_proximity"::0.0],
	  ["maxBiddingTime"::0.5, "w_urgency"::1.0, "w_wait"::0.0, "w_proximity"::0.0]
	];
	
	/*method exploration with: [
	  ["maxBiddingTime"::1, "w_urgency"::0.0, "w_wait"::0.0, "w_proximity"::1.0],
	  ["maxBiddingTime"::1, "w_urgency"::0.0, "w_wait"::0.25, "w_proximity"::0.75],
	  ["maxBiddingTime"::1, "w_urgency"::0.0, "w_wait"::0.5, "w_proximity"::0.5],
	  ["maxBiddingTime"::1, "w_urgency"::0.0, "w_wait"::0.75, "w_proximity"::0.25],
	  ["maxBiddingTime"::1, "w_urgency"::0.0, "w_wait"::1.0, "w_proximity"::0.0],
	  ["maxBiddingTime"::1, "w_urgency"::0.25, "w_wait"::0.0, "w_proximity"::0.75],
	  ["maxBiddingTime"::1, "w_urgency"::0.25, "w_wait"::0.25, "w_proximity"::0.5],
	  ["maxBiddingTime"::1, "w_urgency"::0.25, "w_wait"::0.5, "w_proximity"::0.25],
	  ["maxBiddingTime"::1, "w_urgency"::0.25, "w_wait"::0.75, "w_proximity"::0.0],
	  ["maxBiddingTime"::1, "w_urgency"::0.5, "w_wait"::0.0, "w_proximity"::0.5],
	  ["maxBiddingTime"::1, "w_urgency"::0.5, "w_wait"::0.25, "w_proximity"::0.25],
	  ["maxBiddingTime"::1, "w_urgency"::0.5, "w_wait"::0.5, "w_proximity"::0.0],
	  ["maxBiddingTime"::1, "w_urgency"::0.75, "w_wait"::0.0, "w_proximity"::0.25],
	  ["maxBiddingTime"::1, "w_urgency"::0.75, "w_wait"::0.25, "w_proximity"::0.0],
	  ["maxBiddingTime"::1, "w_urgency"::1.0, "w_wait"::0.0, "w_proximity"::0.0],
	  ["maxBiddingTime"::2, "w_urgency"::0.0, "w_wait"::0.0, "w_proximity"::1.0],
	  ["maxBiddingTime"::2, "w_urgency"::0.0, "w_wait"::0.25, "w_proximity"::0.75],
	  ["maxBiddingTime"::2, "w_urgency"::0.0, "w_wait"::0.5, "w_proximity"::0.5],
	  ["maxBiddingTime"::2, "w_urgency"::0.0, "w_wait"::0.75, "w_proximity"::0.25],
	  ["maxBiddingTime"::2, "w_urgency"::0.0, "w_wait"::1.0, "w_proximity"::0.0],
	  ["maxBiddingTime"::2, "w_urgency"::0.25, "w_wait"::0.0, "w_proximity"::0.75],
	  ["maxBiddingTime"::2, "w_urgency"::0.25, "w_wait"::0.25, "w_proximity"::0.5],
	  ["maxBiddingTime"::2, "w_urgency"::0.25, "w_wait"::0.5, "w_proximity"::0.25],
	  ["maxBiddingTime"::2, "w_urgency"::0.5, "w_wait"::0.0, "w_proximity"::0.5],
	  ["maxBiddingTime"::2, "w_urgency"::0.5, "w_wait"::0.25, "w_proximity"::0.25],
	  ["maxBiddingTime"::2, "w_urgency"::0.5, "w_wait"::0.5, "w_proximity"::0.0],
	  ["maxBiddingTime"::2, "w_urgency"::0.75, "w_wait"::0.0, "w_proximity"::0.25],
	  ["maxBiddingTime"::2, "w_urgency"::0.75, "w_wait"::0.25, "w_proximity"::0.0],
	  ["maxBiddingTime"::2, "w_urgency"::1.0, "w_wait"::0.0, "w_proximity"::0.0]	  

	];*/

}


/*experiment stochast type: batch repeat: 40 keep_simulations: false until: (cycle >= numberOfWeeks * numberOfDays * numberOfHours * 3600 / step){
	
	parameter var: step init: 30.0#sec;
	
	parameter var: rebalEnabled init: true; 
	
	parameter var: numAutonomousBikes init: 217;
	//Food only 164, users only 86, both 217 
	parameter var: dynamicFleetsizing init: true;
	
	parameter var: peopleEnabled init: true;
	parameter var: packagesEnabled init: true;
	parameter var: biddingEnabled init: false;
	
	parameter var: loggingEnabled init: false;
	parameter var: autonomousBikeEventLog init: false; 
	parameter var: peopleTripLog init: false; 
	parameter var: packageTripLog init: false; 
	parameter var: stationChargeLogs init: false; 
	
	
	method stochanalyse outputs:["numAutonomousBikes"] report: './../results/' + string(logDate, 'yyyy-MM-dd hh.mm.ss','en') +"results_stochanalysis.txt" sample:3;
}*/

/*experiment Benchmarking type: gui benchmark: true {
	parameter var: step init: 5.0#sec;
	
	parameter var: rebalEnabled init: true; 
	
	parameter var: numAutonomousBikes init: 217;
	//Food only 164, users only 86, both 217 
	parameter var: dynamicFleetsizing init: true;
	
	parameter var: peopleEnabled init: true;
	parameter var: packagesEnabled init: true;
	parameter var: biddingEnabled init: false;
	
	parameter var: numberOfWeeks init: 1;
	parameter var: numberOfDays init: 1;
	//save to: './../results/' + string(logDate, 'yyyy-MM-dd hh.mm.ss','en'); 
}*/




