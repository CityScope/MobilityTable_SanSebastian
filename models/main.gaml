//ÚLTIMA MODIFICACIÓN 11 DE Febrero

model main 

import "./Agents.gaml" 
import "./Parameters.gaml"

global {
	//Init bounds and roadNetwork
	geometry shape <- envelope(bound_shapefile);
	graph roadNetwork; 
	
	bool autonomousScenario <- autonomousScenario_global;
	
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
	 list avgFirstmile_plot <- list_with(8652, 0);
	 list avgRegBike_plot <- list_with(8652, 0);
	 list avgLastmile_plot <- list_with(8652, 0);
	 list sumawalk_plot <- list_with(8652, 0);
	 
	 list inusebike_plot <- list_with(8652, 0);
	 list availablebike_plot <- list_with(8652, 0);
	 
	 
	 
	
	 int stationCount <- (ceil(numRegularBikes/8));
	 int i <- 1;
	 bool activarprueba <- false;
	 int stationCreatedFlag <- 0;
    // ---------------------------------------Agent Creation----------------------------------------------

	init {
		

    	// ---------------------------------------Buildings--------------------------------------------
	    //create building from: buildings_shapefile;
	    
		// ---------------------------------------The Road Network----------------------------------------------
		create road from: roads_shapefile;
		roadNetwork <- as_edge_graph(road);
		
		// -------------------------------------Charging stations----------------------------------------   
		//Create hotspots for rebalancing - food deliveries
 		create chargingStation from: chargingStations_csv_pred with: [
 			lat::float(get("center_y")),
 			lon::float(get("center_x"))
 		] {
 			point loc <- to_GAMA_CRS({lon,lat},"EPSG:4326").location; 
 			location <- roadNetwork.vertices closest_to(loc);
 			chargingStationCapacity <- stationCapacity;
 		}
 		
 		 int counterestacionesinicio <- 0;
		 create station number: stationCount from: chargingStations_csv_pred with: [
		  
		  lat:: float(get("center_y")),
		  lon:: float(get("center_x"))
		] {
		  point loc <- to_GAMA_CRS({lon,lat},"EPSG:4326").location;
		  location <- roadNetwork.vertices closest_to(loc); 			 
		  capacity <- stationCapacity;
		  numero <- counterestacionesinicio;
		  counterestacionesinicio <- counterestacionesinicio + 1;
		}	
		// -------------------------------------Regular Bikes----------------------------------------   
	
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
				start_day <- int(start_day_str) - 18 ;
				
				string start_h_str <- string(start_hour, 'kk');
				start_h <- int(start_h_str);
				string start_min_str <- string(start_hour, 'mm');
				start_min <- int(start_min_str);
			}
		}
			
		
		write "FINISH INITIALIZATION";
		write length(chargingStations_csv_pred.contents);
		
		initial_hour <- current_date.hour;
		initial_minute <- current_date.minute;
		//write current_date.day;
		
// -------------------------------------------Update Values from Plots -----------------------------------------
		
    }
    
    
     reflex updateValue{
 		autonomousScenario <-  autonomousScenario_global;
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
            remove first(avgFirstmile_plot) from: avgFirstmile_plot;
            remove first(avgRegBike_plot) from: avgRegBike_plot;
            remove first(avgLastmile_plot) from: avgLastmile_plot;
            remove first(sumawalk_plot) from: sumawalk_plot;
            remove first(inusebike_plot) from: sumawalk_plot;
            remove first(availablebike_plot) from: sumawalk_plot;

            
            
            
 
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
        add avgWalkingTime to: avgFirstmile_plot;
        add avgRidingTime to: avgRegBike_plot;
        add avgLastMile to: avgLastmile_plot;
        add avgWalkingTime + avgLastMile to: sumawalk_plot;
        add inuseCountBike to: inusebike_plot;
        add availableCountBike to: availablebike_plot;
        
        
        
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
    
    
    reflex battery_size {
    	if large_battery {
    		maxBatteryLifeAutonomousBike <- 70000.0 #m;
    	}else{
     		maxBatteryLifeAutonomousBike <- 30000 #m;
    	}
    }
    
    reflex charge_rate {
    	if charge_rate {
    		V2IChargingRate <- V2IChargingRate_1;
    	}else{
     		V2IChargingRate <- V2IChargingRate_2;
    	}
    }
    //Stop simulation when specified time is over
	/*reflex stop_simulation when: cycle >= numberOfDays * numberOfHours * 3600 / step {
		do pause;
	}*/
	
	reflex create_autonomousBikes when: autonomousScenario and totalCount < numAutonomousBikes{ 
		//write "number autonmous Bikes: " + numAutonomousBikes;
			create autonomousBike number: (numAutonomousBikes - totalCount){
				location <- point(one_of(roadNetwork.vertices));
				batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike);
				totalCount <- totalCount +1;
		}
		//si me está creando bicicletas pero no me las está quitando.
		//write "count autonomous bike: " + totalCount;
	}
	
	
	/* 	ESTA ES LA FUNCIÓN ORIGINAL QUE CREA BICICLETAS Y FUNCIONA
	 * reflex create_regularBikes when: !autonomousScenario and totalCountRB < numRegularBikes{ 
		write "number of regular bikes: " + numRegularBikes;
			create regularBike number: (numRegularBikes - totalCountRB){
				//location <- point(one_of(roadNetwork.vertices));
				//batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike);
				totalCountRB <- totalCountRB +1; 
		}
		write "count regular bike: " + totalCountRB;
		
	}*/
	
		reflex create_regularBikes when: !autonomousScenario and totalCountRB < numRegularBikes{ 
		 	int number_stations <- ceil(numRegularBikes / 8)  - stationCount;
		 	write number_stations;
		 	if number_stations != 0{
			 	loop s from: 1 to: number_stations{	
				 	list<list<string>> estaciones <- rows_list(chargingStations_csv_pred.contents);
					list<string> nueva_estacion <- estaciones[stationCount]; // Obtiene la fila 11 (contando desde 0)
					//write nueva_estacion;
			
			        //write "ESTO ES LO QUE TIENES QUE ESCRIBIR" + nueva_estacion;	        
			        int station_id <- int(nueva_estacion[0]);
			        float lon <- float(nueva_estacion[2]);
			        float lat <- float(nueva_estacion[1]);
			        //int capacity <- int(nueva_estacion[3]);
			
			        create station with: [
			            lat:: lat,
			            lon:: lon,
			            capacity::stationCapacity,
			            numero::stationCount
				        ]{		       
				        point loc <- to_GAMA_CRS({lon,lat},"EPSG:4326").location;
				  		location <- roadNetwork.vertices closest_to(loc); 
				  		}
	        		stationCount <- stationCount + 1;
	        		write "NUMERO DE ESTACIONES:" + stationCount;
	        		write "Numero DE BICICLETAS:" + numRegularBikes;
			        } //
		        
		 	

         }

    // Ahora sí, creamos la bicicleta
		//write "number of regular bikes: " + numRegularBikes;
		create regularBike number: (numRegularBikes - totalCountRB){
			//location <- point(one_of(roadNetwork.vertices));
			//batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike);
			totalCountRB <- totalCountRB +1; 
		}
		//write "count regular bike: " + totalCountRB;
		
	}

	 
	/*	reflex reset_unserved_counter when: ((initial_ab_number != numAutonomousBikes) or (initial_ab_battery != maxBatteryLifeAutonomousBike) or (initial_ab_speed != RidingSpeedAutonomousBike) or (initial_ab_recharge_rate != V2IChargingRate)){ 
		initial_ab_number <- numAutonomousBikes;
		initial_ab_battery <- maxBatteryLifeAutonomousBike;
		initial_ab_speed <- RidingSpeedAutonomousBike;
		initial_ab_recharge_rate <- V2IChargingRate;
		unservedcount <- 0;
	}*/
		reflex reset_demand when: ((current_date.hour = 0 and current_date.minute = 0 and current_date.second = 0)) {
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
				start_day <- int(start_day_str) - 18 + i;
				
				string start_h_str <- string(start_hour, 'kk');
				start_h <- int(start_h_str);
				string start_min_str <- string(start_hour, 'mm');
				start_min <- int(start_min_str);
				
			}
			
		//totalCount <- 0;
		initial_hour <- 0;
		initial_minute <- 0;
		write "Ha pasado un día (reinicio de demanda)";
		i <- i+1;
	}
	
	reflex eliminarEstaciones when:(stationCount - ceil(numRegularBikes / 8) > 0) {
     				write "ENTRO A ELIMINAR";
					int number_stations <- stationCount - ceil(numRegularBikes / 8);
					write number_stations;
					loop y from: 1 to: number_stations{
						list<station> lista_seleccionada <- station where each.SelectedStation(); 
						list<station> estaciones_huecos <- station where each.SpotsAvailableStation();
						station estacion_seleccionada <- one_of(lista_seleccionada);
						//write estacion_seleccionada;
						//revisar lista estática (logica que se quitan primero)
						ask estacion_seleccionada{
							list<regularBike> bicicletasrebalanceo  <- self.bikesInStation;
							list<station> estacionesposibles <- estaciones_huecos - lista_seleccionada; //comprobar que si le quito self.
							int longitud <- length(bikesInStation);
							
							if empty(bikesInStation){
								do die;  
							}
							else{
								loop x from: 0 to: (longitud - 1){
									regularBike BikeRebalanceo <- bicicletasrebalanceo[x];
									station estacionrebalanceo <- one_of(estacionesposibles);
									BikeRebalanceo.location <- estacionrebalanceo.location;
									BikeRebalanceo.current_station <- estacionrebalanceo;
									bikesInStation <- bikesInStation - BikeRebalanceo;
									estacionrebalanceo.bikesInStation <- estacionrebalanceo.bikesInStation + BikeRebalanceo;
									//write "Longitud de la estación sleccionada: "+ self +  "  " + length(self.bikesInStation);
									//write "Bicicleta Rebalanceada: " + BikeRebalanceo;
								}
								do die;
							}
						}
						//hago el rebalanceo de bicis
						//quito la estación (do die)
						stationCount <- stationCount - 1;
						write "NUMERO DE ESTACIONES:" + stationCount;
	        			write "Numero DE BICICLETAS:" + numRegularBikes;				
					}		
     }
	
	
	    reflex change_regdelivery {
    		if deliverycountreg = 0{
    			regbikedelivery <- #blue;
    		}
    		else{
    			regbikedelivery <- #palegreen;
    		}	
    	}
    
    	reflex change_nobike {
    		if unservedcountreg = 0{
    			nobikecolor <- #blue;
    		}
    		else{
    			nobikecolor <- #red;
    		}	
    	}
    	
    	 reflex change_nospots {
    		if nospotsfound = 0{
    			nospotscolor <- #blue;
    		}
    		else{
    			nospotscolor <- #red;
    		}	
    	}
	
	
	
    
}
 


//--------------------------------- VISUAL EXPERIMENT----------------------------------



experiment multifunctionalVehiclesVisual type: gui {
	int x_val<-300;
	int x_step <- 200;
	int y_val <- 5800;
	int y_step <- 200;
	

		
	


	//Defining parameter values - some overwrite their default values saved in Paramters.gaml
	parameter var: starting_date init: date("2019-10-01 22:58:00");
	parameter var: step init: 5.0#sec;
	parameter var: numberOfDays init: 3;
	parameter "Number of Autonomous Bikes" var: numAutonomousBikes min:1 max: 500 init: 200;
	parameter "Number of Regular Bikes" var: numRegularBikes init: 159 min:1 max: 1232;
    parameter "Battery size" min:30000.0 #m max: 140000.0 #m var:maxBatteryLifeAutonomousBike; //battery capacity in m
	parameter "Autonomous Driving Speed" min: 1/3.6 #m/#s  max: 15/3.6 #m/#s  var:DrivingSpeedAutonomousBike;
	parameter "Regular Bike Average Speed" min: 1/3.6 #m/#s  max: 15/3.6 #m/#s  var:DrivingSpeedRegularBike;
    parameter "Battery Swap" var:large_battery;
    parameter "Charge Rate" var:charge_rate;
    parameter "Battery size regular" min:30000.0 #m max: 140000.0 #m var:maxBatteryLife;
	parameter "Autonomous Scenario Scenario" category: "Scenarios" var:autonomousScenario_global;
	//Defining visualization
    output {
    	
    	
    	//layout  #split background: #black consoles: false controls: false editors: false navigator: false parameters: false toolbars: false tray: false tabs: true;
    		    
		display multifunctionalVehiclesVisual type: opengl background: #black axes: false fullscreen:1 {	 
			
			camera 'default' location: {4402.7388,2931.6502,8710.6203} target: {4402.7388,2931.4982,0.0};
			
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
				draw ("Day " + day + " " + date_time[1]) at: {6590, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 27, #bold);
							}
			graphics Strings {
				if autonomousScenario{
						//AUTONOMOUS BIKE WANDERING 
				    	draw "Donostia / San Sebastián" at: {x_val + x_step * 4 + 1650, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 53 , #bold);	
				    			
						//AUTONOMOUS BIKE WANDERING 
				    	draw triangle(90) at: {x_val + x_step * 4 + 1700, y_val + y_step * 1.5 - 530} color: (#cyan-200) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1700, y_val + y_step * 1.5 - 530} color: (#cyan-150) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1700, y_val + y_step * 1.5 - 530} color: (#cyan-100) rotate: 90;
				    	draw "Autonomous Bike" at: {x_val + x_step * 4 + 130 + 1700, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
						draw "Wandering" at: {x_val + x_step * 4 + 330 + 1700, y_val + y_step * 1.5 - 430} color: #white font: font("Helvetica", 20, #bold);
							
						//AUTONOMOUS BIKE PICKING UP
				    	draw triangle(90) at: {x_val + x_step * 4 + 1700, y_val + y_step * 2.5 - 380} color: #mediumpurple-200 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1700, y_val + y_step * 2.5 - 380} color: #mediumpurple-150 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1700, y_val + y_step * 2.5 - 380} color: #mediumpurple-100 rotate: 90;
				    	draw "Autonomous Bike" at: {x_val + x_step * 4 + 130 + 1700, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				    	draw "(Trip)" at: {x_val + x_step * 4 + 430 + 1700, y_val + y_step * 2.5 - 280} color: #white font: font("Helvetica", 20, #bold);
								
						//LOW CHARGE
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1700, y_val + y_step * 3.5 - 220} color: #red rotate: 90;
				    	draw "Low Charge /" at: {x_val + x_step * 4 + 130 + 1700, y_val + y_step * 3.5 - 220} color: #white font: font("Helvetica", 20, #bold);
				    	draw "Getting Charge" at: {x_val + x_step * 4 + 330 + 1700, y_val + y_step * 3.5 - 120} color: #white font: font("Helvetica", 20, #bold);
								
						//CHARGING STATION (SEGUNDA COLUMNA)
				    	draw hexagon(90) at: {x_val + x_step * 10 + 2150, y_val + y_step * 1.5 - 530} color: #pink;
				    	draw "Charging Station" at: {x_val + x_step * 10 + 130 + 2150, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
							
				    	draw "Number of Stations" at: {x_val + x_step * 10 + 130 + 2150, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
						draw ""+ 77 at: {x_val + x_step * 10 + 130 + 2450, y_val + y_step * 2.5 - 100} color: #white font: font("Helvetica", 40, #bold);
								
						//PEOPLE (TERCELA COLUMNA)
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 3050, y_val + y_step * 2.5 - 380} color: #mediumslateblue;
				    	draw "People (trip)" at: {x_val + x_step * 14 + 190 + 3050, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				    			
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 3050, y_val + y_step * 1.5 - 530} color: #orange;
				    	draw "People" at: {x_val + x_step * 14 + 190 + 3050, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
				    	draw "(waiting/picking bike)" at: {x_val + x_step * 14 + 190 + 3050, y_val + y_step * 1.5 - 410} color: #white font: font("Helvetica", 20, #bold);
				    		
				    	//CHARGE RATE AND BIKE AUTONOMY
				    	draw "Battery Autonomy: " + maxBatteryLifeAutonomousBike/1000 +" Km" at: {x_val + x_step * 14 + 3050, y_val + y_step * 3.5 - 220} color: #white font: font("Helvetica", 20, #bold);
				    	if charge_rate{
				   	    	draw "Swap Time: 11s" at: {x_val + x_step * 14 + 3050, y_val + y_step * 3.5 - 70} color: #white font: font("Helvetica", 20, #bold);
				    	}else{
				   	    	draw "Swap Time: 4.5 hours" at: {x_val + x_step * 14 + 3050, y_val + y_step * 3.5 - 70} color: #white font: font("Helvetica", 20, #bold);
				    	}
				    					    	
						// SCENARIO BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 30 + 895 + 150 - 300 - 100, y_val + y_step * 1.5 - 440};
						draw "scenario" at: {x_val + 1000 - 300 - 120, y_val + y_step * 1.5 - 500} color: #white font: font("Helvetica", 9, #bold);
				
						// BATTERY SIZE BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 30 + 895 + 450 - 300 - 100,  y_val + y_step * 1.5 - 440};
						draw "battery" at: {x_val + 1000 - 300 + 200, y_val + y_step * 1.5 - 500} color: #white font: font("Helvetica", 9, #bold);
				
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
				    	draw "Donostia / San Sebastián" at: {x_val + x_step * 4 + 1400, y_val + y_step * 1.5 - 960} color: #white font: font("Helvetica", 55 , #bold);	
				    		
						//AUTONOMOUS BIKE WANDERING 
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 1.5 - 530} color: (#green-100) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 1.5 - 530} color: (#green-50) rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 1.5 - 530} color: (#green-30) rotate: 90;
				    	draw "Bike In Station" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
					
						//AUTONOMOUS BIKE PICKING UP
				    	draw triangle(90) at: {x_val + x_step * 4 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-200 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 15 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-150 rotate: 90;
				    	draw triangle(90) at: {x_val + x_step * 4 + 30 + 1500, y_val + y_step * 2.5 - 380} color: #mediumpurple-100 rotate: 90;
				    	draw "Bike In Motion" at: {x_val + x_step * 4 + 130 + 1500, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				
						//CHARGING STATION (SEGUNDA COLUMNA)
				    	draw hexagon(90) at: {x_val + x_step * 10 + 2100, y_val + y_step * 1.5 - 530} color: #darkorange;
				    	draw "Charging Station" at: {x_val + x_step * 10 + 130 + 2100, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
					
				    	draw "Number of Stations" at: {x_val + x_step * 10 + 130 + 2100, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
						draw ""+ stationCount at: {x_val + x_step * 10 + 130 + 2400, y_val + y_step * 2.5 - 100} color: #white font: font("Helvetica", 40, #bold);
						
						//PEOPLE (TERCELA COLUMNA)
				    	draw circle(80) at: {x_val + x_step * 14 + 70 + 3200, y_val + y_step * 2.5 - 380} color: #mediumslateblue;
				    	draw "People (Lastmile)" at: {x_val + x_step * 14 + 190 + 3200, y_val + y_step * 2.5 - 380} color: #white font: font("Helvetica", 20, #bold);
				    
						draw circle(80) at: {x_val + x_step * 14 + 70 + 3200, y_val + y_step * 1.5 - 530} color: #yellow;
				    	draw "People (Riding/Trip)" at: {x_val + x_step * 14 + 190 + 3200, y_val + y_step * 1.5 - 530} color: #white font: font("Helvetica", 20, #bold);
				    						
						// SCENARIO BUTTON
						draw rectangle(300,260) border: #white wireframe: true at: {x_val + 30 + 895 + 150 - 300 - 100, y_val + y_step * 1.5 - 440};
						draw "scenario" at: {x_val + 1000 - 300 - 120, y_val + y_step * 1.5 - 500} color: #white font: font("Helvetica", 9, #bold);
				      
				        // NUM AUTONOMOUS BIKES AND SPEED
						draw "NUM VEHICLES" at: {x_val + x_step * 2 + 50 + 900, y_val + 100 - 400} color: #white font: font("Helvetica", 13, #bold);
						draw "" + numRegularBikes at: { x_val + x_step * 3 + 900, y_val + y_step / 2.4 + 120 - 400} color: #white font: font("Helvetica", 13);
						draw "SPEED [km/h]" at: { x_val + x_step * 2 + 50 + 900, y_val + y_step * 2 + 20 - 130} color: #white font: font("Helvetica", 13, #bold);
						draw "" + round(DrivingSpeedRegularBike * 100 * 3.6) / 100 at: { x_val + x_step * 3 + 900, y_val + y_step * 3 - 130} color: #white font: font("Helvetica", 13);
				   }
			   }			
			}
			

		display dashboard antialias: false type: java2D fullscreen: 0 background: #black axes: false { 
			graphics Strings {
			draw "Micromobility in Donostia - San Sebastian" at: {50, 160} color: #white font: font("Helvetica", 35, #bold);
			draw rectangle(4050, 2) at: {1880, 200};

        		//AUTONOMOUS SCENARIO GRAPHICS
 				if autonomousScenario {
		           	 draw "Current Scenario: Autonomous Bicycles" 
		                at: {770, 400} 
		                color: #lightblue 
		                font: font("Helvetica", 30, #bold);
	 				draw "UnservedTrips" at: {850, 2450} color: #white font: font("Helvetica", 15, #bold);
	 					 if unservedcount = 0 {
	      		  			foodwastecolor <- #blue;
	   					 } 
	   					 else {
	       		 			foodwastecolor <- #red;
	   			    	 }
	  				draw rectangle(700, 230) at: {1120, 2600} color: foodwastecolor;
	 		    	draw "" + unservedcount at: {1080, 2650} color: #black font: (font("Helvetica", 30, #bold));
	 		    	draw "People Average Wait Time [min]" rotate: 270 at: {-450, 1350} color: #lightblue font: font("Helvetica", 15, #bold);
					list date_time <- string(current_date) split_with (" ",true);
					
					draw "Simulation Time" at: {2960, 1700} color: #gray font: font("Helvetica", 11, #bold);
					draw ("" + date_time[1]) at: {3000, 1800} color: #gray font: font("Helvetica", 17, #bold);
					
					draw "Simulation Time" at: {2960, 4250} color: #gray font: font("Helvetica", 11, #bold);
					draw ("" + date_time[1]) at: {3000, 4350} color: #gray font: font("Helvetica", 17, #bold);
					
					draw "Hour of the day [Hr.]" at: {1350, 2150} color: #skyblue font: font("Helvetica", 15, #bold);
					draw "Hour of the day [Hr.]" at: {1350, 4500} color: #skyblue font: font("Helvetica", 15, #bold);
 					draw "Vehicle Tasks" at: {1350, 3100} color: #white font: font("Helvetica", 20, #bold);
 					draw "Average Waiting Time" at: {1200, 800} color: #white font: font("Helvetica", 20, #bold);
 					
 					draw "Vehicle Count" rotate: 270 at: {-70, 3750} color: #lightblue font: font("Helvetica", 15, #bold);  // Eje Y (Time)
					//draw "Time of the day" at: {1600, 2800} color: #white font: font("Helvetica", 10, #bold);  // Eje X (Vehicle Count)
					
					

    				draw "Average Time" at: {3170, 1030} color: #white font: font("Helvetica", 15, #bold);
					draw circle(80) at: {3000, 1000} color: #pink;
					draw "15 Min. Mark" at: {3170, 1230} color: #white font: font("Helvetica", 15, #bold);
					draw circle(80) at: {3000, 1200} color: #red;
					
					draw "Vehicles Occupied" at: {3170, 3730} color: #white font: font("Helvetica", 15, #bold);
					draw circle(80) at: {3000, 3700} color: #skyblue;
					draw "Vehicles Idling" at: {3170, 3530} color: #white font: font("Helvetica", 15, #bold);
					draw circle(80) at: {3000, 3500} color: #orange;
    				draw "Vehicles Charging" at: {3170, 3330} color: #white font: font("Helvetica", 15, #bold);
					draw circle(80) at: {3000, 3300} color: #pink;
					
    				draw "Completed Trips" at: {1900, 2450} color: #white font: font("Helvetica", 15, #bold) ;
						if deliverycount = 0{
						foodwastecolor <- #blue;
					} else {
						foodwastecolor <- #palegreen;
					}
					draw rectangle(700,230) at: {2200, 2600} color: foodwastecolor;
					draw "" + deliverycount at: {2160,2650} color: #black font:(font("Helvetica",30,#bold));		
 				}
 				//!REGULAR SCENARIO GRAPHICS
 				else{
		            draw "Current Scenario: Traditional" 
		                at: {800, 400} 
		                color: #lightgreen 
		                font: font("Helvetica", 30, #bold);
		                
		               	draw rectangle(700, 230) at: {2800, 2300} color: regbikedelivery;
		               	draw "Served Trips" at: {2600, 2150} color: #white font: font("Helvetica", 12, #bold);
		              	draw "" + deliverycountreg at: {2750, 2350} color: #black font: (font("Helvetica", 30, #bold));
		               	
		               	draw rectangle(700,230) at: {1700, 2300} color: nospotscolor;
		              	draw "No Bikes Found" at: {1500, 2150} color: #white font: font("Helvetica", 12, #bold);
		                draw "" + unservedcountreg at: {1700, 2350} color: #black font: (font("Helvetica", 30, #bold));
		               	
		              	draw rectangle(700,230) at: {600, 2300} color: nospotscolor;
		              	draw "No Spots Found" at: {400, 2150} color: #white font: font("Helvetica", 12, #bold);
		                draw "" + nospotsfound at: {600, 2350} color: #black font: (font("Helvetica", 30, #bold));
		              	
		              	list date_time <- string(current_date) split_with (" ",true);
		              	
						draw "Simulation Time" at: {2960, 1700} color: #gray font: font("Helvetica", 11, #bold);
						draw ("" + date_time[1]) at: {3000, 1800} color: #gray font: font("Helvetica", 17, #bold);
						
						draw "Simulation Time" at: {2960, 4250} color: #gray font: font("Helvetica", 11, #bold);
						draw ("" + date_time[1]) at: {3000, 4350} color: #gray font: font("Helvetica", 17, #bold);
						
    					
    					draw "Average Trip Times" at: {1200, 600} color: #white font: font("Helvetica", 20, #bold);
	 		    		draw "Average Ride/Walk Time [min]" rotate: 270 at: {-400, 1150} color: #lightgreen font: font("Helvetica", 15, #bold);
	 		    		
    					draw "Walking Time" at: {3170, 1030} color: #white font: font("Helvetica", 15, #bold);
						draw circle(80) at: {3000, 1000} color: #red;
						draw "Bike Riding" at: {3170, 1230} color: #white font: font("Helvetica", 15, #bold);
						draw circle(80) at: {3000, 1200} color: #blue;		
						
						draw "System Availability" rotate: 270 at: {-200, 3650} color: #lightgreen font: font("Helvetica", 15, #bold);  // Eje Y (Time)
    					draw "Vehicle Tasks" at: {1350, 3100} color: #white font: font("Helvetica", 20, #bold);
    					
    					draw "Hour of the day [Hr.]" at: {1350, 1950} color: #lightgreen font: font("Helvetica", 15, #bold);
						draw "Hour of the day [Hr.]" at: {1350, 4500} color: #lightgreen font: font("Helvetica", 15, #bold);
    					


		               	
		                

 				}


			}
			chart "Vehicle Tasks" type: series visible: autonomousScenario background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,550] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: (string(current_date.hour))  x_tick_unit: 721 memorize: false position: {200, 3200} size: {2700, 1200} series_label_position: none {
    				data "Vehicles Charging" value: getChargeCountBike_plot color: #pink marker: false style: line;
    				data "Vehicles Idling" value: wanderCountBike_plot color: #orange marker: false style: line;
    				data "Vehicles Occupied" value:suma_plot  color: #skyblue marker: false style: line;
    		//data "Vehicles in Use" value: inUseCountBike color: #orange marker: false style: line;
			}
				chart "Average Wait Time" type: series visible: autonomousScenario background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,25] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: (string(current_date.hour)) x_tick_unit: 721 memorize: false position: {200, 630} size: {2700, 1200} series_label_position: none {
				data "Wait Time" value: avgWait_plot color: #pink marker: false style: line;
				data "15 min" value: limitwait_plot color: #red marker: false style: line;
				}
				
				chart "Regular Bike Times" type: series visible: !autonomousScenario background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,15] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: (string(current_date.hour)) x_tick_unit: 721 memorize: false position: {200, 630} size: {2700, 1200} series_label_position: none {
   					data "Total Walking Time" value: sumawalk_plot color: #red marker: false style: line;
    				data "Bike Ride Time" value: avgRegBike_plot color: #blue marker: false style: line;
				}
				
				chart "Regular Bike State" type: series visible: !autonomousScenario background: #black title_font: font("Helvetica", 15, #bold) title_visible: false color: #white axes: #white x_range: 8652 y_range:[0,550] tick_line_color:#transparent x_label: "" y_label: "" x_serie_labels: (string(current_date.hour))  x_tick_unit: 721 memorize: false position: {200, 3200} size: {2700, 1200} series_label_position: none {
    				data "Available Bikes" value: availablebike_plot color: #green marker: false style: line;
    				data "Bikes in Use" value: inusebike_plot color: #red marker: false style: line;
				}
			
				
			//COMPLETED TRIPS

			//UNSERVED TRIPS

							}
    					}
					}	

		



