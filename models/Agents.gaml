model Agents

import "./main.gaml"


// *********************************** GLOBAL FUNCTIONS START ***************************************
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

 
 	///////---------- VEHICLE REQUESTS - NO BIDDING --------------///////
	bool requestAutonomousBike(people person, package pack) { 
	 
	 	//Get list of available vehicles
		list<autonomousBike> available <- (autonomousBike where each.availableForRideAB());
		
		//If no bikes available 
		if empty(available) and dynamicFleetsizing{
			//Create new bike
			create autonomousBike number: 1{	
				
				if person != nil{ 

					point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node				
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;
				 	
				}else if pack !=nil{ 
					
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
	
			
			//If closest bike is too far
			if d >person.dynamic_maxDistancePeople and dynamicFleetsizing{
				
				//Create new bike
				create autonomousBike number: 1{
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
			//Trips w/o dynamicFleetsizing wouldn't be served bcs of distance
			/*else if d >person.dynamic_maxDistancePeople and !dynamicFleetsizing{
				return false;
			}*/  

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
			
			//Trips w/o dynamicFleetsizing wouldn't be served bcs of distance
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
	
	/////// ------------------ VEHICLE REQUESTS - WITH BIDDING  --------------------------///////
	
   bool bidForBike(people person, package pack){
		
		//Get list of bikes that are available
		list<autonomousBike> availableBikes <- (autonomousBike where each.availableForRideAB());
		
		//If there are no bikes available in the city, create one right next to them
		if empty(availableBikes) and dynamicFleetsizing{
			
			//CREATE new bike
			create autonomousBike number: 1{	
			
				
				if person != nil{ 
					point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node				
					location <- point(personIntersection);
					batteryLife <- rnd(minSafeBatteryAutonomousBike,maxBatteryLifeAutonomousBike); 	//Battery life random bewteen max and min
				 	numAutonomousBikes  <- numAutonomousBikes +1;

				}else if pack !=nil{ 
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
			//Now it shouldn't be empty
			write 'ERROR: STILL no bikes available';
			return false;
				
		} else if person != nil{ //If person request
		
			point personIntersection <- roadNetwork.vertices closest_to(person); //Cast position to road node
			autonomousBike b <- availableBikes closest_to(personIntersection); //Get closest bike
			float d<- distanceInGraph(personIntersection,b.location); //Get distance on roadNetwork
			
			ask person{ do updateMaxDistance();}
			
			// If the closest bike is too far
			if d >person.dynamic_maxDistancePeople and dynamicFleetsizing{
				
			//Create new bike
				create autonomousBike number: 1{	
					
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
			
			//If dynamic fleet is not active and the closest is not close enough
			/*else if d >person.dynamic_maxDistancePeople and !dynamicFleetsizing{
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

			ask pack{ do updateMaxDistance();}
			
			//If closest bike is too far
			if d > pack.dynamic_maxDistancePackage and dynamicFleetsizing{
				
			//Create new bike
				create autonomousBike number: 1{	
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
			
			//If dynamic fleet is not active and the closest is not close enough
			/*else if d >pack.dynamic_maxDistancePackage  and !dynamicFleetsizing{
				return false;
			}*/
			
			//------------------------------BIDDING FUNCTION ------------------------------------
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

// *********************************** SPECIES DEFINITIONS ***************************************

species road {
	aspect base {
		draw shape color: rgb(125, 125, 125);
	}
}

species building {
    aspect type {
		draw shape color: #white;
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


//For rebalancing - food
species foodhotspot{
	float lat;
	float lon;
	float dens;
	aspect base{
		draw hexagon(60) color:#red;
	}
	
}

//For rebalancing - user
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
    int queueTime;
    int bidClear <- 0;
    
    float tripdistance <- 0.0;
    
    
    float dynamic_maxDistancePackage <- maxDistancePackage_AutonomousBike;

        
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
	
	
	action updateMaxDistance{ 
		if (current_date.hour = start_h){ 
				queueTime <- (current_date.minute - start_min);
		} else if (current_date.hour > start_h){
				queueTime <- (current_date.hour-start_h-1)*60 + (60 - start_min) + current_date.minute;	
		}
		dynamic_maxDistancePackage  <- maxDistancePackage_AutonomousBike - queueTime*DrivingSpeedAutonomousBike #m;
	}
	
 	bool timeToTravel { 
 		if current_date.day != start_day {return false;}
 		else{
 		return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point);}
 	}
	
	/* ========================================== STATE MACHINE ========================================= */
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

		transition to: delivered when: !host.requestAutonomousBike(nil,self){ 
			write 'ERROR: Package not delivered';
			if peopleEventLog {ask logger { do logEvent( "Package not delivered" ); }}
			location <- final_destination;
		} 
    	exit {
    		if packageEventLog {ask logger { do logExitState; }}
		}
    }
    
    state bidding {
    	enter {
    		if (packageEventLog or packageTripLog) {ask logger { do logEnterState; }} 
    		bidClear <-0;
    		target <- (road closest_to(self)).location;
   	
    	}
    	transition to: awaiting_bike_assignation when: host.bidForBike(nil,self){		
    	}
    	transition to: delivered when: !host.bidForBike(nil,self) { 
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
	    transition to: bidding when: bidClear = 1 {
	    	
	    }
	    exit {
	    	if packageEventLog {ask logger { do logExitState; }}
		}
   
   }

	state requested_with_bid{
		enter{
			if packageEventLog or packageTripLog {ask logger { do logEnterState; }} 
		}
		transition to:firstmile {}
		exit {
			if packageEventLog {ask logger { do logExitState; }}
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
		do die;
	}
}

species people control: fsm skills: [moving] {


 //----------------ATTRIBUTES-----------------

	
	//loggers
    peopleLogger logger;
    peopleLogger_trip tripLogger;
    

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
    float dynamic_maxDistancePeople <- maxDistancePeople_AutonomousBike;
    
    //visual aspect
   	rgb color;
    map<string, rgb> color_map <- [
    	"wandering":: #springgreen,
		"requestingAutonomousBike":: #springgreen,
		"awaiting_autonomousBike":: #springgreen,
		"riding_autonomousBike":: #gamagreen,
		"firstmile":: #blue,
		"lastmile":: #blue
	];
    aspect base {
    	color <- color_map[state];
    	draw circle(10) color: color border: #black;
    }
    
    
    //----------------PUBLIC FUNCTIONS-----------------
	
    action ride(autonomousBike ab) {
    	if ab!=nil{
    		autonomousBikeToRide <- ab;
    	}
    }
	
	action updateMaxDistance{ 
		
		if (current_date.hour = start_h) {
			queueTime <- (current_date.minute - start_min);
		} else if (current_date.hour > start_h){
			queueTime <- (current_date.hour-start_h-1)*60 + (60 - start_min) + current_date.minute;	
		}
		dynamic_maxDistancePeople  <- maxDistancePeople_AutonomousBike - queueTime*DrivingSpeedAutonomousBike #m;
	}
	

    bool timeToTravel { 
    	if current_date.day != start_day {return false;}
    	else{
    	return (current_date.day= start_day and current_date.hour = start_h and current_date.minute >= start_min) and !(self overlaps target_point);}
    }
    
    
    /* ========================================== STATE MACHINE ========================================= */
 
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
		transition to: finished when: !host.requestAutonomousBike(self,nil){ 
			write 'ERROR: Trip not served';
			if peopleEventLog {ask logger { do logEvent( "Used another mode, wait too long" ); }}
			location <- final_destination;
		}
		exit {
			if peopleEventLog {ask logger { do logExitState; }}
		}
		
	}
    
    state bidding {
		enter {
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
			bidClear <- 0;
			target <- (road closest_to(self)).location;
		}
		transition to: awaiting_bike_assignation when: host.bidForBike(self,nil) {
		}
		transition to: finished when: !host.bidForBike(self,nil) {
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
		transition to: bidding when: bidClear = 1 {		
		}
		exit {
			if peopleEventLog { ask logger {do logExitState;}}
		}
		
	}
	
	state requested_with_bid{
		enter{
			if peopleEventLog or peopleTripLog {ask logger { do logEnterState; }} 
		}
		transition to:firstmile {}
		exit {
			if peopleEventLog {ask logger { do logExitState; }}
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
		do die;
	}
}

species autonomousBike control: fsm skills: [moving] {
	
	 //----------------ATTRIBUTES-----------------
	 

	//loggers
	autonomousBikeLogger_roadsTraveled travelLogger;
	autonomousBikeLogger_chargeEvents chargeLogger;
	autonomousBikeLogger_event eventLogger;
	    
	//Person/package info
	people rider;
	package delivery;
	int activity; //0=Package 1=Person

	
	//variables for bidding
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
	
	/* ========================================== PUBLIC FUNCTIONS ========================================= */
	 
	
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

	
	bool canMove {
		return ((target != nil and target != location)) and batteryLife > 0;
	}
	
	

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
				
			//If the highest bidder was a package
			}else if highestBidderPackage !=nil and highestBidderUser = nil {
				do pickUp(nil,highestBidderPackage);
				ask highestBidderPackage {do deliver(myself);}
			}else{
				write 'Error: Confusion with highest bidder';
			}
	}
				
	/* ========================================== STATE MACHINE ========================================= */
	
	state wandering initial: true{
		enter {
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			target <- nil;
		}
		transition to: bidding when: biddingStart= true and biddingEnabled{} // When it receives bid
		transition to: picking_up_people when: rider != nil and activity = 1 and !biddingEnabled{} //If no bidding
		transition to: picking_up_packages when: delivery != nil and activity = 0 and !biddingEnabled{} //If no bidding
		transition to: low_battery when: setLowBattery() {}
		transition to: rebalancing when: rebalanceNeeded() and rebalEnabled{}
		exit {
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
				
		}
	}
	
	state rebalancing{
		enter{
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(myself.distanceTraveledBike);}
			}	
		
		
			//choose target from hotspots
			
			if packagesEnabled and !peopleEnabled { //If food only
				closest_f_hotspot <- foodhotspot closest_to(self);
				target <- closest_f_hotspot.location;
				
			}else if !packagesEnabled and peopleEnabled {//If people only
			
				closest_u_hotspot <- userhotspot closest_to(self);
				target <- closest_u_hotspot.location;
				
			}else if packagesEnabled and peopleEnabled {//If both
			
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
			
			if autonomousBikeEventLog {ask eventLogger { do logExitState; }}
		}
		
	
	}
	state bidding {
		enter{
			if autonomousBikeEventLog {
				ask eventLogger { do logEnterState; }
				ask travelLogger { do logRoads(0.0);}
			}
			
		} 
		//Wait for bidding time to end
		transition to: endBid when: (highestBid != -100000.00) and (current_date.hour = bid_start_h and (current_date.minute + (current_date.second/60)) > (bid_start_min + maxBiddingTime)) or (current_date.hour > bid_start_h and (60-bid_start_min+current_date.minute + (current_date.second/60))>maxBiddingTime){}
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


