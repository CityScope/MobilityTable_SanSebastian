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
	
	 //VARIABLES PARA CONTEO DE SERVED Y UNSERVED 
	int deliverycount <- 0;
	int unservedcount<-0;
	
	//autonomous bike count variables, used to create series graph in multifunctionalvehiclesvisual experiment
	int wanderCountbike <- 0;
	int lowChargeCount <- 0; //lowbattery, lowfuel for electric, combustion
	int getChargeCount <- 0; //getcharge, getfuel for electric, combustion
	int pickUpCountBike <- 0;  
	int inUseCountBike <- 0; //en este caso este contador se está usando?
	int fleetsizeCountBike <- 0;
	int numauonomoousbike <- 0;
	int RebalanceCount <- 0; 
	int biddingCount <-0;
	int endbidCount<-0;
 
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
	
	reflex chargeBikes {
		ask bikesInStation {
			if batteryLife < maxBatteryLife{
			batteryLife <- batteryLife + step*V2IChargingRate;
			}
		}
	}
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
    
    //dynamic attributes
    float tripdistance <- 0.0; 
    point target;
    int queueTime;
    int bidClear;
    //float dynamic_maxDistancePeople <- maxDistancePeople_AutonomousBike;
    float maxDistancePeople_AutonomousBike <- 2000 #m;
    bool created_bike <- false;
    
    //visual aspect
   	rgb color;
    map<string, rgb> color_map <- [
    	"wandering":: #transparent,
		"requestingAutonomousBike":: #mediumslateblue,
		"awaiting_autonomousBike":: #mediumslateblue,
		"riding_autonomousBike":: #mediumslateblue,
		"firstmile":: #mediumslateblue,
		"lastmile":: #mediumslateblue
	];
    aspect base {
    	color <- color_map[state];
    	draw circle(7) color: color border: #black;
    }
    
    
   	/* ---------------- FUNCTIONS ---------------- */
	
    action ride(autonomousBike ab) {
    	if ab!=nil{
    		autonomousBikeToRide <- ab;
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
    	transition to: requestingAutonomousBike when: timeToTravel(){ //Flow if bidding is NOT enabled: requestingAutonomousBike --> firstmile
    		final_destination <- target_point;
    	}
    	exit {
		}
    }
    
    //If bidding not enabled
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
    
   	//TODO: Add state to walk to station if regular bikes

	
	state firstmile {
		enter{
		}
		transition to: awaiting_autonomousBike when: location=target{}
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
	
	
	state lastmile {
		enter{
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
			draw triangle(15) color:color border:color rotate: heading + 90 ;
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
	
		if (state="in_use_people"){
			return goto(on:roadNetwork, target:target, return_path: true, speed:RidingSpeedAutonomousBike);
		}
		else{
			return goto(on:roadNetwork, target:target, return_path: true, speed:DrivingSpeedAutonomousBike);
		}
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
            if fleetsizeCountBike + wanderCountbike + lowChargeCount + getChargeCount + RebalanceCount + pickUpCountBike + inUseCountBike > numAutonomousBikes{
                fleetsizeCountBike <- fleetsizeCountBike - 1;
                do die;
            }
        }
        transition to: wandering { fleetsizeCountBike <- fleetsizeCountBike - 1; wanderCountbike <- wanderCountbike + 1; } 
		/*enter{
			int h <- current_date.hour;
			int m <- current_date.minute;
			int s <- current_date.second;
		}*/
		//transition to: wandering when: (current_date.hour = h and (current_date.minute + (current_date.second/60)) > (m + 15/60)) or (current_date.hour > h and (60-m+current_date.minute + (current_date.second/60))> 15/60);
	}
	state wandering {
	//state wandering initial: true{
		enter {
			target <- nil;
		}
		transition to: picking_up_people when: rider != nil and activity = 1 {pickUpCountBike<-pickUpCountBike+1;wanderCountbike<-wanderCountbike-1;} //If no bidding
		transition to: low_battery when: setLowBattery() {wanderCountbike<-wanderCountbike-1;lowChargeCount<-lowChargeCount+1;}
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
		transition to: wandering when: batteryLife >= maxBatteryLifeAutonomousBike { getChargeCount <- getChargeCount - 1; wanderCountbike <- wanderCountbike + 1;}
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
		transition to: wandering when: location=target {
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
			draw triangle(15) color:color border:color rotate: heading + 90 ;
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
	
		if (state="in_use_people"){
			return goto(on:roadNetwork, target:target, return_path: true, speed:RidingSpeedAutonomousBike);
		}
		else{
			return goto(on:roadNetwork, target:target, return_path: true, speed:DrivingSpeedAutonomousBike);
		}
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
	
				
	/* ========================================== STATE MACHINE ========================================= */
	//aquí he puesto el estado en el que se realiza el count
	
	state newborn initial: true {
		   enter {
            if fleetsizeCountBike + wanderCountbike + lowChargeCount + getChargeCount + RebalanceCount + pickUpCountBike + inUseCountBike > numAutonomousBikes{
                fleetsizeCountBike <- fleetsizeCountBike - 1;
                do die;
            }
        }
        transition to: at_station  { fleetsizeCountBike <- fleetsizeCountBike - 1; wanderCountbike <- wanderCountbike + 1; } 
}
	state at_station {
	//state wandering initial: true{
		enter {
			target <- nil;
		}
		transition to: pickedup when: rider != nil and activity = 1 {pickUpCountBike<-pickUpCountBike+1;wanderCountbike<-wanderCountbike-1;} //If no bidding
		exit {
				
		}
	}

	
	state pickedup {
			enter {	
			}
			transition to: in_use_people {
				inUseCountBike<-inUseCountBike+1;pickUpCountBike<-pickUpCountBike-1;
			}
			exit{
				
			}
	}	
	
	state in_use_people {
		enter {
			
			target <- (station closest_to rider.final_destination).location;
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);

		}
		transition to: at_station when: location=target {
			deliverycount <- deliverycount + 1;
			inUseCountBike<-inUseCountBike-1;wanderCountbike<-wanderCountbike+1;
			rider <- nil;
			
		}
		exit {
		}
	}
	
}

