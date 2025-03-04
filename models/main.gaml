//ÚLTIMA MODIFICACIÓN 11 DE Febrero

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
	 
     list wanderCountBike_plot <- list_with(8652, 0);
     list inUseCountBike_plot <- list_with(8652, 0);
     list getChargeCountBike_plot <- list_with(8652, 0);
	 list pickUpCountBike_plot <- list_with(8652, 0);
	 list biddingCount_plot <- list_with(8652, 0);
	 list endbidCount_plot <- list_with(8652, 0);
	 list suma_plot <- list_with(8652, 0);
	 
	 int stationCount;
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
 		
 		
 		//TODO: Update REGULAR station
 		create station from: chargingStations_csv with: [
 			lat::float(get("center_y")),
 			lon::float(get("center_x"))
 		] {
 			point loc <- to_GAMA_CRS({lon,lat},"EPSG:4326").location;
 			location <- roadNetwork.vertices closest_to(loc); 			 
 			capacity <- stationCapacity;
 			stationCount <- stationCount + 1;
 		}
		//TODO: create Regular Bikes
	
		create regularBike number: numRegularBikes {	
			//REVISAR	
			/*list<station> estaciones_huecos <- station where each.SpotsAvailableStation();	
			if empty(estaciones_huecos) {
				write "Hay mas bicis que huecos";
			}
			location <- point(one_of(estaciones_huecos)); //Location in a station*/
			batteryLife <- rnd(minSafeBatteryAutonomousBike, maxBatteryLifeAutonomousBike); // Battery life random between max and min
			totalCountRB<-numRegularBikes;
		}
		// -------------------------------------------The Bikes -----------------------------------------
		create autonomousBike number: numAutonomousBikes {					
			location <- point(one_of(roadNetwork.vertices)); //Random location in network
			batteryLife <- rnd(minSafeBatteryAutonomousBike, maxBatteryLifeAutonomousBike); // Battery life random between max and min
			totalCount<-numAutonomousBikes;
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
	
	reflex create_autonomousBikes when: autonomousScenario and totalCount < numAutonomousBikes{ 
		write "number: " + numAutonomousBikes;
			create autonomousBike number: (numAutonomousBikes - totalCount){
				location <- point(one_of(roadNetwork.vertices));
				batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike);
				totalCount <- totalCount +1;
		}
		//si me está creando bicicletas pero no me las está quitando.
		write "count: " + totalCount;
	}
	
	reflex create_regularBikes when: !autonomousScenario and totalCountRB < numRegularBikes{ 
		write "number of regular bikes: " + numRegularBikes;
			create regularBike number: (numRegularBikes - totalCountRB){
				//location <- point(one_of(roadNetwork.vertices));
				//batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike);
				totalCountRB <- totalCountRB +1; 
		}
		write "count: " + totalCountRB;
		
	}
	 
	/*	reflex reset_unserved_counter when: ((initial_ab_number != numAutonomousBikes) or (initial_ab_battery != maxBatteryLifeAutonomousBike) or (initial_ab_speed != RidingSpeedAutonomousBike) or (initial_ab_recharge_rate != V2IChargingRate)){ 
		initial_ab_number <- numAutonomousBikes;
		initial_ab_battery <- maxBatteryLifeAutonomousBike;
		initial_ab_speed <- RidingSpeedAutonomousBike;
		initial_ab_recharge_rate <- V2IChargingRate;
		unservedcount <- 0;
	}*/
		reflex reset_demand when: ((current_date.hour = 0 and current_date.minute = 0 and current_date.second = 0) and cycle != 0) {
		
		//x_min_value <- cycle;
		//x_max_value <- x_min_value + 9360;
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
			
		//totalCount <- 0;
		initial_hour <- 0;
		initial_minute <- 0;
	}
}
 


//--------------------------------- VISUAL EXPERIMENT----------------------------------

experiment multifunctionalVehiclesVisual type: gui {
	int x_val<-100;
	int x_step <- 300;
	int y_val <- 6000;
	int y_step <- 150;


	//Defining parameter values - some overwrite their default values saved in Paramters.gaml
	parameter var: starting_date init: date("2019-10-01 07:28:00");
	parameter var: step init: 5.0#sec;
	parameter var: numberOfDays init: 1;
	parameter var: numAutonomousBikes init: 300;
	parameter var: numRegularBikes init: 300;

	//Defining visualization
    output {
		display multifunctionalVehiclesVisual type: opengl background: #black axes: false {	 
			
			//Define species and aspect			
			species road aspect: base visible:show_road refresh: false;
			species station aspect: base visible:(!autonomousScenario and show_station) position:{0.0,0.0,0.004};
			species chargingStation aspect:base visible:(autonomousScenario and show_chargingStation) position:{0.0,0.0,0.004};
			//species restaurant aspect:base visible:show_restaurant;
			species autonomousBike aspect: realistic visible:(autonomousScenario and show_autonomousBike) trace:5 fading: true position:{0.0,0.0,0.001};
			species regularBike aspect: realistic visible:(!autonomousScenario and show_regularBike) trace:5 fading: true position:{0.0,0.0,0.001}; 
			species people aspect: base visible:show_people transparency: 0 position:{0.0,0.0,0.005};
			
			//Dynamic show/hide of layers when buttons are pressed
			event "r" {show_road <- !show_road;}
			event "p" {show_people <- !show_people;}
			event "s" {show_chargingStation <- !show_chargingStation;}
			event "s" {show_station <- !show_station;}			
			event "a" {show_autonomousBike <- !show_autonomousBike;}
			event "a" {show_regularBike <- !show_regularBike;}
			
			//Showing simulation day and time
			graphics Strings {
				list date_time <- string(current_date) split_with (" ", true);
				string day <- string(current_date.day);
				draw ("Day " + day + " " + date_time[1]) at: {7000, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 30, #bold);
							}
			graphics Strings {
				if autonomousScenario{
						//AUTONOMOUS BIKE WANDERING 
				    	draw "Donostia / San Sebastián" at: {x_val + x_step * 4 + 1200, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 55 , #bold);	
				    		
						//AUTONOMOUS BIKE WANDERING 
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 1.5 - 530} color: (#cyan-200) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 1.5 - 530} color: (#cyan-150) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 1.5 - 530} color: (#cyan-100) rotate: 90;
				    	draw "Autonomous Bike Wandering" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
					
						//AUTONOMOUS BIKE PICHING UP
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-200 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-150 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-100 rotate: 90;
				    	draw "Autonomous Bike (Trip)" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				
						//LOW CHARGE
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 3.5 - 220} color: #red rotate: 90;
				    	draw "Low Charge/Getting Charge" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 3.5 - 220} color: #white font: font("Helvetica", 20, #bold);
					
						//CHARGING STATION (SEGUNDA COLUMNA)
				    	draw hexagon(90) at: {x_val + x_step * 10 + 1850, y_val + y_step * 2.5 - 380} color: #darkorange;
				    	draw "Charging Station" at: {x_val + x_step * 10 + 130 + 1850, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
					
						//PEOPLE (TERCELA COLUMNA)
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 2350, y_val + y_step * 2.5 - 380} color: #mediumslateblue;
				    	draw "people (trip)" at: {x_val + x_step * 14 + 190 + 2350, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				    	
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 2350, y_val + y_step * 3.5 - 220} color: #orange;
				    	draw "people (waiting/picking bike)" at: {x_val + x_step * 14 + 190 + 2350, y_val + y_step * 3.5 - 220} color: #white font: font("Helvetica", 20, #bold);
				    	
					
						// SCENARIO BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 130 + 1000 + 150 - 300 - 100, y_val + y_step * 1.5 - 440};
						draw "scenario" at: {x_val + 1000 + 205 - 300 - 120, y_val + y_step * 1.5 - 500} color: #white font: font("Helvetica", 9, #bold);
				
						// BATTERY SIZE BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 130 + 1000 + 150 - 300 - 100, y_val + y_step * 1.5 - 180};
						draw "battery" at: {x_val + 1000 + 205 - 300 - 100, y_val + y_step * 1.5 - 245} color: #white font: font("Helvetica", 9, #bold);
				
						// CHARGE RATE BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 130 + 1000 + 150 - 300 - 100, y_val + y_step * 1.5 + 80};
						draw "charge" at: {x_val + 1000 + 205 - 300 - 100, y_val + y_step * 1.5 + 15} color: #white font: font("Helvetica", 9, #bold);
				      
				        // NUM AUTONOMOUS BIKES AND SPEED
						draw "NUM VEHICLES" at: {x_val + x_step * 2 + 50 + 900, y_val + 100 - 400} color: #white font: font("Helvetica", 13, #bold);
						draw "" + numAutonomousBikes at: { x_val + x_step * 3 + 900, y_val + y_step / 2.4 + 120 - 400} color: #white font: font("Helvetica", 13);
						draw "SPEED [km/h]" at: { x_val + x_step * 2 + 50 + 900, y_val + y_step * 2 + 20 - 130} color: #white font: font("Helvetica", 13, #bold);
						draw "" + round(DrivingSpeedAutonomousBike * 100 * 3.6) / 100 at: { x_val + x_step * 3 + 900, y_val + y_step * 3 - 130} color: #white font: font("Helvetica", 13);
				   }
				   else{
				   	//TODO AQUÍ VA EL CAMBIO DE PONER EL NÚMERO DE ESTACIONES, AGREGAR HUEVOS PARA SLIDER Y CUADROS (O NO) PARA LOS DATOS
				   	//FALTA RECORRER LAS LEYENDAS PARA QUE PAREZCAN EN CUADRADO Y AGREGAR SAN SEBASTIÁN ARRIBA DE TODO
				   	//REVISAR EN LA ULTIMA PAGINA DE CUADERNO DE TELDAT ANOTACIONES DE LO QUE NO FUNCIONA O FALTA DE IMPLEMENTAR EN EL MODELO DE AGENTES
				   	
						//AUTONOMOUS BIKE WANDERING 
				    	draw "Donostia / San Sebastián" at: {x_val + x_step * 4 + 1200, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 55 , #bold);	
				    		
						//AUTONOMOUS BIKE WANDERING 
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 1.5 - 530} color: (#green-100) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 1.5 - 530} color: (#green-50) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 1.5 - 530} color: (#green-30) rotate: 90;
				    	draw "Bike In Station" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
					
						//AUTONOMOUS BIKE PICHING UP
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-200 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-150 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-100 rotate: 90;
				    	draw "Bike In Motion" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				
						//CHARGING STATION (SEGUNDA COLUMNA)
				    	draw hexagon(90) at: {x_val + x_step * 10 + 1850, y_val + y_step * 1.5 - 530} color: #darkorange;
				    	draw "Charging Station" at: {x_val + x_step * 10 + 130 + 1850, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
					
				    	draw "Number of Stations" at: {x_val + x_step * 10 + 130 + 1850, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
						draw ""+ stationCount at: {x_val + x_step * 10 + 130 + 1850, y_val + y_step * 2.5 - 100} color: #white font: font("Helvetica", 40, #bold);
						
						//PEOPLE (TERCELA COLUMNA)
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 2350, y_val + y_step * 2.5 - 380} color: #mediumslateblue;
				    	draw "People (Lastmile)" at: {x_val + x_step * 14 + 190 + 2350, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				    	
						draw circle(80) at: {x_val + x_step * 14 + 70 + 2350, y_val + y_step * 1.5 - 530} color: #yellow;
				    	draw "People (Riding/Trip)" at: {x_val + x_step * 14 + 190 + 2350, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
				    						
						// SCENARIO BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 130 + 1000 + 150 - 300 - 100, y_val + y_step * 1.5 - 440};
						draw "scenario" at: {x_val + 1000 + 205 - 300 - 120, y_val + y_step * 1.5 - 500} color: #white font: font("Helvetica", 9, #bold);
				      
				        // NUM AUTONOMOUS BIKES AND SPEED
						draw "NUM VEHICLES" at: {x_val + x_step * 2 + 50 + 900, y_val + 100 - 400} color: #white font: font("Helvetica", 13, #bold);
						draw "" + numRegularBikes at: { x_val + x_step * 3 + 900, y_val + y_step / 2.4 + 120 - 400} color: #white font: font("Helvetica", 13);
						draw "SPEED [km/h]" at: { x_val + x_step * 2 + 50 + 900, y_val + y_step * 2 + 20 - 130} color: #white font: font("Helvetica", 13, #bold);
						draw "" + round(DrivingSpeedRegularBike * 100 * 3.6) / 100 at: { x_val + x_step * 3 + 900, y_val + y_step * 3 - 130} color: #white font: font("Helvetica", 13);
				   }
			   }			
			}
					
		
		display dashboard antialias: false type: java2D fullscreen: 0 background: #black { 
			graphics Strings {
			draw "Bike Mobility in Donostia - San Sebastian" at: {550, 160} color: #white font: font("Helvetica", 23, #bold);
			draw rectangle(3650, 2) at: {1880, 200};

 	if autonomousScenario {
            draw rectangle(2500, 100) 
                at: {2000, 270} 
                color: #lightblue; // Fondo azul oscuro
            draw "Current Scenario: Autonomous" 
                at: {1250, 300} 
                color: #white 
                font: font("Helvetica", 20, #bold);
        } else {
            draw rectangle(2500, 100) 
                at: {2000, 270} 
                color: #lightgreen; // Fondo verde oscuro
            draw "Current Scenario: Traditional" 
                at: {1250, 300} 
                color: #white 
                font: font("Helvetica", 20, #bold);
        }

			draw "Average Waiting Time" at: {1250, 550
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
			
			graphics strings{
				draw "Vehicle Count" rotate: 270 at: {400, 2200} color: #white font: font("Helvetica", 10, #bold);  // Eje Y (Time)
				draw "Time of the day" at: {1600, 2800} color: #white font: font("Helvetica", 10, #bold);  // Eje X (Vehicle Count)
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



