model Agents

import "./main.gaml"
// *********************************** GLOBAL FUNCTIONS  ***************************************
global {
	
	
	// Auxiliary function to calculate distances in graph
	float distanceInGraph (point origin, point destination) {
		point originIntersection <- roadNetwork.vertices closest_to(origin);
		point destinationIntersection <- roadNetwork.vertices closest_to(destination);
		
		if (originIntersection = destinationIntersection) {
			return 0.0;
		}else{	
			return (originIntersection distance_to destinationIntersection using topology(roadNetwork));
	
		}
	}
 	///////---------- WAIT TIME VARIABLES (PARA HACER EL PLOT DE AVG WAIT TIME) --------------///////
	//int lessThanWait <- 0;
	int moreThanWait <- 0;
	float timeWaiting <- 0.0;
	float avgWait <- 0.0;
	list<float> timeList <- []; //list of wait times
	
	 	///////---------- WALKTING TIME VARIABLES (FIRSTMILE) --------------///////
	int moreThanWait_reg<- 0;
	float walkingTime <- 0.0;
	float avgWalkingTime <- 0.0;
	list<float> walkingTimeList <- [];
	
	
	///////---------- REGULAR RIDE TIME VARIABLE (JUST FOR THE BIKE TRIP TIME) --------------///////
	float timeRiding <- 0.0;
	list<float> ridingTimeList <- [];
	float avgRidingTime <- 0.0;
	
	///////---------- WALKTIN TIME VARIABLES(LASTMILE) --------------///////
	float startTimeLastMile <- 0.0;
	float timeLastMile <- 0.0;
	list<float> timeListLastMile <- [];
	float avgLastMile <- 0.0;
	
	
	       //...variables initial_hour initial_minute
	int initial_hour;
	int initial_minute;
	
	//...start of waiting times (same as above but corrected)
	
	/* 
	 *	int start_wait_hour;
	int start_wait_min;*/

	
	//VARIABLES FOR COUNTING SERVED AND UNSERVED (AUTONOMOUS SCENARIO)
	int deliverycount <- 0;
	int unservedcount<-0;
	
	//VARIABLES FOR COUNTING SERVED AND UNSERVED (REGULAR SCENARIO)
	int deliverycountreg <- 0;
	int unservedcountreg <-0;  //no bikes found
	int nospotsfound <- 0;     //no spots found
	
	//VARIABLE COUNTING WHEN THERE´S NOT A SPOT TO LEAVE THE BIKE (REGULAR SCENARIO)
	int no_spotscount <-0;
	
	//VARIABLE COUNTING WHEN THERE´S NOT A BIKE AVAILABLE TO MAKE THE TRIP IN THE CLOSEST STATION(REGULAR SCENARIO)
	int no_bikescount <-0;

	
	
	//size of the station hexagons
	int sizeX <- 40;
	int sizeY <- 40;
	rgb currentColor <- #gray;
	
	//Counters for autonomous bike Scenario Tasks
	int wanderCountbike <- 0;
	int lowChargeCount <- 0; //lowbattery, lowfuel for electric, combustion
	int getChargeCount <- 0; //getcharge, getfuel for electric, combustion
	int pickUpCountBike <- 0;  
	int inUseCountBike <- 0; //en este caso este contador se está usando?
	int fleetsizeCountBike <- 0;
	int numauonomoousbike <- 0;
	int RebalanceCount <- 0; 	int biddingCount <-0;
	int endbidCount<-0;
	int totalCount;

//Counters for regular bike Scenario Tasks
	int inuseCountBike <- 0;
	int lowChargeCountRegular<- 0; //lowbattery, lowfuel for electric, combustion
	int pickUpCountRegular <- 0;
	int fleetsizeCountRegular <- 0;
	int totalCountRB;
	int availableCountBike <- 0;
	
	// Initial values storage of the simulation
	int initial_ab_number <- numAutonomousBikes;
	float initial_ab_battery <- maxBatteryLifeAutonomousBike;
	float initial_ab_speed <- RidingSpeedAutonomousBike;
	string initial_ab_recharge_rate <- V2IChargingRate;
	
	
	///////VEHICLE REQUESTS - NO BIDDING - REGULAR BIKES ------------///////

bool RequestRealBike(people person) { 
// Get the list of all stations
    list<station> availableStations <- station where each.BikesAvailableStation(); 
	if availableStations = nil{
//write "there are no stations with bikes";
		return false;
	}      
// Get the point closest to the person in the graph
   point personIntersection <- roadNetwork.vertices closest_to(person);

// Get the station closest to the person
    station closestStation <- availableStations closest_to(personIntersection);

// I'M NOT SURE IF THE DISTANCE CONDITION APPLIES IN THIS SCENARIO (PENDING TASK)
    float d <- distanceInGraph(personIntersection, closestStation.location);

// If the station is too far
// change maxdistancepeople to the one from regular scenario (PENDING TASK)
    if (d > person.maxDistancePeople_AutonomousBike) {
        //write "STATION TOO FAR";
        return false;
    }
    person.target <- closestStation.location;
    person.start_station<-closestStation;
    return true;
 } 
 	///////---------- VEHICLE REQUESTS - NO BIDDING --------------///////
	bool requestAutonomousBike(people person) { 
	 
	 	//Get list of available vehicles
		list<autonomousBike> available <- (autonomousBike where each.availableForRideAB());
		
		//If no bikes available 
		if empty(available){
			//write 'NO BIKES AVAILABE';
			return false;
		}	
		point personIntersection <- roadNetwork.vertices closest_to(person);
		autonomousBike b <- available closest_to(personIntersection); 
		float d<- distanceInGraph(personIntersection,b.location);
			
		 
		if d>person.maxDistancePeople_AutonomousBike{
			return false;
			write'TRIP UNSERVED';
			
		}
		else{
			ask b { do pickUp(person);} //Assign person to bike
			ask person {do ride(b);} //Assign bike to person
			return true;
		}		
	}
	
	bool requestRegularBike(people person) {
		station assignedStation <- person.start_station;
		if (assignedStation = nil or dead(assignedStation)){
			return false;
		} 
		else if empty(assignedStation.bikesInStation){
			//write 'NO BIKES AVAILABE';
			return false;
		}else{	
			list<regularBike> availableBikes <- assignedStation.bikesInStation;
			regularBike selectedBike <- first(availableBikes);
			if(dead(selectedBike)){
				return false;
			}
			ask selectedBike { do pickUp(person);} //Assign person to bike
			ask person {do rideRB(selectedBike);} //Assign bike to person
			return true;
		}
	}
		
	
	
}
	

// *******************************************    SPECIES    ******************************************************************

species road {
	aspect base {
		draw shape color: rgb(125, 125, 125);
	}
}

/*species building {
    aspect type {
		draw shape color: #silver;
	}
	string type; 
}*/


species chargingStation{
	
	list<autonomousBike> autonomousBikesToCharge;	
	rgb color <- #darkorange;	
	float lat;
	float lon;
	float sizeFactor <- 1.0;
	rgb dynamicColor <- rgb(255, 239, 193); // color base (beige claro)
	
	int chargingStationCapacity; 
	
	aspect base{
		draw hexagon(sizeX*self.sizeFactor,sizeY*self.sizeFactor) color:dynamicColor
			 border:rgb(72, 61, 139);
	}
	
	reflex chargeBikes {
		ask chargingStationCapacity first autonomousBikesToCharge {
			batteryLife <- batteryLife + step*V2IChargingRate;
		}
	}
	
	reflex actualizarAspecto {
		int currentLoad <- length(self.autonomousBikesToCharge);
		float loadRatio <- currentLoad / self.chargingStationCapacity;

		self.sizeFactor <- 1.0 + (loadRatio * 4.0); // hasta 2.0

		int r <- 255;
		int g <- int(239 - 239 * (2*loadRatio));
		int b <- int(193 - 193 * (2*loadRatio));

		self.dynamicColor <- rgb(r, g, b);
	}
}


species station {
	
	list<regularBike> bikesInStation;
	
	float lat;
	float lon;
	
	int capacity; 
	int stationquality;
	
	//color stations
	int blue <- 205;
	int green <- 195;
	
	int rebalanceo;
	int numero;
	
	//rgb stationcolor <-rgb(0,0,0);
	rgb stationcolor <- #orange;
	
	int entradas <- 0;     // cuenta de entradas reales (bicicleta llega por sí sola)
	int salidas <- 0;      // cuenta de salidas reales (bicicleta se va por un usuario)
	float balance <- 0.0;  // indicador visual (entradas - salidas)
	rgb dynamicColor <- rgb(255, 239, 193);
	float sizeFactor <- 1.0; // tamaño visual si quieres
	
	
		aspect base{
		draw hexagon(sizeX+40,sizeY+40) color:dynamicColor border:stationcolor;
	}
	
	reflex chargeBikes {
		ask bikesInStation {
			if batteryLife < maxBatteryLife{
			batteryLife <- batteryLife + step*V2IChargingRate;
			}
		}
	}
	
	reflex actualizarAspecto {
    	balance <- float(entradas - salidas);
    	float ratio <- balance / capacity;

   	 // Clampear ratio a [-1.0, 1.0]
   		 ratio <- max(-1.0, min(1.0, ratio));

    // Color base: beige claro
   		 int baseR <- 255;
   		 int baseG <- 239;
  		 int baseB <- 193;

    // Máximo cambio permitido en cada componente (para mantener el estilo)
    		int maxShift <- 80;

   		 int r <- baseR;
 		   int g <- baseG;
    		int b <- baseB;

    if (ratio > 0.0) {
        // Hay más entradas que salidas → tendencia a rojo (menos verde y azul)
        g <- int(baseG - ratio * maxShift);  // Verde baja
        b <- int(baseB - ratio * maxShift);  // Azul baja
    } else if (ratio < 0.0) {
        // Hay más salidas que entradas → tendencia a verde (menos rojo y azul)
        r <- int(baseR + ratio * maxShift);  // Rojo baja (ratio negativo)
        b <- int(baseB + ratio * maxShift);  // Azul baja
    }

    // Clamp final para evitar salirse de [0, 255]
    r <- max(0, min(255, r));
    g <- max(0, min(255, g));
    b <- max(0, min(255, b));

    dynamicColor <- rgb(r, g, b);

    // Escalado visual opcional
    sizeFactor <- 1.0 + abs(ratio) * 2.0;
}
	

	
	/*reflex color_station{
		if green > 0 and blue > 0{
		green <- green - (stationquality);
		blue <- blue - (stationquality);
		stationcolor <-rgb(255,green,blue) ;
		}
	}*/
	
		reflex cleanstation {
  			bikesInStation <- bikesInStation where (!dead(each));
		}

	//comienzan en blanco
	//si salen bicis, le subo un poco al rojo y demanda de Alejandro ----> (prioridad2)
	//si entran bicis, le resto un poco al rojo  **esto corregir
	//mover código (DONOSTIA A LA DERECHA Y AJUSTAR PANTALLA) ---->(prioridad1rápido)
	//resolver bug de hoy --->(prioridad)
	//draft presentación mañana para zuriñe --->(prioridad1)	
	
	bool SpotsAvailableStation {
		if length(self.bikesInStation) < self.capacity {
			return true;
		}else{
			return false;
		}
	}
	
	bool BikesAvailableStation {
		if length(self.bikesInStation) > 0 {
			return true;
		}else{
			return false;
		}
	}
	
	bool ReachedRebalanceo (int max_bikes){
		if length(self.bikesInStation) = max_bikes {
			return true;
		}else{
			return false;
		}
	}
	
	bool SelectedStation {
		//write "TEST NUMBER: " + self.numero;
		//write "TEST STATIONCOUNT: " + (stationCount - 1);
		if self.numero = (stationCount - 1){
			//write "VAMOOOOS";
			return true;
	
		}else{
			return false;
		}
	}
	
	
}

// *******************************************    PEOPLE    ******************************************************************

species people control: fsm skills: [moving] {


 //----------------ATTRIBUTES-----------------
 
 	//prueba
 	int start_wait_hour;
	int start_wait_min;

	//raw
	date start_hour; 
	float start_lat; 
	float start_lon;
	float target_lat;
	float target_lon;
	
	 
	//adapted
	point start_point;
	point target_point;
	int start_day;
	int start_h; 
	int start_min; 
	
	//regularbiketime timer
	int startRide_h;
	int startRide_min;
	
	//firsmile timer
	int walkStartHour;
	int walkStartMinute;
	
	//lastmile timer
	int startLastMileHour ;
	int startLastMileMinute ;
		
 	//destination
    point final_destination;
    
    //assigned bike
    autonomousBike autonomousBikeToRide;
    
    //assigned bike
    regularBike regularBikeToRide;
    
    //dynamic attributes
    float tripdistance <- 0.0; 
    point target;   
    
    //float dynamic_maxDistancePeople <- maxDistancePeople_AutonomousBike;
    float maxDistancePeople_AutonomousBike <- maxDistancePeople_AutonomousBikeglobal;
    bool created_bike <- false;
    
    //stations start and end points
    station start_station;
    station end_station;
    
    //visual aspect
   	rgb color;
    map<string, rgb> color_map <- [
    	"wandering":: #transparent,
		"requestingAutonomousBike":: #orange,
		"awaiting_autonomousBike":: #orange,
		"riding_autonomousBike":: #mediumslateblue,
		"firstmile":: #yellow,
		"lastmile":: #mediumslateblue
	];
    aspect base {
    	color <- color_map[state];
    	draw circle(15) color: color border: #black;
    }
    
    
   	/* ---------------- FUNCTIONS ---------------- */
	
    action ride(autonomousBike ab) {
    	if ab!=nil{
    		autonomousBikeToRide <- ab;
    	}
    	else{
    		write "SE DIO EL CASO";
    	}
    }
    
    action rideRB(regularBike ab) {
    	if ab!=nil{
    		regularBikeToRide <- ab;
    	}
    }
	

    bool timeToTravel { 
    	if current_date.day != start_day {return false;}
    	else{
    	return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point);}
    }
    
    
    
    
    
    /* ========================================== STATE MACHINE ========================================= */
 
    state wandering initial: true {
    	enter {
    		target <- nil;
    	}
    	transition to: requestingAutonomousBike when: autonomousScenario and timeToTravel(){ //Flow if bidding is NOT enabled: requestingAutonomousBike --> firstmile
    		final_destination <- target_point;
    		start_wait_hour <- current_date.hour;
	        start_wait_min <- current_date.minute;
    		 //write "transition to requestingautonomousbike de agente: "  +self;
    		
    	}
    	transition to: chooseStation when: !autonomousScenario and timeToTravel(){ //Flow if bidding is NOT enabled: requestingAutonomousBike --> firstmile
    		final_destination <- target_point;
    		//write "transition to chooseStation de agente: "  +self;
    		//write "final_destination :" + final_destination;
    	}
    	exit {
		}
    }
    
    //If bidding not enabled (autonomousScenario)
    state requestingAutonomousBike {
		enter {
			
		}
		transition to: firstmile when: host.requestAutonomousBike(self) {
			target <- (road closest_to(self)).location;
		}
		transition to: finished when: !host.requestAutonomousBike(self){ 
			//write 'ERROR: Trip not served';
			unservedcount<-unservedcount+1;
			location <- final_destination;
		}
		exit {
		}
	}
	
	state chooseStation {
	    enter {	
	    //write "ESTADO CHOOSE STATION: agente "+self+"con rider "+self.regularBikeToRide;
	    int primero <-  numRegularBikes;	
        //list<station> all_stations <- station;
        station closest_station <- station closest_to(self);
        	if (!closest_station.BikesAvailableStation()) {
            	ask closest_station {
               	 rebalanceo <- rebalanceo + 1;
               	 stationquality <- stationquality + 1;
               	 unservedcountreg <- unservedcount + 1;
               	 
               	 
               	 //write rebalanceo;
	                 if (rebalanceo >= 3 and numRegularBikes = primero ) {
						// This is done in case I lower the slider and to avoid showing the bikes that were removed from the list.
						// First, it waits for all the bikes to be removed so that no bike appears in the /death/ state.
						//write numRegularBikes;
						//TODO if the station I'm going to rebalance has less than 3 bikes, don't count the counter    	
	                 	rebalanceo <- 0;
						list<station> stations_with_bikes <- station where each.BikesAvailableStation();
						if (length(stations_with_bikes) > 0) {
						    int max_bikes <- max_of(stations_with_bikes, length(each.bikesInStation));
						    int min_bikes <- min_of(stations_with_bikes, length(each.bikesInStation));
						    if (max_bikes >= 3){
							    list<station> stations_with_max_bikes <- stations_with_bikes where each.ReachedRebalanceo(max_bikes);
							    station station_with_most_bikes <- one_of(stations_with_max_bikes);
							   // write "Estación con más bicicletas: " + max_bikes+ station_with_most_bikes;
							   // write station_with_most_bikes.bikesInStation;
							    regularBike bike_rebalanceo <- last(station_with_most_bikes.bikesInStation);
							    station_with_most_bikes.bikesInStation <- station_with_most_bikes.bikesInStation - bike_rebalanceo;
							    bike_rebalanceo.location <- closest_station.location;      
							    closest_station.bikesInStation <- closest_station.bikesInStation + bike_rebalanceo;
							   // write "Estación ahora: "+ closest_station.bikesInStation;
							    //write "Estación cambio: "+station_with_most_bikes.bikesInStation;
						    }
						    else{
								//write "REBALANCING IS NOT DONE BECAUSE THERE ARE FEW BIKES";
						    }
						}
						
	                 }                 
           		 }
            }     
			list<station> available_stations <- station where each.BikesAvailableStation();
			if available_stations = nil{				
			}
	        //write available_stations;  
	    	//estación más cercana	    	
	        start_station <- available_stations closest_to(self);
	        //write start_station;  me da que todas son nil (ya no, tenía que actualizar las bicis con el ask)
	        self.start_station <- start_station;  
	        target <- start_station.location;
	    }
	    transition to: firstmile when: !autonomousScenario and target = start_station.location; // Si se encuentra una estación válida
	    //write "transition to firstmile de agente: " +self;	    
	    exit {
	    }	    
	}
//debug auqí porque no está entrando a target  (entra pero no siempre me hace el write de chooseendstation)
state pickUpBike {
    enter {
    	
        if host.requestRegularBike(self) {
            target <- (road closest_to(self)).location; // ¿Esto está bien? quiero que se vaya de regreso a la calle y ya en el sig estado ...
        } else {
            //write "Error al asignar la bicicleta.";
            target <- nil;
        }
        //write "ESTADO PICKUPBIKE: agente "+self+"con rider "+self.regularBikeToRide;
        
    }
    transition to: chooseStation when: !autonomousScenario and target = nil; 
     //write "transition to chooseStation de agente: " +self;	    
    
    transition to: chooseEndStation when: !autonomousScenario and target != nil;
	//write "transition to ChooseEndStation de agente: " +self;	    

    exit {
    }
}


	
	state chooseEndStation{
		enter{
		//write "ESTADO CHOOSEENDSTATION: agente "+self+"con rider "+self.regularBikeToRide;
			
	        list<station> available_stations <- station where (each.SpotsAvailableStation());
	        if empty(available_stations){
	        	write "PRUEBA";
	        	//TODO 
	        	
	        }
	        station end_station_temp <- available_stations closest_to(target_point);	
	        target <- end_station_temp.location;
	        end_station <- end_station_temp;
		}
		transition to: riding_regularBike when: !autonomousScenario and target = end_station.location{
			startRide_h <- current_date.hour;
        	startRide_min <- current_date.minute;
		} // Si se encuentra una estación válida
	     //write "transition to ridingRegularBike de agente: " +self;	    

		exit{	
		}	
	}
	
	state riding_regularBike {
		enter {
		//write "RIDING REGULAR BIKE: agente "+self+"con rider "+self.regularBikeToRide;
		//write final_destination;
			

		}
		transition to: dropoffBike when: regularBikeToRide.state != "in_use_people" {
		//write "transition to dropoffBike de agente: " +self;	    
		
			target <- final_destination;
		}
		exit {
		}
		location <- regularBikeToRide.location; //Always be at the same place as the bike  
	}
	
	
	state riding_autonomousBike {
		enter {

		}
		transition to: lastmile when: autonomousBikeToRide.state != "in_use_people" {
			target <- final_destination;
		}
		exit {
			autonomousBikeToRide <- nil;
		}
		location <- autonomousBikeToRide.location; //Always be at the same place as the bike
	}
	
	state dropoffBike{
		enter{
		//write "ESTADO DROPOFFBIKE: agente "+self+"con rider "+self.regularBikeToRide;
			
	        if end_station.SpotsAvailableStation() = false {
					//write "No hay huecos para dejar la bici";
				nospotsfound <- nospotsfound +1;
	            target <- nil; 
			}else{
				self.regularBikeToRide <- nil;
					//write "Si hay huecos para dejar la bici";
			}
		}
		
		transition to: chooseEndStation when: target = nil{
			//write "DE VUELTA A CHOOSE END STATION: " +self;	    
		}

		transition to: lastmile when: self.regularBikeToRide=nil{
			float currentMinutes <- current_date.hour * 60 + current_date.minute;
		    float startMinutes <- startRide_h * 60 + startRide_min;
		    
		    if (currentMinutes < startMinutes) {
		        // Paso por la medianoche
		        timeRiding <- currentMinutes + (24 * 60 - startMinutes);
		    } else {
		        timeRiding <- currentMinutes - startMinutes;
		    }
		
		    // Agregar a la lista para calcular el promedio
		    if length(ridingTimeList) = 20 {
		        remove from: ridingTimeList index: 0;
		    }
		    ridingTimeList <- ridingTimeList + timeRiding;
		
		    // Calcular promedio
		    avgRidingTime <- sum(ridingTimeList) / length(ridingTimeList);
					//write "transition to lastmile de agente: " +self;	 
			deliverycountreg <- deliverycountreg + 1;   
		}
	
	}
	
	state firstmile {
		enter{
		//write "ESTADO FIRSTMILE: agente "+self+"con rider "+self.regularBikeToRide;
		if !autonomousScenario{
				walkStartHour <- current_date.hour;
				walkStartMinute <- current_date.minute;
		}

			
		}
		transition to: awaiting_autonomousBike when: autonomousScenario and location=target{
				}
		transition to: pickUpBike when: !autonomousScenario and location=target{
			float now <- current_date.hour * 60 + current_date.minute;
			float start <- walkStartHour * 60 + walkStartMinute;

			if (walkStartHour > current_date.hour) {
				// caso donde pasó de un día a otro
				walkingTime <- now + (24 * 60 - start);
			} else {
				walkingTime <- now - start;
			}
		
			// Agregar a la lista de caminatas
			if length(walkingTimeList) = 20 {
				remove from:walkingTimeList index: 0;
			}
			walkingTimeList <- walkingTimeList + walkingTime;
		
			// Calcular promedio
			avgWalkingTime <- sum(walkingTimeList) / length(walkingTimeList);
		}
	    //write "transition to pickupBike de agente: " +self;	    
		
		exit {
		}
		do goto target: target on: roadNetwork;
	}
	
	state awaiting_autonomousBike {
	    enter {

	    }
	    
	    transition to: isolated_transition when: dead(autonomousBikeToRide) or autonomousBikeToRide = nil;
	    //transition to: finished when: autonomousBikeToRide = nil{do die;}
	    
	    
	    //cuando hace la transición a que se usa la bicicleta se toma el tiempo desde que entró hasta que se tomó la bicicleta
	    transition to: riding_autonomousBike when: autonomousBikeToRide.state = "in_use_people" {
	        int current_hour <- current_date.hour;
	        int current_minute <- current_date.minute;
	        
	        if start_wait_hour < current_hour {
	            timeWaiting <- (current_hour * 60 + current_minute) - (start_wait_hour * 60 + start_wait_min);
	        } else if start_wait_hour = current_hour {
	            timeWaiting <- current_minute - start_wait_min;
	        } else {
	            timeWaiting <- (current_hour * 60 + current_minute) + (24 * 60 - (start_wait_hour * 60 + start_wait_min));
	        }
	        
	        if length(timeList) = 20 {
	            remove from: timeList index: 0;
	        }
	        timeList <- timeList + timeWaiting;
	        
	        avgWait <- sum(timeList) / length(timeList);
	        target <- nil; // Este es el lugar correcto para limpiar el objetivo antes de la transición.
	    }
	    
	    exit {

	    }
	}
	
	

	
	
	state lastmile {
		enter{
			if !autonomousScenario{
				startLastMileHour <- current_date.hour;
				startLastMileMinute <- current_date.minute;
			}
			
		    //write "ESTADO LASTMILE: agente "+self+"con rider "+self.regularBikeToRide;
		
		}
		transition to:finished when: location=target{
			 tripdistance <-  host.distanceInGraph(self.start_point, self.target_point);
			 
			float now <- current_date.hour * 60 + current_date.minute;
			float start <- startLastMileHour * 60 + startLastMileMinute;

			if (startLastMileHour > current_date.hour) {
				// caso donde pasó de un día a otro
				timeLastMile <- now + (24 * 60 - start);
			} else {
				timeLastMile <- now - start;
			}
		
			// Agregar a la lista de caminatas
			if length(timeListLastMile) = 20 {
				remove from:timeListLastMile index: 0;
			}
			timeListLastMile <- timeListLastMile + timeLastMile;
		
			// Calcular promedio
			avgLastMile <- sum(timeListLastMile) / length(timeListLastMile);
		}
		
		do goto target: target on: roadNetwork;
		
		exit {
			
		}
		
	}
	
	state finished {
		enter{
		    //write "ESTADO FINISHED: agente "+self+"con rider "+self.regularBikeToRide;
		/* 
			tripdistance <- host.distanceInGraph(self.start_point, self.target_point);
			if start_h < initial_hour {
				timeWaiting <- float(current_date.hour*60 + current_date.minute) - (initial_hour*60 + initial_minute);
			} else if (start_h = initial_hour) and (start_min < initial_minute){
				timeWaiting <- float(current_date.hour*60 + current_date.minute) - (initial_hour*60 + initial_minute);
			} else if start_h > current_date.hour {
				timeWaiting <- float(current_date.hour*60 + current_date.minute) + (24*60 - (start_h*60 + start_min));
				//write(timeWaiting);		
			} else {
				timeWaiting <- float(current_date.hour*60 + current_date.minute) - (start_h*60 + start_min);
			}
			if length(timeList) = 20{
				remove from:timeList index:0;
			} timeList <- timeList + timeWaiting;
			loop while: length(timeList) = 20{
				moreThanWait <- 0;
				avgWait <- 0.0;
				loop i over: timeList{
					if i > 40{
						moreThanWait <- moreThanWait + 1;
					} 
					avgWait <- avgWait + i;
				} avgWait <- avgWait/20; //average
				return moreThanWait;
			}
			
			*/
			
		}
		do die;
	}
	
	state isolated_transition{
		enter{
			do die;
		}
			
	}
}


// *******************************************    BIKES    ******************************************************************

species autonomousBike control: fsm skills: [moving] {
	
	 //----------------ATTRIBUTES-----------------
	
	    
	//Person/package info
	people rider;

	int activity; //0=Package 1=Person

	
	//dynamic attributes for rebalancing
	int last_trip_day <- 7;
	int last_trip_h <- 12;
	
	//movement
	point target;
	float batteryLife; 
	float distancePerCycle;
	float distanceTraveledBike;
	path travelledPath; 
	
	
	//visual aspect
	rgb color;
	map<string, rgb> color_map <- [
		"wandering"::#cyan,
		
		"low_battery":: #red,
		"getting_charge":: #red,

		"picking_up_people"::#mediumpurple,
		"picking_up_packages"::#gold,
		"in_use_people"::#mediumslateblue,
		"in_use_packages"::#yellow,
		
		"rebalancing"::#orange
	];
	aspect realistic {
		color <- color_map[state];
		if state != "newborn"{
			draw triangle(50) color:color border:color rotate: heading + 90 ;
		}else{
			draw circle(100) color:#pink border:#pink rotate: heading + 90 ;
		}	
	}
	
	/* ---------------- PUBLIC FUNCTIONS ---------------- */ 
	
	bool availableForRideAB {
		return  (self.state="wandering" or self.state="rebalancing" or self.state = 'newborn') and !setLowBattery() and rider = nil;
	}
	
	

	action pickUp(people person) { 
			rider <- person;
			activity <- 1;
	}
	

	/* ---------------- PRIVATE FUNCTIONS ---------------- */
	
	
	// ----- Movement ------
	bool canMove {
		return ((target != nil and target != location)) and batteryLife > 0;
	}
	
	path moveTowardTarget {
			return goto(on:roadNetwork, target:target, return_path: true, speed:DrivingSpeedAutonomousBike);
	}
	
	reflex move when: canMove()  {	
		
		travelledPath <- moveTowardTarget();
		
		float distanceTraveled <- host.distanceInGraph(travelledPath.source,travelledPath.target);
		
		do reduceBattery(distanceTraveled);
	}
	
	// ----- Battery ------
	
	bool setLowBattery { 
		if batteryLife < minSafeBatteryAutonomousBike { return true; } 
		//else if rechargeNeeded() { return true;}
		else {
			return false;
		}
	}
	
	float energyCost(float distance) {
		return distance;
	}
	
	action reduceBattery(float distance) {
		batteryLife <- batteryLife - energyCost(distance); 
	}
	

	// ----- Rebalancing ------
	bool rebalanceNeeded{
			//if latest move was more than 12 h ago
			if last_trip_day = current_date.day and  (current_date.hour  - last_trip_h) > 12 {
				return true;
				
			} else if last_trip_day < current_date.day and  (current_date.hour  + (24 - last_trip_h)) > 12 {
				return true;
				
			}else{
				return false;
			}
	}
	

				
	/* ========================================== STATE MACHINE ========================================= */
	//aquí he puesto el estado en el que se realiza el count
	
	state newborn initial: true {
		   enter {

        }
        transition to: fleetsize { fleetsizeCountBike <- fleetsizeCountBike - 1; } 
		/*enter{
			int h <- current_date.hour;
			int m <- current_date.minute;
			int s <- current_date.second;
		}*/
		//transition to: wandering when: (current_date.hour = h and (current_date.minute + (current_date.second/60)) > (m + 15/60)) or (current_date.hour > h and (60-m+current_date.minute + (current_date.second/60))> 15/60);
	}
	
	state fleetsize {
		enter{ 
// The bike is removed if the slider is lowered.
			if totalCount > numAutonomousBikes{
				totalCount <- totalCount-1;
				//write "died";
				//write totalCount;
				do die;
				}
				
// The bike is removed if the scenario changes.
			else if !autonomousScenario{
				totalCount <- totalCount-1;
				//write "died";
				//write totalCount;
				do die;
			}
		}
			transition to: wandering;
	}
	
	state wandering {
	//state wandering initial: true{
		enter {
			wanderCountbike<-wanderCountbike+1;
			target <- nil;
			
		}
		transition to: picking_up_people when: rider != nil and activity = 1 {pickUpCountBike<-pickUpCountBike+1;wanderCountbike<-wanderCountbike-1;} //If no bidding
		transition to: low_battery when: setLowBattery() {wanderCountbike<-wanderCountbike-1;lowChargeCount<-lowChargeCount+1;}
		transition to: fleetsize when: (totalCount > numAutonomousBikes or !autonomousScenario) and rider = nil {wanderCountbike<- wanderCountbike - 1;}
		exit {
				
		}
	}

	
	state low_battery {
		enter{
			target <- (chargingStation closest_to(self)).location; 
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
		
		}
		transition to: getting_charge when: location = target {lowChargeCount<-lowChargeCount-1;getChargeCount<-getChargeCount+1;}
		exit {
		}
	}
	
	state getting_charge {
		enter {
	
			target <- nil;
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge + myself;
			}
		}
		transition to: fleetsize when: batteryLife >= maxBatteryLifeAutonomousBike { getChargeCount <- getChargeCount - 1;}
		exit {
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge - myself;}
		}
	}
				
	state picking_up_people {
			enter {
				if dead(rider) or rider = nil{
					do die;
				}
				else{
					try{
						//TODOSometimes the rider is still dead and this situation gives an error
						if !dead(rider){
							target <- rider.target;
							point target_intersection <- roadNetwork.vertices closest_to(target);
							distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
						}
						
					}
					catch{
						do die;
					}
				}
			}
			transition to: in_use_people when: (location=target and rider.location=target) {inUseCountBike<-inUseCountBike+1;pickUpCountBike<-pickUpCountBike-1;}
			exit{
				
			}
	}	
	
	state in_use_people {
		enter {
			
			target <- (road closest_to rider.final_destination).location;
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);

		}
		transition to: fleetsize when: location=target {
			deliverycount <- deliverycount + 1;
			inUseCountBike<-inUseCountBike-1;
			rider <- nil;
			 
			//Save this time for rebalancing
			last_trip_day <- current_date.day;
			last_trip_h <- current_date.hour;
		}
		exit {
		}
	}
	
}



species regularBike control: fsm skills: [moving] {
	
	 //----------------ATTRIBUTES-----------------
	
	    
	//Person/package info
	people rider;
	int activity <- 1; 

 
 	//movement
	point target;
	float batteryLife; 
	float distancePerCycle;
	float distanceTraveledBike;
	path travelledPath; 
	station current_station;
	
	
	//visual aspect
	rgb color;
	map<string, rgb> color_map <- [
		
		"low_battery":: #red,
		"getting_charge":: #red,
		
		"at_station":: #green,

		"picking_up_people"::#mediumpurple,
		"in_use_people"::#mediumslateblue,
		
		"rebalancing"::#orange
	];
	aspect realistic {
		color <- color_map[state];
		if state != "newborn"{
			draw triangle(50) color:color border:color rotate: heading + 90 ;
		}else{
			draw circle(100) color:#pink border:#pink rotate: heading + 90 ;
		}	
	}
	
	/* ---------------- PUBLIC FUNCTIONS ---------------- */ 
	
	//ESTA FUNCIÓN PUEDE QUE SOBRE
	bool availableForRideAB {
		return  (self.state="wandering" or self.state="rebalancing" or self.state = 'newborn') and !setLowBattery() and rider = nil;
	}
	


	action pickUp(people person) { 

			rider <- person;
			activity <- 1;
			//write "entro en pickUp" + person;
	}
	

	/* ---------------- PRIVATE FUNCTIONS ---------------- */
	
	
	// ----- Movement ------
	bool canMove {
		return ((target != nil and target != location)) and batteryLife > 0; //agregue condición and rider!=nil
	}
	
	//parece ser que aquí no se necesita esta función
	path moveTowardTarget {
			return goto(on:roadNetwork, target:target, return_path: true, speed:DrivingSpeedRegularBike);
	}
	
	reflex move when: canMove()  {	
		//write "SI ESTÁ HACIENDO EL REFLEX";
		travelledPath <- moveTowardTarget();
		
		float distanceTraveled <- host.distanceInGraph(travelledPath.source,travelledPath.target);
		
		do reduceBattery(distanceTraveled);
	}
	
	// ----- Battery ------
	
	bool setLowBattery { 
		if batteryLife < minSafeBatteryAutonomousBike { return true; } 
		//else if rechargeNeeded() { return true;}
		else {
			return false;
		}
	}
	
	float energyCost(float distance) {
		return distance;
	}
	
	action reduceBattery(float distance) {
		batteryLife <- batteryLife - energyCost(distance); 
	}
	
				
	/* ========================================== STATE MACHINE ========================================= */
	//aquí he puesto el estado en el que se realiza el count
	
	state newborn initial: true {
		   
		   enter {
		   //DUDA CON NAROA (ESTO VA AQUÍ O EN AT STATION PORQUE NO TENGO MUY CLARO COMO AFECTA A LOS COUNTERS)(PENDING TASK)   	
		   	
		   	//Comprobar las estaciones que tienen huecos y asignar la bicicleta a la estación que tenga huecos mas cercana
		   	
		   
		   	list<station> estaciones_huecos <- station where each.SpotsAvailableStation();
		   	//write estaciones_huecos;
		   	//write "estaciones huecos tiene" + length(estaciones_huecos);
			if empty(estaciones_huecos) {
				write "There are more bikes than slots"; 
			}
			location <- point(one_of(estaciones_huecos)); //Location in a station
			//write self.location;
			
		   	self.current_station <- station closest_to(location);
		   	ask self.current_station {
				bikesInStation <- bikesInStation + myself;
			}
			
			
        }
        transition to: fleetsizeRB;
}

	state fleetsizeRB{
		enter {
			//write totalCountRB;
			//write numRegularBikes;
			
			//Reducing number of bikes (within the same scenario)
			if totalCountRB > numRegularBikes{
				if (self.rider = nil){
					if current_station != nil{ //Added this bcs othwerise sometimes raised an error too
						ask self.current_station {
							bikesInStation <- bikesInStation - myself;
							write myself.current_station;
							write bikesInStation;
							write myself;
						}
					}
					totalCountRB <- totalCountRB-1;
					//availableCountBike <- availableCountBike-1;
					
					//write "died now";
					//write totalCountRB;
					do die;
				}
				else{
					//write "se estaba usando";
				}

			}	
			//Scenario Change (do die of all the bikes)
			else if autonomousScenario{
				if(self.rider = nil){
					ask self.current_station {
						bikesInStation <- bikesInStation - myself;
						//write bikesInStation;
						//write myself;
					}
					totalCountRB <- totalCountRB-1;
					//write "died";
					//write totalCountRB;
					do die;
				}
				else{
			//write "it was in use";
				}
			}
		}	
        transition to: at_station  { fleetsizeCountBike <- fleetsizeCountBike - 1; } 	
	}
	
	
	state at_station {
	//state wandering initial: true{
		enter {
			target <- nil;
			availableCountBike <- availableCountBike+1;
			
		}
		transition to: pickedup when: rider != nil {pickUpCountBike<-pickUpCountBike+1;
			ask station closest_to(self) {
			    if (myself in bikesInStation) {
			        bikesInStation <- bikesInStation - myself;
			        salidas <- salidas + 1;
			    }
			}
		}
		transition to: fleetsizeRB when: (totalCountRB > numRegularBikes or autonomousScenario) and rider = nil {}
		exit {
				
		}
	}

	
	state pickedup {
			enter {
				availableCountBike <- availableCountBike-1;
				inuseCountBike <- inuseCountBike+1;
					
			}
			transition to: in_use_people when: rider.end_station != nil {
				inUseCountBike<-inUseCountBike+1;pickUpCountBike<-pickUpCountBike-1;
			}
			exit{
				
			}
	}	
	
// There might be a problem here (it's taking the final destination of the trip as the target, not the stop).
	state in_use_people {
		enter {
			
			//target <- rider.end_station.location;
			
			if dead(rider.end_station){
				ask rider{
					do die;
				}
	
			}
			if dead(rider){
				do die;
			}
			target <- rider.end_station.location;	
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
		//write "BICICLETA"+self+ "STATE IN USE PEOPLE "+ target;
		}
		transition to: dropoffbike when: location=target{
		}
		
		exit {
		}
	}
	
	state dropoffbike { 
		enter{
			inuseCountBike <- inuseCountBike+1;
		//write "BICICLETA"+self+ "DROPOFFBIKE "+ target;	
		}
		transition to: at_station when: rider.regularBikeToRide=nil{	
			//write "ESTE ES EL RIDER"+rider;
			//write rider.end_station;
				
			ask rider.end_station{
				bikesInStation <- bikesInStation + myself;
				entradas <- entradas + 1;
			}
			//deliverycount <- deliverycount + 1;
			inUseCountBike<-inUseCountBike-1;
			rider <- nil;
		}
		
		transition to: in_use_people when: rider.state= "chooseEndStation"{
		}
		//esto cambia algo?
		exit {
		}		
	}
	
}

