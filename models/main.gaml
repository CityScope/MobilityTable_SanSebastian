model main 

import "./Agents.gaml" 
import "./Parameters.gaml"

global {
	//Init bounds and roadNetwork
	geometry shape <- envelope(bound_shapefile);
	graph roadNetwork; 
	
	//LISTA PARA IR ACTUALIZANDO LOS VALORES
	 list avgWait_plot <- list_with(8652, 0);
	 list time_plot <- list_with(8652, 0);	 
	 list limitwait_plot <- list_with(8652, 0);
	 //no se como hacer para que no salte el 3 en el principio del experimento limitwait_plot[0] <- 3;	 
     list wanderCountBike_plot <- list_with(8652, 0);
     list inUseCountBike_plot <- list_with(8652, 0);
     list getChargeCountBike_plot <- list_with(8652, 0);
	 list pickUpCountBike_plot <- list_with(8652, 0);
	 list biddingCount_plot <- list_with(8652, 0);
	 list endbidCount_plot <- list_with(8652, 0);
	 list suma_plot <- list_with(8652, 0);
	 
	 
    // ---------------------------------------Agent Creation----------------------------------------------

	init {
    	// ---------------------------------------Buildings--------------------------------------------
	    //create building from: buildings_shapefile;
	    
		// ---------------------------------------The Road Network----------------------------------------------
		create road from: roads_shapefile;
		roadNetwork <- as_edge_graph(road);
		
		// -------------------------------------Charging stations----------------------------------------   
		//Create hotspots for rebalancing - food deliveries
 		create chargingStation from: chargingStations_csv with: [
 			lat::float(get("center_y")),
 			lon::float(get("center_x"))
 		] {
 			point loc <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
 			location <- roadNetwork.vertices closest_to(loc);
 			chargingStationCapacity <- stationCapacity;
 		}
	
		// -------------------------------------------The Bikes -----------------------------------------
		create autonomousBike number: numAutonomousBikes {					
			location <- point(one_of(roadNetwork.vertices)); //Random location in network
			batteryLife <- rnd(minSafeBatteryAutonomousBike, maxBatteryLifeAutonomousBike); // Battery life random between max and min
		}

		// -------------------------------------------The People -----------------------------------------
	    if peopleEnabled {
			create people from: demand_csv with: [
				start_hour::date(get("starttime")), 
				start_lat::float(get("start_lat")),
				start_lon::float(get("start_lon")),
				target_lat::float(get("target_lat")),
				target_lon::float(get("target_lon"))
			] {
		        speed <- peopleSpeed;
		        start_point <- to_GAMA_CRS({start_lon, start_lat}, "EPSG:4326").location; 
				target_point <- to_GAMA_CRS({target_lon, target_lat}, "EPSG:4326").location;
				location <- start_point;
				
				string start_day_str <- string(start_hour, 'dd');
				start_day <- int(start_day_str) - 18;
				
				string start_h_str <- string(start_hour, 'kk');
				start_h <- int(start_h_str);
				string start_min_str <- string(start_hour, 'mm');
				start_min <- int(start_min_str);
			}
		}
			
		//Create hotspots for rebalancing - user rides
	 	create userhotspot from: user_hotspot_csv with: [
	 		lat::float(get("center_y")),
	 		lon::float(get("center_x")),
	 		dens::int(get("density"))
	 	] {
	 		location <- to_GAMA_CRS({lon, lat}, "EPSG:4326").location; 
	 	}
		
		write "FINISH INITIALIZATION";
		initial_hour <- current_date.hour;
		initial_minute <- current_date.minute;
		
// -------------------------------------------Update Values from Plots -----------------------------------------
		
    }
     reflex updateValue{

        if (cycle > 8652)
        {
            remove first(avgWait_plot) from: avgWait_plot;
            remove first(time_plot) from: time_plot;
            remove first(limitwait_plot) from: limitwait_plot;
            remove first(wanderCountBike_plot) from: wanderCountBike_plot;
            remove first(getChargeCountBike_plot) from: getChargeCountBike_plot;
 		    remove first(pickUpCountBike_plot) from: pickUpCountBike_plot;
            remove first(biddingCount_plot) from: biddingCount_plot;
            remove first(endbidCount_plot) from: endbidCount_plot;
            remove first(inUseCountBike_plot) from: inUseCountBike_plot;
            remove first(suma_plot) from: suma_plot;
            
        }
        add avgWait to: avgWait_plot;
        add current_date.hour to: time_plot;
        add 15 to: limitwait_plot;
        add wanderCountbike to: wanderCountBike_plot;
        add getChargeCount to: getChargeCountBike_plot;
        add pickUpCountBike to: pickUpCountBike_plot;
        add biddingCount to: biddingCount_plot;
        add endbidCount to: endbidCount_plot;
        add inUseCountBike to: inUseCountBike_plot;
        add inUseCountBike +  endbidCount + biddingCount + pickUpCountBike to: suma_plot;
        
        /*if (cycle < 8652) {	
			add avgWait to: avgWait_plot;
			add current_date.hour to: time_plot;
			add 40 to: limitwait_plot;

		} else{
			remove first(avgWait_plot) from: avgWait_plot;
			remove first(time_plot) from: time_plot;
			add avgWait to: avgWait_plot;
			add current_date.hour to: time_plot;
		}*/

    }
    //Stop simulation when specified time is over
	reflex stop_simulation when: cycle >= numberOfDays * numberOfHours * 3600 / step {
		do pause;
	}
}



//--------------------------------- VISUAL EXPERIMENT----------------------------------

experiment multifunctionalVehiclesVisual type: gui {

	//Defining parameter values - some overwrite their default values saved in Paramters.gaml
	parameter var: starting_date init: date("2019-10-01 07:00:00");
	parameter var: step init: 15.0#sec;
	parameter var: numberOfDays init: 1;
	parameter var: numAutonomousBikes init: 300;

	//Defining visualization
    output {
		display multifunctionalVehiclesVisual type: opengl background: #black axes: false {	 
			//Define species and aspect
			species road aspect: base visible: show_road position: {0, 0, -0.001};
			species autonomousBike aspect: realistic visible: show_autonomousBike trace: 7 fading: true;
			species people aspect: base visible: show_people;
			species chargingStation aspect: base visible: show_chargingStation;
			
			//Dynamic show/hide of layers when buttons are pressed
			event "r" {show_road <- !show_road;}
			event "p" {show_people <- !show_people;}
			event "s" {show_chargingStation <- !show_chargingStation;}
			event "d" {show_package <- !show_package;}
			event "a" {show_autonomousBike <- !show_autonomousBike;}
			
			//Showing simulation day and time
			graphics Strings {
				list date_time <- string(current_date) split_with (" ", true);
				string day <- string(current_date.day);
				draw ("Day " + day + " " + date_time[1]) at: {7000, 5000} color: #white font: font("Helvetica", 30, #bold);
			}
		}
		
		display dashboard antialias: false type: java2D fullscreen: 0 background: #black { 
			graphics Strings {
				draw "MULTIFUNCTIONALVEHICLESVISUAL GRAPHS OSCAR" at: {200, 160} color: #white font: font("Helvetica", 23, #bold);
				draw rectangle(3650, 2) at: {1880, 200};
				
			draw "Average Waiting Time" at: {1250, 320
			} color: #white font: font("Helvetica", 20, #bold);

			// Leyenda de las líneas
			draw line([{200, 360}, {250, 360}]) color: #red;  // Línea roja
			draw "15 minutes" at: {270, 360} color: #white font: font("Helvetica", 12, #bold);
			draw line([{200, 450}, {250, 450}]) color: #pink;  // Línea rosa
			draw "Wait Time" at: {270, 450} color: #white font: font("Helvetica", 12, #bold);
			}
				chart "Average Wait Time" type: series background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,20] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: time_plot x_tick_unit: 721 memorize: false position: {550, 800} size: {2450, 800} series_label_position: none {
				data "Wait Time" value: avgWait_plot color: #pink marker: false style: line;
				data "15 min" value: limitwait_plot color: #red marker: false style: line;
				
			}
			//COMPLETED TRIPS
			graphics Strings {
			draw "Completed Trips" at: {3000, 700} color: #white font: font("Helvetica", 15, #bold) ;
			if deliverycount = 0{
				foodwastecolor <- #blue;
					} else {
						foodwastecolor <- #palegreen;
					}
			draw ellipse(430,230) at: {3275, 875} color: foodwastecolor;
			draw "" + deliverycount at: {3200,925} color: #black font:(font("Helvetica",30,#bold));
			}
			//UNSERVED TRIPS
			graphics Strings {
   		    draw "UnservedTrips" at: {3000, 1200} color: #white font: font("Helvetica", 15, #bold);
    		if unservedcount = 0 {
      		  foodwastecolor <- #blue;
   				} else {
       		 		foodwastecolor <- #red;
   			    }
  			draw ellipse(430, 230) at: {3275, 1350} color: foodwastecolor;
 		    draw "" + unservedcount at: {3200, 1400} color: #black font: (font("Helvetica", 30, #bold));
			}
			
				graphics Strings {
				draw "People Average Wait Time [min]" rotate: 270 at: {130, 1075} color: #white font: font("Helvetica", 10, #bold);
				list date_time <- string(current_date) split_with (" ",true);
				draw ("" + date_time[1]) at: {2550, 700} color: #white font: font("Helvetica", 10, #bold);
				draw "Time of the Day" at: {1600, 1700} color: #white font: font("Helvetica", 10, #bold);
			}
			graphics Strings {
    		draw "Vehicle Tasks" at: {1500, 1850} color: #white font: font("Helvetica", 20, #bold);
							 }

			chart "Vehicle Tasks" type: series background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,400] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: time_plot  x_tick_unit: 721 memorize: false position: {550, 1900} size: {2450, 800} series_label_position: none {
    		data "Vehicles Charging" value: getChargeCountBike_plot color: #pink marker: false style: line;
    		data "Vehicles Idling" value: wanderCountBike_plot color: #orange marker: false style: line;
    		data "Vehicles Occupied" value: suma_plot color: #skyblue marker: false style: line;
    		//data "Vehicles in Use" value: inUseCountBike color: #orange marker: false style: line;
			}
				graphics Strings {	
    			draw line([{3100, 1760}, {3150, 1760}]) color: #pink;
   			    draw "Vehicles Charging" at: {3170, 1760} color: #white font: font("Helvetica", 12, #bold);
   				draw line([{3100, 1850}, {3150, 1850}]) color: #orange;
    			draw "Vehicles Idling" at: {3170, 1850} color: #white font: font("Helvetica", 12, #bold);
    			draw line([{3100, 1940}, {3150, 1940}]) color: #skyblue;
    			draw "Vehicles Occupied" at: {3170, 1940} color: #white font: font("Helvetica", 12, #bold);
								 }
							}
    					}
					}		



