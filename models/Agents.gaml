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
 	///////---------- WAIT TIME VARIABLES (PARA HACER EL PLOT DE AVG WAIT TIME --------------///////
	//int lessThanWait <- 0;
	int moreThanWait <- 0;
	float timeWaiting <- 0.0;
	float avgWait <- 0.0;
	list<float> timeList <- []; //list of wait times
	
	       //...variables initial_hour initial_minute
	int initial_hour;
	int initial_minute;
	
		   //...inicio de tiempos de espera (la misma que arriba pero corregida)
	int start_wait_hour;
	int start_wait_min;
	
	 //VARIABLES PARA CONTEO DE SERVED Y UNSERVED (ESCENARIO AUTÓNOMO)
	int deliverycount <- 0;
	int unservedcount<-0;
	
	//VARIABLESL PARA CONTEO DE SERVED Y UNSERVED (ESCENARIO REGULAR)
	int deliverycountreg <- 0;
	int unservedcountreg <-0;
	
	//tamaño de los hexágonos de las estaciones
	int sizeX <- 40;
	int sizeY <- 40;
	rgb currentColor <- #darkorange;
	
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
	int wanderCoutRegular <- 0;
	int lowChargeCountRegular<- 0; //lowbattery, lowfuel for electric, combustion
	int pickUpCountRegular <- 0;
	int inUseCountRegular <- 0;
	int fleetsizeCountRegular <- 0;
	int totalCountRB;
	
	// Initial values storage of the simulation
	int initial_ab_number <- numAutonomousBikes;
	float initial_ab_battery <- maxBatteryLifeAutonomousBike;
	float initial_ab_speed <- RidingSpeedAutonomousBike;
	string initial_ab_recharge_rate <- V2IChargingRate;
	
	
	///////VEHICLE REQUESTS - NO BIDDING - REGULAR BIKES ------------///////

bool RequestRealBike(people person) { 
    // Obtener la lista de todas las estaciones
    list<station> availableStations <- station where each.BikesAvailableStation(); 
	if availableStations = nil{
		//write "no hay estaciones con bicis";
		return false;
	}      
   // Obtener el punto más cercano a la persona en el grafo
   point personIntersection <- roadNetwork.vertices closest_to(person);

    // Obtener la estación más cercana a la persona
    station closestStation <- availableStations closest_to(personIntersection);

    // NO ESTOY SEGURO SI EN ESTE ESCENARIO ENTRA LA CONDICIÓN DE DISTANCIA
    float d <- distanceInGraph(personIntersection, closestStation.location);

    // Si la estación está demasiado lejos
    //cambiar maxdistancepeople a la de regular scenario
    if (d > person.maxDistancePeople_AutonomousBike) {
        //write "STATION TOO FAR";
        return false;
    }
    person.target <- closestStation.location;
    person.start_station<-closestStation;
    return true;
 }
    
 //EL RESTO DE FUNCIONES LAS PASO A PERSON
 
 //ESTA ES LA FUNCION DE PICKUP BIKE
  /*         // Filtrar las bicicletas disponibles en la estación más cercana
        list<regularBike> availableBikes <- start_station.bikesInStation;
        regularBike bike <- first(availableBikes); // Tomamos la primera bicicleta disponible

        // Mover a la persona hacia la estación más cercana
        
        ask person {
            do rideRB(bike); // La persona usa la bicicleta
        }

      */


	


	
 
 	///////---------- VEHICLE REQUESTS - NO BIDDING --------------///////
	bool requestAutonomousBike(people person) { 
	 
	 	//Get list of available vehicles
		list<autonomousBike> available <- (autonomousBike where each.availableForRideAB());
		
		//If no bikes available 
		if empty(available){
			//write 'NO BIKES AVAILABE';
			return false;
		}
		
		if person != nil{ //People demand
		
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

		} else { 
			write 'Error in request bike'; //Because no one made this request
			return false;
		}
			
		
	}
	
	bool requestRegularBike(people person) {
		station assignedStation <- person.start_station;
		if (assignedStation = nil){
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
	
	int chargingStationCapacity; 
	
	aspect base{
		draw hexagon(15,15) color:color border:#black;
	}
	
	reflex chargeBikes {
		ask chargingStationCapacity first autonomousBikesToCharge {
			batteryLife <- batteryLife + step*V2IChargingRate;
		}
	}
}


species station {
	
	list<regularBike> bikesInStation;
	
	float lat;
	float lon;
	
	int capacity; 
	
	int rebalanceo;
	
		aspect base{
		draw hexagon(sizeX,sizeY) color:currentColor border:#black;
	}
	
	reflex chargeBikes {
		ask bikesInStation {
			if batteryLife < maxBatteryLife{
			batteryLife <- batteryLife + step*V2IChargingRate;
			}
		}
	}
	
/* reflex rebalanceo{
 * quita una bicicleta de la estación con más bicicletas o con menos counters y se la agrega a la lista
 hay que estar pendiente de los asks.
 */ 
	
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
	
	action rebalanceando(station s){
		//TODO pendiente hacer algo con el aspecto de la station para que se vea cual hizo el rebalanceo.
	}
	
}



// *******************************************    PEOPLE    ******************************************************************

species people control: fsm skills: [moving] {


 //----------------ATTRIBUTES-----------------

	
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
    float maxDistancePeople_AutonomousBike <- 2000 #m;
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
        list<station> all_stations <- station;
        station closest_station <- all_stations closest_to(self);
        	if (!closest_station.BikesAvailableStation()) {
            	ask closest_station {
               	 rebalanceo <- rebalanceo + 1;
               	 write rebalanceo;
                 if (rebalanceo >= 3 and numRegularBikes = primero) {
                 	//esto se hace por si bajo el slider y evitar que aparezcan las bicicletas que quite en la lista.	
                 	//primero espera a que se quiten todas las bicicletas para que no aparezca ninguna bicicleta en estado /*death*/
                 	//write numRegularBikes;
                 	//TODO is la estacion que voy a rebalancear tiene menos de 3 bicicletas no cuenta el counter
                 	rebalanceo <- 0;
					list<station> stations_with_bikes <- station where each.BikesAvailableStation();
					if (length(stations_with_bikes) > 0) {
					    int max_bikes <- max_of(stations_with_bikes, length(each.bikesInStation));
					    list<station> stations_with_max_bikes <- stations_with_bikes where each.ReachedRebalanceo(max_bikes);
					    station station_with_most_bikes <- one_of(stations_with_max_bikes);
					    write "Estación con más bicicletas: " + max_bikes+ station_with_most_bikes;
					    write station_with_most_bikes.bikesInStation;
					    regularBike bike_rebalanceo <- last(station_with_most_bikes.bikesInStation);
					    station_with_most_bikes.bikesInStation <- station_with_most_bikes.bikesInStation - bike_rebalanceo;
					    bike_rebalanceo.location <- closest_station.location;      
					    closest_station.bikesInStation <- closest_station.bikesInStation + bike_rebalanceo;
					    write "Estación ahora: "+ closest_station.bikesInStation;
					    write "Estación cambio: "+station_with_most_bikes.bikesInStation;
					    ask closest_station {
    						do rebalanceando(myself);
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
	        end_station <- available_stations closest_to(target_point);	
	        target <- end_station.location;
		}
		transition to: riding_regularBike when: !autonomousScenario and target = end_station.location; // Si se encuentra una estación válida
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
	            target <- nil; 
			}else{
				self.regularBikeToRide <- nil;
					//write "Si hay huecos para dejar la bici";
			}
		}
		
		transition to: chooseEndStation when: !autonomousScenario and target = nil{
			//write "DE VUELTA A CHOOSE END STATION: " +self;	    
		}

		transition to: lastmile when: !autonomousScenario and self.regularBikeToRide=nil{
			//write "transition to lastmile de agente: " +self;	    
		}
	
	}
	
	state firstmile {
		enter{
		//write "ESTADO FIRSTMILE: agente "+self+"con rider "+self.regularBikeToRide;
			
		}
		transition to: awaiting_autonomousBike when: autonomousScenario and location=target{}
		transition to: pickUpBike when: !autonomousScenario and location=target{}
	    //write "transition to pickupBike de agente: " +self;	    
		
		exit {
		}
		do goto target: target on: roadNetwork;
	}
	
	state awaiting_autonomousBike {
	    enter {
	        start_wait_hour <- current_date.hour;
	        start_wait_min <- current_date.minute;
	    }
	    
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
		    //write "ESTADO LASTMILE: agente "+self+"con rider "+self.regularBikeToRide;
		
		}
		transition to:finished when: location=target{
			 tripdistance <-  host.distanceInGraph(self.start_point, self.target_point);
		}
		exit {
		}
		do goto target: target on: roadNetwork;
	}
	
	state finished {
		enter{
		    //write "ESTADO FINISHED: agente "+self+"con rider "+self.regularBikeToRide;
		
			tripdistance <- host.distanceInGraph(self.start_point, self.target_point);
/* conditions to keep track of wait time for packages */
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
			/* loop(s) to find moving average of last 10 wait times */
			if length(timeList) = 20{
				remove from:timeList index:0;
			} timeList <- timeList + timeWaiting;
			loop while: length(timeList) = 20{
				moreThanWait <- 0;
				avgWait <- 0.0;
				/* the loop below is to count the number of packages delivered under/over 40 minutes, represented in a pie chart (inactive) */
				loop i over: timeList{
					if i > 40{
						moreThanWait <- moreThanWait + 1;
					} 
					avgWait <- avgWait + i;
				} avgWait <- avgWait/20; //average
				return moreThanWait;
			}
		}
		do die;
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
            /*if fleetsizeCountBike + wanderCountbike + lowChargeCount + getChargeCount + RebalanceCount + pickUpCountBike + inUseCountBike > numAutonomousBikes{
                fleetsizeCountBike <- fleetsizeCountBike - 1;
                do die;
            }*/
        }
        transition to: fleetsize { fleetsizeCountBike <- fleetsizeCountBike - 1; wanderCountbike <- wanderCountbike + 1; } 
		/*enter{
			int h <- current_date.hour;
			int m <- current_date.minute;
			int s <- current_date.second;
		}*/
		//transition to: wandering when: (current_date.hour = h and (current_date.minute + (current_date.second/60)) > (m + 15/60)) or (current_date.hour > h and (60-m+current_date.minute + (current_date.second/60))> 15/60);
	}
	
	state fleetsize {
		enter{ 
			//se quita la bicicleta si el slider se baja.
			if totalCount > numAutonomousBikes{
				totalCount <- totalCount-1;
				//write "died";
				//write totalCount;
				do die;
				}
				
				//se quita la bicicleta si se cambia de escenario.
			else if !autonomousScenario{
				totalCount <- totalCount-1;
				//write "died";
				//write totalCount;
				do die;
			}
		}
			transition to: wandering;
	}
		//DUDA NAROA ( SOLO PUEDEN QUITARSE BICICLETAS SI ESTÁN EN ESTE ESTADO?)... puede ser por esto que se tarden en quitarse
	
	state wandering {
	//state wandering initial: true{
		enter {
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
		transition to: fleetsize when: batteryLife >= maxBatteryLifeAutonomousBike { getChargeCount <- getChargeCount - 1; wanderCountbike <- wanderCountbike + 1;}
		exit {
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge - myself;}
		}
	}
			
	state picking_up_people {
			enter {
				target <- rider.target;
				
				point target_intersection <- roadNetwork.vertices closest_to(target);
				distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
				
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
			inUseCountBike<-inUseCountBike-1;wanderCountbike<-wanderCountbike+1;
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
		   	
		   //DUDA CON NAROA (ESTO VA AQUÍ O EN AT STATION PORQUE NO TENGO MUY CLARO COMO AFECTA A LOS COUNTERS)
		   //cuando se crean las bicicletas las crea en la location de una estación pero no se actualiza la lista de bicicletas (esto solucionado)
		   	
		   	
		   	//Comprobar las estaciones que tienen huecos y asignar la bicicleta a la estación que tenga huecos mas cercana
		   	//si todas las estaciones están llegnas, mostrar mensaje
		   	
		   	
		   	list<station> estaciones_huecos <- station where each.SpotsAvailableStation();	
			if empty(estaciones_huecos) {
				//write "Hay mas bicis que huecos";
			}
			location <- point(one_of(estaciones_huecos)); //Location in a station
			
		   	self.current_station <- station closest_to(location);
		   	ask self.current_station {
				bikesInStation <- bikesInStation + myself;
			}
				

			//Primero

            /*if fleetsizeCountBike + wanderCountbike + lowChargeCount + getChargeCount + RebalanceCount + pickUpCountBike + inUseCountBike > numAutonomousBikes{
                fleetsizeCountBike <- fleetsizeCountBike - 1;
                do die;
            }*/
        }
        transition to: fleetsizeRB;
}

	state fleetsizeRB{
		enter {
			//write totalCountRB;
			write numRegularBikes;
			if totalCountRB > numRegularBikes{
				totalCountRB <- totalCountRB-1;
				write "died";
				write totalCountRB;
				if (self.rider = nil){
				ask self.current_station {
					bikesInStation <- bikesInStation - myself;
				}
					do die;
					
				}
				else{
					//write "se estaba usando";
				}

				}
				
				//se quita la bicicleta si se cambia de escenario.
			else if autonomousScenario{
				totalCountRB <- totalCountRB-1;
				write "died";
				write totalCountRB;
				if(self.rider = nil){
					ask self.current_station {
					bikesInStation <- bikesInStation - myself;
					}
					do die;
				}
				else{
					write "se estaba usando";
				}
			}
		}	
        transition to: at_station  { fleetsizeCountBike <- fleetsizeCountBike - 1; wanderCountbike <- wanderCountbike + 1; } 	
	}
	
	
	state at_station {
	//state wandering initial: true{
		enter {
			target <- nil;
		}
		transition to: pickedup when: rider != nil {pickUpCountBike<-pickUpCountBike+1;wanderCountbike<-wanderCountbike-1;
			ask station closest_to(self) {
			    if (myself in bikesInStation) {
			        bikesInStation <- bikesInStation - myself;
			    }
			}
		}
		transition to: fleetsizeRB when: (totalCountRB > numRegularBikes or autonomousScenario) and rider = nil {wanderCountbike<- wanderCountbike - 1;}
		exit {
				
		}
	}

	
	state pickedup {
			enter {	
			}
			transition to: in_use_people when: rider.end_station != nil {
				inUseCountBike<-inUseCountBike+1;pickUpCountBike<-pickUpCountBike-1;
			}
			exit{
				
			}
	}	
	
	//puede haber un problema aquí (está tomando como target la ubicación final del viaje y no la parada)
	state in_use_people {
		enter {
			
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
		//write "BICICLETA"+self+ "DROPOFFBIKE "+ target;	
		}
		transition to: at_station when: rider.regularBikeToRide=nil{	
			//write "ESTE ES EL RIDER"+rider;
			//write rider.end_station;
				
			ask rider.end_station{
				bikesInStation <- bikesInStation + myself;
			}
			//deliverycount <- deliverycount + 1;
			inUseCountBike<-inUseCountBike-1;
			wanderCountbike<-wanderCountbike+1;
			rider <- nil;
		}
		
		transition to: in_use_people when: rider.state= "chooseEndStation"{
		}
		//esto cambia algo?
		exit {
		}		
	}
	
}

/////////////////// NETWORKING AGENT ////////////

species NetworkingAgent skills:[network] {
	
	int AB_num_slider <- 30;
	int AB_size_slider <- 30;
	int AB_speed_slider <- 30;
	int NB_num_slider <- 30;
	int NB_speed_slider <- 30;

	int scenario_button <- 0;
	
	reflex when:has_more_message() {
		
		loop while:has_more_message(){
			message mes <- fetch_message();
			write "mensaje total";
			write mes.contents;
						
			list mes_filter <- string(mes.contents) split_with('[,]');
			
			list mes_filter_0 <- string(mes_filter[1]) split_with('[,]');
			list mes_filter_1 <- string(mes_filter[2]) split_with('[,]');
			list mes_filter_2 <- string(mes_filter[3]) split_with('[,]');
			list mes_filter_3 <- string(mes_filter[4]) split_with('[,]');
			list mes_filter_4 <- string(mes_filter[5]) split_with('[,]');
			list mes_filter_5 <- string(mes_filter[6]) split_with('[,]');
			
			list slider0 <- string(mes_filter_0) split_with('[:]');
			string source_string_s0 <- replace(slider0[0],"'","");
			int source_s0 <- int(source_string_s0);
			string value_string_s0 <- replace(slider0[1],"'","");
			int value_s0 <- int(value_string_s0);
			
			list slider1 <- string(mes_filter_1) split_with('[:]');
			string source_string_s1 <- replace(slider1[0],"'","");
			int source_s1 <- int(source_string_s1);
			string value_string_s1 <- replace(slider1[1],"'","");
			int value_s1 <- int(value_string_s1);
			
			list slider2 <- string(mes_filter_2) split_with('[:]');
			string source_string_s2 <- replace(slider2[0],"'","");
			int source_s2 <- int(source_string_s2);
			string value_string_s2 <- replace(slider2[1],"'","");
			int value_s2 <- int(value_string_s2);
			
			list slider3 <- string(mes_filter_3) split_with('[:]');
			string source_string_s3 <- replace(slider3[0],"'","");
			int source_s3 <- int(source_string_s3);
			string value_string_s3 <- replace(slider3[1],"'","");
			int value_s3 <- int(value_string_s3);
			
			list slider4 <- string(mes_filter_4) split_with('[:]');
			string source_string_s4 <- replace(slider4[0],"'","");
			int source_s4 <- int(source_string_s4);
			string value_string_s4 <- replace(slider4[1],"'","");
			int value_s4 <- int(value_string_s4);
			
			list button <- string(mes_filter_5) split_with('[:]');
			string source_string_s5 <- replace(button[0],"'","");
			int source_s5 <- int(source_string_s5);
			string value_string_s5 <- replace(button[1],"'","");
			int value_s5 <- int(value_string_s5);
 			
 			if source_s0 = 0 and value_s0 != AB_num_slider {
 				numAutonomousBikes <- value_s0*40;
 				AB_num_slider <- value_s0;
 			} else if source_s1 = 1 and value_s1 != AB_size_slider{
 				maxBatteryLifeAutonomousBike <- 300.0-value_s1*10;
 				AB_size_slider <- value_s1;
 			} else if source_s2 = 2 and value_s2 != AB_speed_slider {
 				DrivingSpeedAutonomousBike <- (20-value_s2)/3.6;
 				AB_speed_slider <- value_s2;
 			} else if source_s3 = 3 and value_s3 != NB_num_slider{
 				numRegularBikes <- value_s3*40;
 				NB_num_slider <- value_s3;
 			} else if source_s4 = 4 and value_s4 != NB_speed_slider{
 				DrivingSpeedRegularBike <- (20-value_s4)/3.6;
 				NB_speed_slider <- value_s4;
 			} else if source_s5 = 5 and value_s5 != scenario_button {
 				if value_s5 = 0 {
 					autonomousScenario <- true;
 					
 				} else if value_s5 = 1 {
 					autonomousScenario <- false;
 				}
 				scenario_button <- value_s5;
 			}
		}
	}
}

