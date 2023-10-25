model Agents

import "./main.gaml"

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

 
 	/////// VEHICLE REQUESTS - NO BIDDING ///////
	bool requestAutonomousBike(people person, package pack) { 
	 
	 	//Get list of available vehicles
		list<autonomousBike> available <- (autonomousBike where each.availableForRideAB());
		
		//If no bikes available 
		if empty(available) and dynamicFleetsizing{
			//Create new bike
			create autonomousBike number: 1{	
				
				if person != nil{ 
					
					//write(person.my_cell.name);
				
					point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node				
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
				 	
				}else if pack !=nil{ 
					
					//write(pack.my_cell.name);
					
					point packIntersection <- roadNetwork.vertices closest_to(pack); //Cast position to road node
					location <- point(packIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
					numAutonomousBikes  <- numAutonomousBikes +1;
			
				}
			}
			
		}else if empty(available) and !dynamicFleetsizing{
			return false;
			
		}
		
		//Update list of available vehicles
		available <- (autonomousBike where each.availableForRideAB());
		
		if empty(available) and dynamicFleetsizing{
			write 'ERROR, still empty';
			return false;
			
		} else if person != nil{ //People demand
		
			point personIntersection <- roadNetwork.vertices closest_to(person);
			autonomousBike b <- available closest_to(personIntersection); 
			float d<- distanceInGraph(personIntersection,b.location);
			
			ask person{ do updateMaxDistance();}
			//person.updateMaxDistance();
			
			//If closest bike is too far
			if d >person.dynamic_maxDistancePeople and dynamicFleetsizing{
				
				//Create new bike
				create autonomousBike number: 1{
					
					//write(person.my_cell.name);
						
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
				 	
				}
				
				//Assign the newly created one
				b <- last(autonomousBike.population);
				
				float d2<- distanceInGraph(personIntersection,b.location);
				
				if d2 >person.dynamic_maxDistancePeople{
					write 'ERROR IN +1 BIKE';
					return false;
				}
			} 
			
			/*else if d >person.dynamic_maxDistancePeople and !dynamicFleetsizing{
				return false;
			}*/  //REMOVED that trips w/o dynamicFleetsizing wouldn't be served bcs of distance

			ask b { do pickUp(person, nil);} //Assign person to bike
			ask person {do ride(b);} //Assign bike to person
			return true;
		
						
		} else if pack != nil{ //Package demand
			
			point packIntersection <- roadNetwork.vertices closest_to(pack);
			autonomousBike b <- available closest_to(packIntersection);
			float d<- distanceInGraph(packIntersection,b.location);
			
			ask pack{ do updateMaxDistance();}
			
			//If closest bike is too far
			if d >pack.dynamic_maxDistancePackage and dynamicFleetsizing{
				
				//Create new bike
				create autonomousBike number: 1{	
					
					//write( pack.my_cell.name);
					
					location <- point(packIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
				 
				}
				
				//Update list of available vehicles
				b <- last(autonomousBike.population);
				
				float d2<- distanceInGraph(packIntersection,b.location);
				
				if d2 >pack.dynamic_maxDistancePackage{
					write 'ERROR IN +1 BIKE';
					return false;
				}
				
			} 
			/*else if d >pack.dynamic_maxDistancePackage and !dynamicFleetsizing{
				return false;
			}*/
			
			ask b { do pickUp(nil,pack);} //Assign package to bike
			ask pack { do deliver(b);} //Assign bike to package
			return true;
			
		} else { 
			write 'Error in request bike'; //Because no one made this request
			return false;
		}
			
		
	}
	

	/////// VEHICLE REQUESTS - WITH BIDDING ///////
	
   bool bidForBike(people person, package pack){
		
		//Get list of bikes that are available
		list<autonomousBike> availableBikes <- (autonomousBike where each.availableForRideAB());
		
		//If there are no bikes available in the city, create one right next to them
		if empty(availableBikes) and dynamicFleetsizing{
			
			//CREATE new bike
			create autonomousBike number: 1{	
				
				//write('Bike added!');
				
				if person != nil{ 
					//write( person.my_cell.name);
					point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node				
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;

				}else if pack !=nil{ 
					
					//write(pack.my_cell.name);
					point packIntersection <- roadNetwork.vertices closest_to(pack); //Cast position to road node
					location <- point(packIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
					numAutonomousBikes  <- numAutonomousBikes +1;
				}
			}
		} else if empty(availableBikes) and !dynamicFleetsizing {
			return false;
		}
		
		//Update list of available bikes
 		availableBikes <- (autonomousBike where each.availableForRideAB());
 		
		if empty(availableBikes) and dynamicFleetsizing{
			//NOW it shouldn't be empty
			write 'ERROR: STILL no bikes available';
			return false;
				
		} else if person != nil{ //If person request
		
			point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node
			autonomousBike b <- availableBikes closest_to(personIntersection); //Get closest bike
			float d<- distanceInGraph(personIntersection,b.location); //Get distance on roadNetwork
			
			//person.updateMaxDistance();
			ask person{ do updateMaxDistance();}
			
			// If the closest bike is too far
			if d >person.dynamic_maxDistancePeople and dynamicFleetsizing{
				
			//Create new bike
				create autonomousBike number: 1{	
					
					//write(person.my_cell.name);
					
					//Next to the person
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
			
				}
				
				//We assign the bike that we have just added
				b <- last(autonomousBike.population);
				
				float d2<- distanceInGraph(personIntersection,b.location);
				if d2 > person.dynamic_maxDistancePeople {
					write 'ERROR IN +1 BIKE';
					return false;
				}
				
				
			
			}
			
			/*else if d >person.dynamic_maxDistancePeople and !dynamicFleetsizing{
				//If dynamic fleet is not active and the closest is not close enough
				return false;
				
			}*/
			
			//------------------------------BIDDING FUNCTION PEOPLE-----------------------------------
			// Bid value ct is higher for people, its smaller for larger distances, and larger for larger queue times 
			float Wait <- person.queueTime/maxWaitTimePeople; 
			float Proximity <- d/maxDistancePeople_AutonomousBike; 
			float bidValuePerson <- w_urgency * UrgencyPerson + w_wait * Wait - w_proximity * Proximity;
			
				
			//Send bid value to bike	
			ask b { do receiveBid(person,nil,bidValuePerson);} 
			
			return true;
			
		}else if pack !=nil{ // If package request
		
			point packIntersection <- roadNetwork.vertices closest_to(pack); //Cast position to road node
			autonomousBike b <- availableBikes closest_to(packIntersection); //Get closest bike
			float d<- distanceInGraph(packIntersection,b.location); //Get distance on roadNetwork

			
			//pack.updateMaxDistance();
			ask pack{ do updateMaxDistance();}
			
			//If closest bike is too far
			if d > pack.dynamic_maxDistancePackage and dynamicFleetsizing{
				
			//Create new bike
				create autonomousBike number: 1{	
					
					//write(pack.my_cell.name);
					
					//Next to the person
					location <- point(packIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
				 	
				}
				
				//We assign the bike that we have just added
				b <- last(autonomousBike.population);
				float d2<- distanceInGraph(packIntersection,b.location);
				if d2 >pack.dynamic_maxDistancePackage {
					write 'ERROR IN +1 BIKE';
					return false;
				}
				
				
			}
			
			/*else if d >pack.dynamic_maxDistancePackage  and !dynamicFleetsizing{
				//If dynamic fleet is not active and the closest is not close enough
				return false;
			}*/
			
			//------------------------------BIDDING FUNCTION PACKAGE------------------------------------
			// Bid value ct is lower for packages, its smaller for larger distances, and larger for larger queue times
			float Wait <- pack.queueTime/maxWaitTimePackage; 
			float Proximity <- d/maxDistancePackage_AutonomousBike; 
			float bidValuePackage <- w_urgency * UrgencyPackage + w_wait * Wait- w_proximity * Proximity;

			//Send bid value to bike
			ask b { do receiveBid(nil,pack,bidValuePackage);} 
			
			return true;

			
		}else{
			write 'ERROR in bidForBike caller'; return false;
		}
	
	}
	
	// An auxiliary function used for bidding, to know when a vehicle was assigned
	bool bikeAssigned(people person, package pack){
		if person != nil{
			if person.autonomousBikeToRide !=nil{ 
				return true;
			}else{
				return false;
			}
		}else if pack !=nil{ 
			if pack.autonomousBikeToDeliver !=nil{
				return true;
			}else{
				return false;
			}
		}else{
			return false;
		}
	}

			
		
}

species road {
	aspect base {
		draw shape color: rgb(125, 125, 125);
	}
}


/*species CellcenterPoint{
	aspect base {
    	color <- #orangered;
    	draw triangle(100) color: color;
    }
	
}*/

/*grid cell width: 6 height: 6 neighbors: 6 {
	bool used <-false;
	int numBikesCell <- 0;
	point centerRoadpoint;
	
	int colorValue <- int(255*(numBikesCell*0.1)) update: int(255*(numBikesCell*0.1));
	rgb color <- rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0)  update: rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0) ;
	
	
	aspect base {
		draw shape color: color;
	}
	//rgb color <- rgb(int(100 * (1 - numBikesCell)), 100, int(100 * (1 - numBikesCell))) update: rgb(int(100 * (1 - numBikesCell)), 100, int(100 * (1 - numBikesCell)));
}*/

species building {
    aspect type {
		//draw shape color: color_map[type] border:color_map[type];
		draw shape color: #palegreen;
	}
	string type; 
}


species chargingStation{
	
	list<autonomousBike> autonomousBikesToCharge;
	
	rgb color <- #deeppink;
	
	float lat;
	float lon;
	int capacity; 
	
	aspect base{
		draw hexagon(25,25) color:color border:#black;
	}
	
	reflex chargeBikes {
		ask capacity first autonomousBikesToCharge {
			batteryLife <- batteryLife + step*V2IChargingRate;
		}
	}
}

species restaurant{
	
	rgb color <- #sandybrown;
	
	float lat;
	float lon;
	point rest;
	
	aspect base{
		draw circle(10) color:color;
	}
}

//For rebalancing
species foodhotspot{
	float lat;
	float lon;
	float dens;
	aspect base{
		draw hexagon(60) color:#red;
	}
	
}

//For rebalancing
species userhotspot{
	float lat;
	float lon;
	float dens;
	aspect base{
		draw hexagon(60) color:#blue;
	}
	
}

species package control: fsm skills: [moving] {

	rgb color;
	
    map<string, rgb> color_map <- [
    	
    	"generated":: #lightsteelblue,
    	"firstmile":: #lightsteelblue,
    	"requestingAutonomousBike"::#red,
		"awaiting_autonomousBike_package":: #yellow,
		"delivering_autonomousBike":: #yellow,
		"lastmile"::#lightsteelblue,
		"retry":: #red,
		"delivered":: #transparent
	];
	
	packageLogger logger;
    packageLogger_trip tripLogger;
    
	date start_hour;
	float start_lat; 
	float start_lon;
	float target_lat; 
	float target_lon;
	int start_d;
	
	point start_point;
	point target_point;
	int start_day;
	int start_h;
	int start_min;
	
	autonomousBike autonomousBikeToDeliver;
	
	point final_destination; 
    point target; 
    //float waitTime;
    int queueTime;
    int bidClear <- 0;
    
    float tripdistance <- 0.0;
    
    
    float dynamic_maxDistancePackage <- maxDistancePackage_AutonomousBike;
    //cell my_cell; 
        
	aspect base {
    	color <- color_map[state];
    	draw square(15) color: color border: #black;
    }
    aspect test{
    	draw square(15) color: #green;
    }
    
	action deliver(autonomousBike ab){
		autonomousBikeToDeliver <- ab;
	}
	
	
	/*reflex updateQueueTime{
		
		
		if timeToTravel(){
			//write 'Package Day '+ start_day + '=' + current_date.day +' '+ start_h +'= '+current_date.hour; //TODO: REVIEW day 
		
		}
		
	}*/
	
	action updateMaxDistance{ //TODO: Review
		if (current_date.hour = start_h){ 
				queueTime <- (current_date.minute - start_min);
		} else if (current_date.hour > start_h){
				queueTime <- (current_date.hour-start_h-1)*60 + (60 - start_min) + current_date.minute;	
		}
		dynamic_maxDistancePackage  <- maxDistancePackage_AutonomousBike - queueTime*DrivingSpeedAutonomousBike #m;
	}
	
	//TODO: REVIEW day 
 	bool timeToTravel { 
 		if current_date.day != start_day {return false;}
 		else{
 		return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point);}
 	}
	//bool timeToTravel { return ((current_date.day = start_day and current_date.hour = start_h and current_date.minute >= (start_min)) or (current_date.day = start_day and current_date.hour > start_h)) and !(self overlaps target_point); }
    //bool timeToTravel { return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point); }
    //bool timeToTravel { return (current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point); }
	
	state wandering initial: true {
    	
    	enter {
    		if (packageEventLog or packageTripLog) {ask logger { do logEnterState;}}
    		target <- nil;
    	}
    	transition to: bidding when: timeToTravel() and biddingEnabled { //Flow if bidding is enabled: bidding--> awaitingBikeAssignation --> firstmile
    		final_destination <- target_point;
    	}
    	transition to: requestingAutonomousBike when: timeToTravel() and !biddingEnabled{ //Flow if bidding is NOT enabled: requestingAutonomousBike --> firstmile
    		final_destination <- target_point;
    	}
    	exit {
			if (packageEventLog) {ask logger { do logExitState; }}
		}
    }
    
    //If bidding not enabled
    state requestingAutonomousBike {
    	
    	enter {
    		if  (packageEventLog or packageTripLog) {ask logger { do logEnterState; }}    		
    	}
    	transition to: firstmile when: host.requestAutonomousBike(nil,self){		
    		 target <- (road closest_to(self)).location;
    	}

		transition to: wandering when: !host.requestAutonomousBike(nil,self){ //TODO: Do we need this state?
			write 'ERROR: Package not delivered';
			if peopleEventLog {ask logger { do logEvent( "Package not delivered" ); }}
			location <- final_destination;
		} 
    	exit {
    		//if packageEventLog {ask logger { do logExitState; }}
			if packageEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToDeliver); }}
		}
    }
    
    state bidding {
    	enter {
    		//write string(self) + 'entering bidding';
    		if (packageEventLog or packageTripLog) {ask logger { do logEnterState; }} 
    		bidClear <-0;
    		target <- (road closest_to(self)).location;
   	
    	}
    	transition to: awaiting_bike_assignation when: host.bidForBike(nil,self){		
    	}
    	transition to: wandering when: !host.bidForBike(nil,self) { //TODO: review this state
    		write 'ERROR: Package not delivered';
			if peopleEventLog {ask logger { do logEvent( "Package not delivered" ); }}
			location <- final_destination;
		}
    	exit {
    		if packageEventLog {ask logger { do logExitState; }}
		}
		
	}
    state awaiting_bike_assignation{
		
		enter{
    		if (packageEventLog or packageTripLog){ask logger {do logEnterState;}}
    	}
	    transition to: requested_with_bid when: host.bikeAssigned(nil,self){ 
	    	target <- (road closest_to(self)).location;
	    }
	    /*transition to: firstmile when: host.bikeAssigned(nil,self){ 
	    	target <- (road closest_to(self)).location;
	    }*/
	    transition to: bidding when: bidClear = 1 {
	    	//write string(self)+ 'lost bid, will bid again';
	    	
	    	//TODO: REVIEW - We need to update the max distance, now it will be lower
	    	
	    }
	    exit {
	    	if packageEventLog {ask logger { do logExitState; }}
	    	//if packageEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToDeliver); }}
		}
   
   }

	state requested_with_bid{
		enter{
			if packageEventLog or packageTripLog {ask logger { do logEnterState; }} 
		}
		transition to:firstmile {}
		exit {
			if packageEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToDeliver); }}
		}
	}

	state firstmile {
		enter{
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
		}
		transition to: awaiting_autonomousBike_package when: location=target{}
		exit {
			if packageEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	
	state awaiting_autonomousBike_package {
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "awaiting " + string(myself.autonomousBikeToDeliver) ); }}
		}
		transition to: delivering_autonomousBike when: autonomousBikeToDeliver.state = "in_use_packages" {target <- nil;}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
		}
	}
	
	state delivering_autonomousBike {
		enter {
			if packageEventLog or packageTripLog {ask logger { do logEnterState( "delivering " + string(myself.autonomousBikeToDeliver) ); }}
		}
		transition to: lastmile when: autonomousBikeToDeliver.state != "in_use_packages" {
			target <- final_destination;
		}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
			autonomousBikeToDeliver<- nil;
		}
		location <- autonomousBikeToDeliver.location; 
	}
	
	state lastmile {
		enter{
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}
		}
		transition to:delivered when: location=target{}
		exit {
			if packageEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	
	state delivered {
		enter{
			tripdistance <- host.distanceInGraph(self.start_point, self.target_point);
			if packageEventLog or packageTripLog {ask logger{ do logEnterState;}}

		}
		do die; //TODO: review die
	}
}

species people control: fsm skills: [moving] {

	rgb color;
	
    map<string, rgb> color_map <- [
    	"wandering":: #springgreen,
		"requestingAutonomousBike":: #springgreen,
		"awaiting_autonomousBike":: #springgreen,
		"riding_autonomousBike":: #gamagreen,
		"firstmile":: #blue,
		"lastmile":: #blue
	];
	
	//loggers
    peopleLogger logger;
    peopleLogger_trip tripLogger;
    
    package delivery;

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
    
    autonomousBike autonomousBikeToRide;
    
    point final_destination;
    point target;
    //float waitTime;
    int queueTime;
    int bidClear;
    
    float tripdistance <- 0.0;
    
    float dynamic_maxDistancePeople <- maxDistancePeople_AutonomousBike;
    
    //cell my_cell;   
        
    
    int register <-0;
    aspect base {
    	color <- color_map[state];
    	draw circle(10) color: color border: #black;
    }
    
     aspect test{
    	draw circle(15) color: #blue;
    }
    
    //----------------PUBLIC FUNCTIONS-----------------
	
    action ride(autonomousBike ab) {
    	if ab!=nil{
    		autonomousBikeToRide <- ab;
    	}
    }
    
	
    	
	/*reflex updateQueueTime{
		
		if timeToTravel() {
			
			//write 'People Day '+ start_day + '=' + current_date.day +' '+ start_h +'= '+current_date.hour; //TODO: REVIEW day 
			
		
		}
		
	}*/
	
	action updateMaxDistance{ //TODO: Review
		
		if (current_date.hour = start_h) {
			queueTime <- (current_date.minute - start_min);
		} else if (current_date.hour > start_h){
			queueTime <- (current_date.hour-start_h-1)*60 + (60 - start_min) + current_date.minute;	
		}
		dynamic_maxDistancePeople  <- maxDistancePeople_AutonomousBike - queueTime*DrivingSpeedAutonomousBike #m;
	}
	
	
	//TODO: REVIEW day 
    bool timeToTravel { 
    	if current_date.day != start_day {return false;}
    	else{
    	return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point);}
    }
    
 
    state wandering initial: true {
    	enter {
    		if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }}
    		target <- nil;
    	}
    	transition to: bidding when: timeToTravel() and biddingEnabled { //Flow if bidding is enabled: bidding--> awaitingBikeAssignation --> firstmile
    		final_destination <- target_point;
    	}
    	transition to: requestingAutonomousBike when: timeToTravel() and !biddingEnabled{ //Flow if bidding is NOT enabled: requestingAutonomousBike --> firstmile
    		final_destination <- target_point;
    	}
    	exit {
			if peopleEventLog {ask logger { do logExitState; }}
		}
    }
    
    //If bidding not enabled
    state requestingAutonomousBike {
		enter {
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
		}
		transition to: firstmile when: host.requestAutonomousBike(self, nil) {
			target <- (road closest_to(self)).location;
		}
		transition to: finished when: !host.requestAutonomousBike(self,nil){ //TODO: REVIEW this state
			write 'ERROR: Trip not served';
			if peopleEventLog {ask logger { do logEvent( "Used another mode, wait too long" ); }}
			location <- final_destination;
		}
		exit {
			if peopleEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToRide); }}
		}
		
	}
    
    state bidding {
		enter {
			//write string(self) + 'entering bidding';
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
			bidClear <- 0;
			target <- (road closest_to(self)).location;
		}
		transition to: awaiting_bike_assignation when: host.bidForBike(self,nil) {
		}
		transition to: finished when: !host.bidForBike(self,nil) { //TODO: review this state
			write 'ERROR: Trip not served';
			if peopleEventLog {ask logger { do logEvent( "Used another mode, wait too long" ); }}
			location <- final_destination;
		}
		exit {
			if peopleEventLog {ask logger { do logExitState; }}
		}
		
	}
    
	state awaiting_bike_assignation {
		enter {
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
		}
		transition to: requested_with_bid when: host.bikeAssigned(self, nil) {
			target <- (road closest_to(self)).location;
		}
		/*transition to: firstmile when: host.bikeAssigned(self, nil) {
			target <- (road closest_to(self)).location;
		}*/
		transition to: bidding when: bidClear = 1 {
			//write string(self)+ 'lost bid, will bid again';
			
		}
		exit {
			//if peopleEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToRide); }}
			if peopleEventLog { ask logger {do logExitState;}}
		}
		
	}
	
	state requested_with_bid{
		enter{
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
		}
		transition to:firstmile {}
		exit {
			if peopleEventLog {ask logger { do logExitState("Requested Bike " + myself.autonomousBikeToRide); }}
		}
	}

	
	state firstmile {
		enter{
			if peopleEventLog or peopleTripLog {ask logger{ do logEnterState;}}
		}
		transition to: awaiting_autonomousBike when: location=target{}
		exit {
			if peopleEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	
	state awaiting_autonomousBike {
		enter {
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState( "awaiting " + string(myself.autonomousBikeToRide) ); }}
		}
		transition to: riding_autonomousBike when: autonomousBikeToRide.state = "in_use_people" {target <- nil;}
		exit {
			if peopleEventLog {ask logger { do logExitState; }}
		}
	}
	
	state riding_autonomousBike {
		enter {
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState( "riding " + string(myself.autonomousBikeToRide) ); }}
		}
		transition to: lastmile when: autonomousBikeToRide.state != "in_use_people" {
			target <- final_destination;
		}
		exit {
			if peopleEventLog {ask logger { do logExitState; }}
			autonomousBikeToRide <- nil;
		}
		location <- autonomousBikeToRide.location; //Always be at the same place as the bike
	}
	
	
	state lastmile {
		enter{
			if peopleEventLog or peopleTripLog {ask logger{ do logEnterState;}}
		}
		transition to:finished when: location=target{
			 tripdistance <-  host.distanceInGraph(self.start_point, self.target_point);
		}
		exit {
			if peopleEventLog {ask logger{do logExitState;}}
		}
		do goto target: target on: roadNetwork;
	}
	state finished {
		enter{
			tripdistance <- host.distanceInGraph(self.start_point, self.target_point);
			if peopleEventLog or peopleTripLog {ask logger{ do logEnterState;}}

		}
		do die; //TODO: review die
	}
}

species autonomousBike control: fsm skills: [moving] {
	
	//----------------Display-----------------
	rgb color;
	
	map<string, rgb> color_map <- [
		"wandering"::#cyan,
		
		"low_battery":: #red,
		"getting_charge":: #red,

		"picking_up_people"::#springgreen,
		"picking_up_packages"::#mediumorchid,
		"in_use_people"::#gamagreen,
		"in_use_packages"::#purple,
		
		"rebalancing"::#gold
	];
	
	aspect realistic {
		color <- color_map[state];
		if state != "newborn"{
			draw triangle(35) color:color border:color rotate: heading + 90 ;
		}else{
			draw circle(100) color:#pink border:#pink rotate: heading + 90 ;
		}
		
	} 

	//loggers
	autonomousBikeLogger_roadsTraveled travelLogger;
	autonomousBikeLogger_chargeEvents chargeLogger;
	autonomousBikeLogger_event eventLogger;
	    
	/* ========================================== PUBLIC FUNCTIONS ========================================= */
	
	people rider;
	package delivery;
	int activity; //0=Package 1=Person

	
	bool biddingStart <- false;
	float highestBid <- -100000.00;
	people highestBidderUser;
	package highestBidderPackage;
	list<people> personBidders;
	list<package> packageBidders;
	foodhotspot closest_f_hotspot;
	userhotspot closest_u_hotspot;
	
	int bid_start_h;
	int bid_start_min;
	//TODO: Add DAY!
	
	int last_trip_day <- 7;
	int last_trip_h <- 12;
	
	//cell my_cell;
	//cell rebalchosenCell;
	
	bool availableForRideAB {
		return  (self.state="wandering" or self.state="rebalancing") and !setLowBattery() and rider = nil  and delivery=nil;
	}
	

	action pickUp(people person, package pack) { 
		
		if person != nil{
			
			rider <- person;
			activity <- 1;
		} else if pack != nil {
			
			delivery <- pack;
			activity <- 0;
		}
	}
	

	/* ========================================== PRIVATE FUNCTIONS ========================================= */
	//---------------BATTERY-----------------
	
	bool setLowBattery { 
		if batteryLife < minSafeBatteryAutonomousBike { return true; } 
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
	//----------------MOVEMENT-----------------
	point target;
	//point nightorigin;
	
	float batteryLife min: 0.0 max: maxBatteryLifeAutonomousBike; 
	float distancePerCycle;
	
	float distanceTraveledBike;
	path travelledPath; 
	
	bool canMove {
		return ((target != nil and target != location)) and batteryLife > 0;
	}
	
	
	//TODO: REVIEW REBAL
	bool rebalanceNeeded{
		//if latest move was more than 12 h ago
		
		//Save this time for rebalancing
			if last_trip_day = current_date.day and  (current_date.hour  - last_trip_h) > 6 {
			//if last_trip_day = (current_date.day-1) and  (current_date.hour  - last_trip_h) > 12  {
				//write('Current hour:'+ current_date.hour);
				//write('Last trip hour:'+ last_trip_h);
				//write("REBAL ACTIVE "+ last_trip_day + " =" + (current_date.day-1)  +" hours "+ (current_date.hour  - last_trip_h)) + " > 12";
				return true;
				
			} else if last_trip_day < current_date.day and  (current_date.hour  + (24 - last_trip_h)) > 6 {
			//} else if last_trip_day < (current_date.day-2) {
				//write('Current day and hour :'+ current_date.day + " "+current_date.hour + " h");
				//write('Last trip day and hour:'+ last_trip_day+ " "+ last_trip_h + " h");
				//write("REBAL ACTIVE " + (current_date.hour  + (24 - last_trip_h)) + " > 12");
				//write("REBAL ACTIVE " + last_trip_day + " < " + (current_date.day-2));
				return true;
				
			}else{
				return false;
			}
		
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
	
	

	action receiveBid(people person, package pack, float bidValue){
		//write 'Bike ' + string(self) +'received bid from:'+ person + '/'+ pack +' of value: '+ bidValue ;
		biddingStart <- true;
		if person != nil{
			add person to: personBidders;
		}else if pack != nil{
			add pack to: packageBidders;
		}
		if highestBid = -100000.00{ //First bid
			bid_start_h <- current_date.hour;
			bid_start_min <- current_date.minute;
		}
		if bidValue > highestBid { 
		//If the current bid value is larger than the previous max, we update it
			highestBidderUser <- nil;
			highestBidderPackage <- nil;
			highestBid <- bidValue;
			if person !=nil {
				highestBidderUser <- person; 
			}else if package !=nil{
				highestBidderPackage <- pack;	
			}else{
				write 'Error in receiveBid()';
			}
		}

	}
	
	action endBidProcess{
			loop i over: personBidders{	
				i.bidClear <- 1;
			}
			loop j over: packageBidders{
				j.bidClear <- 1;
			}
			//If the highest bidder was a person
			if highestBidderUser !=nil and highestBidderPackage = nil{ 
				do pickUp(highestBidderUser,nil);
				ask highestBidderUser {do ride(myself);}
				//write 'Highest bidder for bike '+ string(self)+' person '+ highestBidderUser;
				
			//If the highest bidder was a package
			}else if highestBidderPackage !=nil and highestBidderUser = nil {
				do pickUp(nil,highestBidderPackage);
				ask highestBidderPackage {do deliver(myself);}
				//write 'Highest bidder for bike '+ string(self)+' package '+ highestBidderPackage;
			}else{
				write 'Error: Confusion with highest bidder';
			}
	}
				
	/* ========================================== STATE MACHINE ========================================= */
	
	/*state newborn initial: true{
		enter{int delayT <-cycle;}
		transition to: wandering when: (cycle-delayT > 1) ;
	}*/
	state wandering initial: true{
		enter {
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			target <- nil;
			
			//Add +1 bike to the cell
			//my_cell <- cell closest_to(self.location);
			//my_cell.numBikesCell <- my_cell.numBikesCell +1;
			
			//write('Cell ' + my_cell + ' has +1 bike, total:  ' + my_cell.numBikesCell);
		}
		transition to: bidding when: biddingStart= true and biddingEnabled{} // When it receives bid
		transition to: picking_up_people when: rider != nil and activity = 1 and !biddingEnabled{} //If no bidding
		transition to: picking_up_packages when: delivery != nil and activity = 0 and !biddingEnabled{} //If no bidding
		transition to: low_battery when: setLowBattery() {}
		transition to: rebalancing when: rebalanceNeeded() and rebalEnabled{}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
			
			//Remove 1 bike from cell
			//my_cell.numBikesCell <- my_cell.numBikesCell - 1;
			
			//write('Cell ' + my_cell + ' has -1 bike, total:  ' + my_cell.numBikesCell);
			//my_cell <- nil;
			
			
		}
	}
	
	
	//TODO: review rebal
	state rebalancing{
		enter{
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}	
		
		
			//choose target from hotspots
			if packagesEnabled and !peopleEnabled { //If food only
				closest_f_hotspot <- foodhotspot closest_to(self);
				target <- closest_f_hotspot.location;
				
			}else if !packagesEnabled and peopleEnabled {//If people only
			
				/*//closest_u_hotspot <- userhotspot closest_to(self);
				//target <- closest_u_hotspot.location;
				
				//Choose usedCells that have less than 1 bike
	 			list<cell> usedCells <- (cell where (each.used= true));
	 			list<cell> cellsinNeed <- (usedCells where (each.numBikesCell <5));
	 			
	 			//If there are cells in need
	 			if length(cellsinNeed) != 0 {
	 				//Choose the one that is closest
	 				
	 				rebalchosenCell <- cellsinNeed closest_to(self);
	 				
	 				//We need to add the bike already so that other bikes don't choose it as well
	 				rebalchosenCell.numBikesCell <-  rebalchosenCell.numBikesCell +1;
	 				
	 				write('Cells in need: ' + length(cellsinNeed) + ' chosen cell: ' + rebalchosenCell);
	 				
	 				//Set its centerRoadpoint as target
	 				target <- rebalchosenCell.centerRoadpoint; 
	 				do Move();
	 			}else{
	 				  target <-location;
	 				  do Move();
	 			}*/
	 			
	 			
				
			}else if packagesEnabled and peopleEnabled {//If both
			

				//Choose usedCells that have less than 1 bike
	 			//list<cell> usedCells <- (cell where (each.used= true));
	 			//list<cell> cellsinNeed <- (usedCells where (each.numBikesCell <1));
	 			
	 			//If there are cells in need - prioritize this
	 			/*if cellsinNeed != nil {
	 				
	 				//Choose the one that is closest
	 				cell chosenCell <- cellsinNeed closest_to(self);
	 				//Set its centerRoadpoint as target
	 				target <- chosenCell.centerRoadpoint; 
	 				
	 			//Otherwise choose closest hotspot
	 			}else{
	 				
		 			//Check if food or user hotspots are closer
					closest_f_hotspot <- foodhotspot closest_to(self);
					closest_u_hotspot <- userhotspot closest_to(self);
					if (closest_f_hotspot distance_to(self)) < (closest_u_hotspot distance_to(self)){
						target <- closest_f_hotspot.location;
					}else if (closest_f_hotspot distance_to(self)) > (closest_u_hotspot distance_to(self)) {
						target <- closest_u_hotspot.location;
					}
	 			}*/
	 			//Check if food or user hotspots are closer
					closest_f_hotspot <- foodhotspot closest_to(self);
					closest_u_hotspot <- userhotspot closest_to(self);
					if (closest_f_hotspot distance_to(self)) < (closest_u_hotspot distance_to(self)){
						target <- closest_f_hotspot.location;
						
					}else if (closest_f_hotspot distance_to(self)) > (closest_u_hotspot distance_to(self)) {
						target <- closest_u_hotspot.location;
						
					}
			
			
						
			}
		}
		transition to: wandering when: location=target {}
		transition to: bidding when: biddingStart= true and biddingEnabled{} // When it receives bid
		transition to: picking_up_people when: rider != nil and activity = 1 and !biddingEnabled{} //If no bidding
		transition to: picking_up_packages when: delivery != nil and activity = 0 and !biddingEnabled{} //If no bidding
		transition to: low_battery when: setLowBattery() {}
		exit {
			
			//Update this time for rebalancing
			last_trip_day <- current_date.day;
			last_trip_h <- current_date.hour;
			
			//Remove +1 bike because it would be double counted when starting wandering;
			//if rebalchosenCell != nil {
				//rebalchosenCell.numBikesCell <-  rebalchosenCell.numBikesCell -1;
			//}
			
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
		
	
	}
	state bidding {
		enter{
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			
		} //Wait for bidding time to end
		transition to: endBid when: (highestBid != -100000.00) and (current_date.hour = bid_start_h and current_date.minute > (bid_start_min + maxBiddingTime)) or (current_date.hour > bid_start_h and (60-bid_start_min+current_date.minute)>maxBiddingTime){}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
	}
	state endBid {
		enter{	 
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			do endBidProcess(); //Assign winner and get the rest of packages and people out of the bid waiting
			
			//Clear all the variables for next round
			biddingStart <- false;
			highestBid <- -100000.00;
			highestBidderUser<- nil;
			highestBidderPackage <- nil;
			personBidders <- [];
			packageBidders <- [];
			bid_start_h <- nil;
			bid_start_min <- nil;
		}
		transition to: picking_up_people when: rider != nil and activity = 1{}
		transition to: picking_up_packages when: delivery != nil and activity = 0{}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
	}
	
	state low_battery {
		enter{
			target <- (chargingStation closest_to(self)).location; 
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
			
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState(myself.state); }
				ask travelLogger { do logRoads(myself.distanceTraveledBike);}
			}
		}
		transition to: getting_charge when: location = target {}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
	}
	
	state getting_charge {
		enter {
			if stationChargeLogs{
				ask eventLogger { do logEnterState("Charging at " + (chargingStation closest_to myself)); }
				ask travelLogger { do logRoads(0.0);}
			}		
			target <- nil;
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge + myself;
			}
		}
		transition to: wandering when: batteryLife >= maxBatteryLifeAutonomousBike {}
		exit {
			if stationChargeLogs{ask eventLogger { do logExitState("Charged at " + (chargingStation closest_to myself)); }}
			ask chargingStation closest_to(self) {
				autonomousBikesToCharge <- autonomousBikesToCharge - myself;}
		}
	}
			
	state picking_up_people {
			enter {
				target <- rider.target;
				
				point target_intersection <- roadNetwork.vertices closest_to(target);
				distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
				
				if autonomousBikeEventLog {
					ask eventLogger { do logEnterState("Picking up " + myself.rider); }
					ask travelLogger { do logRoads(myself.distanceTraveledBike);}
				}
			}
			transition to: in_use_people when: (location=target and rider.location=target) {}
			exit{
				if autonomousBikeEventLog {ask eventLogger { do logExitState("Picked up " + myself.rider); }}
			}
	}	
	
	state picking_up_packages {
			enter {
				target <- delivery.target; 
				
				point target_intersection <- roadNetwork.vertices closest_to(target);
				distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
				
				if autonomousBikeEventLog {
					ask eventLogger { do logEnterState("Picking up " + myself.delivery); }
					ask travelLogger { do logRoads(myself.distanceTraveledBike);}
				}
			}
			transition to: in_use_packages when: (location=target and delivery.location=target) {}
			exit{
				//trips_w_good_service <- trips_w_good_service+1; //TODO: This may not be necessary anymore
				//write 'trips with good service: '+trips_w_good_service;
				if autonomousBikeEventLog {ask eventLogger { do logExitState("Picked up " + myself.delivery); }}
			}
	}
	
	state in_use_people {
		enter {
			
			target <- (road closest_to rider.final_destination).location;
			
			point target_intersection <- roadNetwork.vertices closest_to(target);
			distanceTraveledBike <- host.distanceInGraph(target_intersection,location);

			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState("In Use " + myself.rider); }
				ask travelLogger { do logRoads(myself.distanceTraveledBike);}
			}
		}
		transition to: wandering when: location=target {
			rider <- nil;
			
			//Save this time for rebalancing
			last_trip_day <- current_date.day;
			last_trip_h <- current_date.hour;
		}
		exit {
			//trips_w_good_service <- trips_w_good_service+1; //TODO: This may not be necessary anymore
			//write 'trips with good service: '+trips_w_good_service;
			if autonomousBikeEventLog {ask eventLogger { do logExitState("Used" + myself.rider); }}
		}
	}
	
	state in_use_packages {
		enter {
			target <- (road closest_to delivery.final_destination).location;  

		point target_intersection <- roadNetwork.vertices closest_to(target);
		distanceTraveledBike <- host.distanceInGraph(target_intersection,location);
		
		if autonomousBikeEventLog {
				ask eventLogger { do logEnterState("In Use " + myself.delivery); }
				ask travelLogger { do logRoads(myself.distanceTraveledBike);}
			}
		}
		transition to: wandering when: location=target {
			delivery <- nil;
			
			//Save this time for rebalancing
			last_trip_day <- current_date.day;
			last_trip_h <- current_date.hour;
			
		}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState("Used" + myself.delivery); }}
		}
	}
}


