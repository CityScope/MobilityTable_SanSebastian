model main 

import "./Agents.gaml" 
import "./Loggers.gaml"
import "./Parameters.gaml"

global {
	
	//Init bounds and roadNetwork
	geometry shape <- envelope(bound_shapefile);
	graph roadNetwork; 
	
    // ---------------------------------------Agent Creation----------------------------------------------
	init{
		do logSetUp;
    	// ---------------------------------------Buildings--------------------------------------------
	    //create building from: buildings_shapefile;
	    
		// ---------------------------------------The Road Network----------------------------------------------

		create road from: roads_shapefile;
		
		roadNetwork <- as_edge_graph(road) ;
		
					   
		// -------------------------------------Charging stations----------------------------------------   
		
	
		//Create hotspots for rebalancing - food deliveries
 		create chargingStation from: chargingStations_csv with:[
 			lat::float(get("center_y")),
 			lon::float(get("center_x"))
 		]{
 			point loc  <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
 			location <- roadNetwork.vertices closest_to(loc);
 			chargingStationCapacity <- stationCapacity;
 		}
	
		// -------------------------------------------The Bikes -----------------------------------------
		
		
		create autonomousBike number:numAutonomousBikes{					
			location <- point(one_of(roadNetwork.vertices)); //Random location in network
			batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
		}
		
    	
    	// -------------------------------------------The Packages -----------------------------------------
		/*if packagesEnabled{create package from: pdemand_csv with:
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
			
			
			string start_h_str <- string(start_hour,'kk');
			start_h <-  int(start_h_str);
			if start_h = 24 {
				start_h <- 0;
			}
			string start_min_str <- string(start_hour,'mm');
			start_min <- int(start_min_str);
			

		}}*/
		
		// -------------------------------------------The People -----------------------------------------
	    if peopleEnabled{create people from: demand_csv with:
		[start_hour::date(get("starttime")), 
				start_lat::float(get("start_lat")),
				start_lon::float(get("start_lon")),
				target_lat::float(get("target_lat")),
				target_lon::float(get("target_lon"))
			]{

	        speed <- peopleSpeed;
	        start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location; 
			target_point <- to_GAMA_CRS({target_lon,target_lat},"EPSG:4326").location;
			location <- start_point;
			
			
			string start_day_str <- string(start_hour, 'dd');
			//Change day so that the first is day 1
			start_day <- int(start_day_str) -18;
		
				

			
			string start_h_str <- string(start_hour,'kk');
			start_h <- int(start_h_str);
			string start_min_str <- string(start_hour,'mm');
			start_min <- int(start_min_str);
			
			
			}}
	   
		
			
			//Create hotspots for rebalancing - food deliveries
	 		/*create foodhotspot from: food_hotspot_csv with:[
	 			lat::float(get("center_y")),
	 			lon::float(get("center_x")),
	 			dens::int(get("density"))
	 		]{
	 			
	 			location  <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
	 		}*/
	 		
	 		//Create hotspots for rebalancing -  user rides
	 		create userhotspot from: user_hotspot_csv with:[
	 			lat::float(get("center_y")),
	 			lon::float(get("center_x")),
	 			dens::int(get("density"))
	 		]{
	 			
	 			location  <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
	 		}
	 		
	 					
			write "FINISH INITIALIZATION";
    }
    
    //Stop simulation when specified time is over
	reflex stop_simulation when: cycle >=  numberOfDays * numberOfHours * 3600 / step {
		do pause ;
	}
	
}



//--------------------------------- VISUAL EXPERIMENT----------------------------------

experiment multifunctionalVehiclesVisual type: gui {

	//Defining parameter values - some overwrite their default values saved in Paramters.gaml
	
	parameter var: starting_date init: date("2019-10-01 07:00:00"); //Just to see some activity when launching it- easier for debugging
	
	parameter var: step init: 15.0#sec; //If you reduce it the simulation will be smoother but slower
	parameter var: numberOfDays  init: 1; //I think this will be Monday, we need to decide which day to simulate
	//TODO: If we're just keeping one day, we can import a csv with just one day of demand 
	parameter var: numAutonomousBikes init: 300;

	//Defining visualization
    output {
		display multifunctionalVehiclesVisual type:opengl background: #black axes: false{	 
			
			//Define species and aspect
			species road aspect: base visible:show_road position: {0,0,-0.001};
			//species building aspect: type visible: show_building;
			species autonomousBike aspect: realistic visible:show_autonomousBike trace: 7 fading: true ;
			species people aspect: base visible:show_people;
			species chargingStation aspect: base visible:show_chargingStation ;
			species package aspect:base visible:show_package;
			
			//Dynamic show/hide of layers when buttons are pressed
			//event "b" {show_building<-!show_building;}
			event "r" {show_road<-!show_road;}
			event "p" {show_people<-!show_people;}
			event "s" {show_chargingStation<-!show_chargingStation;}
			event "d" {show_package<-!show_package;}
			event "a" {show_autonomousBike<-!show_autonomousBike;}
			
			//Showing simulation day and time
			graphics Strings{
			list date_time <- string(current_date) split_with (" ",true);
			string day <- string(current_date.day);
			draw ("Day"+ day + " " + date_time[1]) at: {7000, 5000} color: #white font: font("Helvetica", 30, #bold);

				
			}
		}
		
		
    }
}



