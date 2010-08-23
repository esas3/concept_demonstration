$j(function() {
  function addToBin(docid) {
    $j.ajax({
      url: "/documents/" + docid + "/condensed",
      success: function(data) {
        $j("#bin").append(data);
      }
    });
  }
  
  $j(".add_to_bin").live("click", function() {
    var docid = $j(this).attr("data-docid");
    var docids = (JSON.parse($j.cookie("bin")) || []);
    if(docids.indexOf(docid) == -1) {
      docids = docids.concat(docid);
      addToBin(docid);
    }
    $j.cookie("bin", JSON.stringify(docids), {path: '/'});
    return false;
  });
  
  $j(".show_cloud").live("click", function () {
    var tags = $j(this).attr("tags");
    var tagcloud = new TagCloud(document.getElementById('cloud'),'random');
    tagcloud.addNode(new Node('Story',71));
    tagcloud.addNode(new Node('Commit',534));
    tagcloud.addNode(new Node('Chatmessage',1844))
    tagcloud.addNode(new Node('Mail',144));
    tagcloud.draw();
  });
  
  
  $j(".show_graph").live("click",function () {
    
    showForceDirected();
  
  });
  
  
  $j("a.remove").live("click", function() {
    var docid = $j(this).attr("data-docid");
    var docids = (JSON.parse($j.cookie("bin")) || []);
    docids = docids.filter(function(element) {
      return element != docid;
    });
    $j.cookie("bin", JSON.stringify(docids), {path: '/'});
    refreshBin();
  });
  
  function refreshBin() {
    $j("#bin").empty();
    var bin = JSON.parse($j.cookie("bin"));
    if(bin) {
      bin.forEach(function(docid) {
        addToBin(docid);
        //showGraph(docid);
      });
    }
  }
  
  refreshBin();
  
  function showGraph() {
    var url = "/tags.json";
    $j.ajax({
      url: url,
      dataType: 'json',
      success: function(data, status) {
        if(data) {
          if(!window.g) {
            window.g = new Graph($("graph"));
          }
          var g = window.g;
          data.each(function(concept) {
            //var tag = data.tags[i];
            // g.addNode(concept["name"], "", "/tags/" + concept["name"]);
            g.addEdge(concept["name"].split("#")[1], concept["superclass"].split("#")[1]);
          });
          
          // data.related_documents.each(function(doc) {
          //   var doc_id = doc.id + ":" + doc.name.substring(0,15);
          //   g.addEdge(node_id,doc_id);
          // });
          //     
          g.start();
        }
      }
      
    });
  } 
  
  window.showGraph = showGraph;
  showGraph();
  
  $j("#graph_head").click(function() {
    $j("#graph_container").toggleClass("hidden");
    $j.cookie("hide_graph_container", JSON.stringify($j("#graph_container").hasClass("hidden")), {path: '/'});
  });
  
  var hide_graph_container = JSON.parse($j.cookie("hide_graph_container"));
  if(hide_graph_container) {
    $j("#graph_container").addClass("hidden");
  } else {
    $j("#graph_container").removeClass("hidden");
  }
  
  
  function showForceDirected() {
		/* 1) Create a new SnowflakeLayout.
		 * 
		 * If you're going to place the graph in an HTML Element, other
		 * the <body>, remember that it must have a known size and
		 * position (via element.offsetWidth, element.offsetHeight,
		 * element.offsetTop, element.offsetLeft).
		 */
		var layout = new ForceDirectedLayout( document.body, true );
		layout.view.skewBase=575;
		layout.setSize();

		/* 2) Configure the layout.
		 * 
		 * This configuration defines how we handle the addition of
		 * different kinds of nodes to the graph. For each "type" of
		 * node, we tell the layout how to create a "model" and "view"
		 * of the new node.
		 */
		layout.config._default = {
			
		/* The "model" defines the underlying structure of our graph.
		 * For a SnowflakeModel, we need to define the following for
		 * each node:
		 * 
		 * - childRadius: the edge length to this node's children
		 * - fanAngle: the maximum angle in which child nodes will be
		 *   layed out
		 * - rootAngle: the base angle of the graph at the origin (this
		 *   is automatically determined for all child nodes)
		 * 
		 * These parameters determine how this new node will interact
		 * with other nodes in our graph. The "model" attribute of a
		 * class in our configuration must return a JavaScript Object
		 * containing these values.
		 */
		
			model: function( dataNode ) {
				return {
					mass: .5
				}
			},
			
		/* The "view" defines what the nodes in our graph look like.
		 * The "view" attribute of a class must return a DOM element -- 
		 * JSViz supports most HTML and SVG elements. You can control
		 * the appearence and behavior of view elements just like any
		 * DOM element: 
		 * 
		 * CSS: Point to a CSS style sheet using the "className"
		 * attribute of the DOM element.
		 * 
		 * Contents: Indicate the node's contents, in HTML, using the
		 * "appendChild" function or by setting DOM element's innerHTML.
		 * 
		 * Behavior: Add an event handler using the EventHandler factory
		 * class. For example: 
		 * 
		 * nodeElement.onclick = new EventHandler( _caller, _handler, arg0, arg1... );
		 * 
		 * where _caller is an object instance that _handler may refer
		 * to as "this" (use "window" if the function is in the global
		 * scope), _handler is the function to be executed, and any
		 * additional arguments are passed as parameters to _handler. 
		 */

			view: function( dataNode, modelNode ) {
				if ( layout.svg ) {
					var nodeElement = document.createElementNS("http://www.w3.org/2000/svg", "circle");
					nodeElement.setAttribute('stroke', '#888888');
					nodeElement.setAttribute('stroke-width', '.25px');
					nodeElement.setAttribute('fill', dataNode.color);
					nodeElement.setAttribute('r', 6 + 'px');
					nodeElement.onmousedown =  new EventHandler( layout, layout.handleMouseDownEvent, modelNode.id )
					return nodeElement;
				} else {
					var nodeElement = document.createElement( 'div' );
					nodeElement.style.position = "absolute";
					nodeElement.style.width = "12px";
					nodeElement.style.height = "12px";
					
					var color = dataNode.color.replace( "#", "" );
					nodeElement.style.backgroundImage = "url(http://kylescholz.com/cgi-bin/bubble.pl?title=&r=12&pt=8&b=888888&c=" + color + ")";
					nodeElement.innerHTML = '<img width="1" height="1">';
					nodeElement.onmousedown =  new EventHandler( layout, layout.handleMouseDownEvent, modelNode.id )
					return nodeElement;
				}
			}
		}

		/* Force Directed Graphs are a simulation of different kinds of
		 * forces between particles. In JSViz, a graph edge is typically
		 * represented as an attractive "spring" force connecting
		 * two nodes.
		 * 
		 * It's often the case that parent-child relationships are
		 * represented with stricter force rules. This can help a graph
		 * organize with fewer overlapping edges.
		 */
		
    		layout.forces.spring._default = function( nodeA, nodeB, isParentChild ) {
			if (isParentChild) {
				return {
					springConstant: 0.5,
					dampingConstant: 0.2,
					restLength: 20
				}
			} else {
				return {
					springConstant: 0.2,
					dampingConstant: 0.2,
					restLength: 20
				}
			}
		}
		
		/* Note that there is no need to include the above function in
		 * your application if you're satisfied with the default
		 * behavior.
		 * 
		 * You may wish to represent different edge weights in your
		 * graph with different edge lengths. A number of factors
		 * contribute to the actual edge length, but you can incluence
		 * the graph by applying different spring confiugrations between
		 * different kinds of edges.
		 * 
		 * For example, to apply a looser relationship beween node types
		 * 'A' and 'B', I can create a custom spring with greater
		 * elasticity:
		 */

		layout.forces.spring['A'] = {};
    		layout.forces.spring['A']['B'] = function( nodeA, nodeB, isParentChild ) {
			return {
				springConstant: 0.4,
				dampingConstant: 0.2,
				restLength: 20
			}
		}
		/* Note that these configurations are directed: The above
		 * configuration would apply to an edge from a node of type
		 * 'A' to a node of type 'B', but not from a 'B' to an 'A' ...
		 * use a additional configuration from that. 
		 */
		
		/* The other forces in our graph repel each node from another.
		 * This function should be the same for all node types.
		 */
    		layout.forces.magnet = function() {
			return {
				magnetConstant: -2000,
				minimumDistance: 10
			}
		}
		
		/* You don't need to include the above function in your
		 * application if you are satisfied with the default
		 * implementation.
		 */
		
		/* 3) Override the default edge properties builder.
		 * 
		 * @return DOMElement
		 */ 
		layout.viewEdgeBuilder = function( dataNodeSrc, dataNodeDest ) {
			if ( this.svg ) {
				return {
					'stroke': dataNodeSrc.color,
					'stroke-width': '2px',
					'stroke-dasharray': '2,4'
				}
			} else {
				return {
					'pixelColor': dataNodeSrc.color,
					'pixelWidth': '2px',
					'pixelHeight': '2px',
					'pixels': 5
				}
			}
		}

		/* 4) Make an loader to process the contents of our file.
		 * 
		 * Here, we're using the XML Loader. 
		 */
		  var url = "/tags.json";
       $j.ajax({
         url: url,
         dataType: 'json',
         success: function(data, status) {
           if(data) {
              layout.model.ENTROPY_THROTTLE=false;
         			var nodes = [];
         			var root = new DataGraphNode();
         			root.mass = 1;
         			root.color = "#ddd";
         			layout.newDataGraphNode(root);
         			data.each(function(tag) {
         			  var node = new DataGraphNode();
         			  node.color = "#8888bb";
         			  node.mass = 2; //tag.children.length;
         			  layout.newDataGraphNode(node);
         			  layout.newDataGraphEdge(root, node);
                // tag.children.each(function(document) {
                //   var docNode = new DataGraphNode();
                //   docNode.color = "#bb8888";
                //   docNode.mass = 1;
                //   layout.newDataGraphNode(docNode);
                //   layout.newDataGraphEdge(node, docNode);
                // });
         			});
              // for ( var i=0; i<8; i++ ) {
              //  var node = new DataGraphNode();
              //  node.color= (Math.random()>.5) ? "#8888bb" : "#bb8888";
              //  node.mass=.5;
              //  layout.newDataGraphNode( node );
              // 
              //  if ( nodes.length>0 ) {
              //    var neighbor = nodes[Math.floor((Math.random()*nodes.length))];
              //    layout.newDataGraphEdge( node, neighbor );              
              //  }
              // 
              //  if ( nodes.length>0 && Math.random() >.6 ) {
              //    var neighbor = nodes[Math.floor((Math.random()*nodes.length))];
              //    layout.newDataGraphEdge( node, neighbor );              
              //  }
              // 
              //  nodes.push( node );
         		/* 5) Control the addition of nodes and edges with a timer.
         		 * 
         		 * This enables the graph to start organizng as data is loaded.
         		 * Use a larger tick time for smoother animation, but slower
         		 * build time.
         		 */
         		var buildTimer = new Timer( 150 );
         		buildTimer.subscribe( layout );
         		buildTimer.start();
             
            
           }
         }

       });
		 
   
    
  }
  
  //showForceDirected();
  
  function showVis() {
    var url = "/tags.json";
    $j.ajax({
      url: url,
      dataType: 'json',
      success: function(data, status) {
        if(data) {
          $j("#graph").hide();
          $j("#vis").show();
          var canvas = new Canvas('mycanvas', {  
            //Where to inject the canvas. Any div container will do.  
            'injectInto':'vis',  
            //width and height for canvas. Default's to 200.  
            'width': 950,  
            'height':700,
            //Optional: Create a background canvas  
            //for painting concentric circles.  
            'backgroundCanvas': {  
              'styles': {  
                'strokeStyle': '#444'  
              },  
              'impl': {  
                'init': function(){},  
                'plot': function(canvas, ctx){  
                  var times = 6, d = 100;  
                  var pi2 = Math.PI * 2;  
                  for (var i = 1; i <= times; i++) {  
                    ctx.beginPath();  
                    ctx.arc(0, 0, i * d, 0, pi2, true);  
                    ctx.stroke();  
                    ctx.closePath();  
                  }  
                }  
              }  
            }
          }); 
          var rgraph= new RGraph(canvas,  {  
            //interpolation type, can be linear or polar  
            interpolation: 'linear',  
            //parent-children distance  
            levelDistance: 200,  
            //Set node/edge styles  
            Node: {  
              color: '#ccddee'  
            },  
            Edge: {  
              color: '#777'  
            },  
            //Add a controller to make the tree move on click.  
            onCreateLabel: function(domElement, node) {  
              domElement.onclick = function() {  
                rgraph.onClick(node.id);
                console.log("clicked " + node.name);
              };  
            },
            onPlaceLabel: function(domElement, node) {  
              domElement.innerHTML = node.name;  
              var left = parseInt(domElement.style.left);  
              domElement.style.width = '';  
              domElement.style.height = '';  
              var w = domElement.offsetWidth;  
              domElement.style.left = (left - w /2) + 'px';  
            }
          });  
          
          //load tree from tree data.  
          rgraph.loadJSON(data);  
          //compute positions and plot  
          rgraph.refresh();  
          // rgraph.onClick(rgraph.root);
        }
      }
      
    });    
    
  }
  
  window.showVis = showVis;
  
  
  $j("#condense_documents").live("click", function() {
    $j(".documents").toggleClass("condensed");
    return false;
  });
});