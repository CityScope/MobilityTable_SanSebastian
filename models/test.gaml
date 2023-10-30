/**
* Name: test
* Based on the internal empty template. 
* Author: naroacorettisanchez
* Tags: 
*/


model test

global{
	
	float step <- 2 #sec;
	graph roadNetwork;
	
	 //--------------------------Demand Parameters-----------------------------
	string cityScopeCity <- "Cambridge";
    string cityDemandFolder <- "./../includes/Demand";
    string cityGISFolder <- "./../includes/City/"+cityScopeCity;

    //csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_demand_cambridge_oct7_2019_week.csv",true); 
   // file roads_shapefile <- file(cityGISFolder + "/Roads.shp");
    file buildings_shapefile <- file(cityGISFolder + "/Buildings.shp");
    
    /*string cityScopeCity <- "SanSebastian";
	string cityGISFolder <- "./../../DataSS/";

    file buildings_shapefile <- file(cityGISFolder + "/buildings/buildings_ss.shp");*/
    //Simulation starting date
	date starting_date <- date("2019-10-07 00:00:00"); 
	

	init{
		create building from: buildings_shapefile;
	    //create road from: roads_shapefile;
	
		/*roadNetwork <- as_edge_graph(road) ;
		
		
			create people number: 3 from: demand_csv with:
			[start_hour::date(get("starttime")), //'yyyy-MM-dd hh:mm:s'
				start_lat::float(get("start_lat")),
				start_lon::float(get("start_lon")),
				target_lat::float(get("target_lat")),
				target_lon::float(get("target_lon"))
			]{

	        //speed <- peopleSpeed;
	        start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location; // (lon, lat) var0 equals a geometry corresponding to the agent geometry transformed into the GAMA CRS
			target_point <- to_GAMA_CRS({target_lon,target_lat},"EPSG:4326").location;
			//location <- start_point;
			
			
			//write "Start "+start_point+ " " +start_h+ ":"+ start_min;
		}*/
	}
}

species people{
	
	date start_hour;
	
	point start_point;
	point target_point;
	
	float start_lat; 
	float start_lon;
	float target_lat;
	float target_lon;
	
	//I did something wrong here but ended up debugging in the main one
	
	/*reflex distancePrint when: (cycle = 1){
		
		point originIntersection <- roadNetwork.vertices closest_to(start_point);
		point destinationIntersection <- roadNetwork.vertices closest_to(target_point);
		
		float d1 <- start_point distance_to target_point using topology(road);
		write( self.name + 'Dist 1 '+ d1 );
		
		if (originIntersection = destinationIntersection) {
			return 0.0;
		}else{
			
			float d2 <- originIntersection distance_to destinationIntersection using topology(roadNetwork);
			write(self.name +'Dist 2 '+ d2 );
			return d2;
	
		}
	}*/
	
}

species road{
	
}
species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}




experiment test type: gui{
	
	output {
		display multifunctionalVehiclesVisual type:opengl background: #black axes: false{	 
			//species building aspect: type visible: show_building position:{0,0,-0.001};
		
			//grid cell border: #black;
			species building aspect: base;}
	}
	
}


/* Insert your model definition here */

