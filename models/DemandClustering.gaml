/**
* Name: DemandClustering
* Based on the internal empty template. 
* Author: naroacorettisanchez
* Tags: 
*/


model DemandClustering

/* Insert your model definition here */
 
//import "./Parameters.gaml"




global {
	//---------------------------------------------------------Performance Measures-----------------------------------------------------------------------------
	//------------------------------------------------------------------Necessary Variables--------------------------------------------------------------------------------------------------

	 //--------------------------Demand Parameters-----------------------------
	    string cityDemandFolder <- "./../includes/Demand";
	
	    //csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_demand_cambridge_oct7_2019_week.csv",true); 
	    csv_file demand_csv <- csv_file (cityDemandFolder+ "/user_week_weekendfirst.csv",true);
	    //csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week.csv",true);
	    csv_file pdemand_csv <- csv_file (cityDemandFolder+ "/food_demand_cambridge_week_weekendfirst.csv",true);
	    string cityScopeCity <- "Cambridge";
		string cityGISFolder <- "./../includes/City/"+cityScopeCity;
		file bound_shapefile <- file(cityGISFolder + "/Bounds.shp");
		//file buildings_shapefile <- file(cityGISFolder + "/Buildings.shp")	parameter: "Building Shapefile:" category: "GIS";
		file roads_shapefile <- file(cityGISFolder + "/CambridgeRoads.shp");	
		
		
		// GIS FILES
		geometry shape <- envelope(bound_shapefile);
		graph roadNetwork;
	

    // ---------------------------------------Agent Creation----------------------------------------------
	init{
		// ---------------------------------------The Road Network----------------------------------------------
		create road from: roads_shapefile;
		
		roadNetwork <- as_edge_graph(road) ;
		
		
		    	    
		// -------------------------------------------The Packages -----------------------------------------
		create package_points from: pdemand_csv with:
		[
				start_lat::float(get("start_latitude")),
				start_lon::float(get("start_longitude"))
		]{
			
			start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location;
			
			
			location <- roadNetwork.vertices closest_to(start_point);
			
			id <- roadNetwork.vertices index_of location;
			
			cell my_cell <- cell closest_to(self) ;
			my_cell.used <- true;
			my_cell.color <- #green;
			//write(my_cell);
			
			//write(id);
	
		}
		
		// -------------------------------------------The People -----------------------------------------
	    create people_points from: demand_csv with:
		[
				start_lat::float(get("start_lat")),
				start_lon::float(get("start_lon"))
		]{

  
	        start_point  <- to_GAMA_CRS({start_lon,start_lat},"EPSG:4326").location; 
			//location <- start_point;
			
			location <- roadNetwork.vertices closest_to(start_point);
			
			id <- roadNetwork.vertices index_of location;
			//write(id);
			
			cell my_cell <- cell closest_to(self) ;
			my_cell.used <- true;
			my_cell.color <- #green;
			//write(my_cell);
	
		}
		
		
		
		list<cell> usedCells <- (cell where (each.used= true));
		
		write('Num of used cells: ' + length(usedCells));
		
		loop c over: usedCells{
			
			
			c.centerRoadpoint <-  roadNetwork.vertices closest_to(c.location);
			
			create CellcenterPoint{
				location <- c.centerRoadpoint;
			}
			
		}
		
		//list<autonomousBike> available <- (autonomousBike where each.availableForRideAB());
			
			// -------------------------------------------Demand clusters---------------------------------------
			
		//from charging locations to closest intersection
	   /* list<int> tmpDist;
	    list<int> chargingStationLocation;

		loop vertex over: roadNetwork.vertices {
			create tagRFID {
				id <- roadNetwork.vertices index_of vertex;
				location <- point(vertex);
			}
		}

		//K-Means		
		//Create a list of x,y coordinate for each intersection
		list<list> instances <- tagRFID collect ([each.location.x, each.location.y]);
		
		write(instances);

		//from the vertices list, create k groups  with the Kmeans algorithm (https://en.wikipedia.org/wiki/K-means_clustering)
		list<list<int>> kmeansClusters <- list<list<int>>(kmeans(instances, 5));


		//write(kmeansClusters);
		
		//from clustered vertices to centroids locations
		int groupIndex <- 0;
		list<point> coordinatesCentroids <- [];
		loop cluster over: kmeansClusters {
			
			//write(cluster);
			groupIndex <- groupIndex + 1;
			list<point> coordinatesVertices <- [];
			loop i over: cluster {
				add point (roadNetwork.vertices[i]) to: coordinatesVertices; 
			}
			add mean(coordinatesVertices) to: coordinatesCentroids;
		}    
	    
		loop centroid from:0 to:length(coordinatesCentroids)-1 {
			tmpDist <- [];
			loop vertices from:0 to:length(roadNetwork.vertices)-1{
				add (point(roadNetwork.vertices[vertices]) distance_to coordinatesCentroids[centroid]) to: tmpDist;
			}	
			loop vertices from:0 to: length(tmpDist)-1{
				if(min(tmpDist)=tmpDist[vertices]){
					add vertices to: chargingStationLocation;
					break;
				}
			}	
		}
	    
		
	    loop i from: 0 to: length(chargingStationLocation) - 1 {
			create chargingStation{
				location <- point(roadNetwork.vertices[chargingStationLocation[i]]);
				//write location;
			}
		}*/
		
		
		//K-Means		
		//Create a list of x,y coordinate for each intersection
		//list<list> instances <- people_points collect ([each.location.x, each.location.y]);
		
		//write(instances);

		//from the vertices list, create k groups  with the Kmeans algorithm (https://en.wikipedia.org/wiki/K-means_clustering)
		//list<list<int>> kmeansClusters <- list<list<int>>(kmeans(instances, 5));
		
		

		//write(kmeansClusters);

		//write(kmeansClusters);
		
		/*//Set number of clusters
		int numPeopleClusters <- 5;
		int numRestaurantClusters <- 5;		
		
		//Create a list of x,y coordinate for each demand
		list<list> instances_people <- people_points collect ([each.location.x, each.location.y]);
		list<list> instances_pack <- package_points collect ([each.location.x, each.location.y]);
		
		//write(instances_pack);

		//from the list of all demand, create k groups  with the Kmeans algorithm (https://en.wikipedia.org/wiki/K-means_clustering)
		list<list<int>> kmeansClusters_people <- list<list<int>>(kmeans(instances_people, numPeopleClusters));
		list<list<int>> kmeansClusters_pack <- list<list<int>>(kmeans(instances_pack, numRestaurantClusters));

		//from clustered vertices to centroids locations
		//write(kmeansClusters_pack);
			
		
		// Part 1 - People
		int groupIndex_people <- 0;
		list<point> coordinatesCentroids_people <- [];
		loop cluster over: kmeansClusters_people{
			
			write(cluster);
			
			groupIndex_people <- groupIndex_people + 1;
			list<point> coordinatesVertices_people <- [];
			loop i over: cluster {
				
				//write (point (roadNetwork.vertices[i]));
				
				add point (roadNetwork.vertices[i]) to: coordinatesVertices_people; 
			}
			add mean(coordinatesVertices_people) to: coordinatesCentroids_people;
		}    
		
		// Part 1 - Packages
		int groupIndex_pack <- 0;
		list<point> coordinatesCentroids_pack <- [];
		loop cluster over: kmeansClusters_pack{
			groupIndex_pack <- groupIndex_pack + 1;
			list<point> coordinatesVertices_pack <- [];
			loop i over: cluster {
				add point (roadNetwork.vertices[i]) to: coordinatesVertices_pack; 
			}
			add mean(coordinatesVertices_pack) to: coordinatesCentroids_pack;
		}   
		
		
		//Transfer to clostest road point
		
		list<int> tmpDist_people;
		list<int> tmpDist_pack;
		list<int> clusterPointLocation_people;
		list<int> clusterPointLocation_pack;
		
		//Part 1 - People
	    
		loop centroid from:0 to:length(coordinatesCentroids_people)-1 {
			tmpDist_people <- [];
			loop vertices from:0 to:length(roadNetwork.vertices)-1{
				add (point(roadNetwork.vertices[vertices]) distance_to coordinatesCentroids_people[centroid]) to: tmpDist_people;
			}	
			loop vertices from:0 to: length(tmpDist_people)-1{
				if(min(tmpDist_people)=tmpDist_people[vertices]){
					add vertices to: clusterPointLocation_people;
					break;
				}
			}	
		}
		
		
		//Part 2 - Packages
	    
		loop centroid from:0 to:length(coordinatesCentroids_pack)-1 {
			tmpDist_pack <- [];
			loop vertices from:0 to:length(roadNetwork.vertices)-1{
				add (point(roadNetwork.vertices[vertices]) distance_to coordinatesCentroids_pack[centroid]) to: tmpDist_pack;
			}	
			loop vertices from:0 to: length(tmpDist_pack)-1{
				if(min(tmpDist_pack)=tmpDist_pack[vertices]){
					add vertices to: clusterPointLocation_pack;
					break;
				}
			}	
		}
	    
	    
	    //Create agents out of the clusterPoints
	    
	    //Part 1 - People
		
	    loop i from: 0 to: length(clusterPointLocation_people) - 1 {
			create clusterPoint_people{
				location <- point(roadNetwork.vertices[clusterPointLocation_people[i]]);
			}
		}
		
		//Part 2 - Packages
		
	    loop i from: 0 to: length(clusterPointLocation_pack) - 1 {
			create clusterPoint_pack{
				location <- point(roadNetwork.vertices[clusterPointLocation_pack[i]]);
			}
		}*/
		
		
		
						
			write "FINISH INITIALIZATION";
		
		}
		
		
}

species tagRFID{
	
	int id;
	
	
}

species CellcenterPoint{
	aspect base {
    	color <- #red;
    	draw circle(40) color: color;
    }
	
}

grid cell width: 6 height: 6 neighbors: 6 {
	//float max_food <- 1.0;
	//float food_prod <- rnd(0.01);
	//float food <- rnd(1.0) max: max_food update: food + food_prod;
	//rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food))) update: rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)));
	bool used <-false;
	int numBikesCell <- 0;
	point centerRoadpoint;
	//rgb color <- rgb(int(255 * (1 - numBikesCell)), 255, int(255 * (1 - numBikesCell))) update: rgb(int(255 * (1 - numBikesCell)), 255, int(255 * (1 - numBikesCell)));
	//list<cell> neighbors2 <- (self neighbors_at 2);

	rgb color <- #white;
}

species package_points{
	int id;
	float start_lon;
	float start_lat;
	point start_point;
	aspect base {
    	color <- #yellow;
    	draw circle(20) color: color;
    }
}
species clusterPoint_pack{
	aspect base {
    	color <- #orange;
    	draw square(30) color: color;
    }
}


species people_points{
	int id;
	float start_lon;
	float start_lat;
	point start_point;
	aspect base {
    	color <- #blue;
    	draw circle(15) color: color;
    }
}

species clusterPoint_people{
	aspect base {
    	color <- #lightblue;
    	draw square(30) color: color;
    }
}

species road{
	
	aspect base {
		draw shape color: rgb(125, 125, 125);
	}
}

species chargingStation {

	
	aspect base {
		draw circle(30) color:rgb(230,95,53);		
	}
	
}


experiment clustering type: gui {
	
	//parameter var: step init: 30#sec;
	
	
    output {
		display multifunctionalVehiclesVisual type:opengl background: #black axes: false{	 
			//species building aspect: type visible:show_building position:{0,0,-0.001};
			grid cell border: #black;
			species CellcenterPoint aspect: base;
			species road aspect: base;
			species people_points aspect: base;
			species package_points aspect: base;
			species clusterPoint_people aspect: base;
			species clusterPoint_pack aspect: base;
			
			//species chargingStation aspect:base ;
			
			//species people aspect: base visible:show_people;
			//species package aspect:base visible:show_package;

			//event "b" {show_building<-!show_building;}
			//event "r" {show_road<-!show_road;}
			//event "p" {show_people<-!show_people;}
			//event "f" {show_restaurant<-!show_restaurant;}
			//event "d" {show_package<-!show_package;}
		}
    }
}
