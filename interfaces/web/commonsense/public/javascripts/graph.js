/*  Graph JavaScript framework, version 0.0.1
 *  (c) 2006 Aslak Hellesoy <aslak.hellesoy@gmail.com>
 *  (c) 2006 Dave Hoover <dave.hoover@gmail.com>
 *
 *  Ported from Graph::Layouter::Spring in
 *    http://search.cpan.org/~pasky/Graph-Layderer-0.02/
 *  The algorithm is based on a spring-style layouter of a Java-based social
 *  network tracker PieSpy written by Paul Mutton E<lt>paul@jibble.orgE<gt>.
 *
 *  Graph is freely distributable under the terms of an MIT-style license.
 *  For details, see the Graph web site: http://dev.buildpatternd.com/trac
 *
/*--------------------------------------------------------------------------*/

// Mouse position.
var mouse = { 
    x: 0, 
    y: 0, 
    down: false, 
    drag: { 
        x0: 0, 
        y0: 0, 
        dx: 0, 
        dy: 0,
        busy: false
    },
    inside: function(x, y, radius) {
        if (Math.abs(x-mouse.x) < radius && 
            Math.abs(y-mouse.y) < radius) return true;
        return false;
    }
};
// When the mouse is moved, update the stored mouse position.
// If the mouse is also pressed, update the drag position. 
document.onmousemove = function(e) {
    mouse.x = e.pageX || (e.clientX + (document.documentElement.scrollLeft || document.body.scrollLeft));
    mouse.y = e.pageY || (e.clientY + (document.documentElement.scrollTop || document.body.scrollTop));
    if (mouse.down) {
        mouse.drag.dx = mouse.x - mouse.drag.x0;
        mouse.drag.dy = mouse.y - mouse.drag.y0;
    }
}
document.onmousedown = function(e) {
    mouse.down = true;
    mouse.drag.x0 = mouse.x;
    mouse.drag.y0 = mouse.y;
}
document.onmouseup = function(e) {
    mouse.down = false;
    mouse.drag.x0 = 0;
    mouse.drag.y0 = 0;
    mouse.drag.dx = 0;
    mouse.drag.dy = 0;
}

/*--------------------------------------------------------------------------*/

function disable_text_selection(element) {
	element.onselectstart = function() { return false; };
	element.unselectable = "on";
	if(element.style)
	  element.style.MozUserSelect = "none";    
}

/*--------------------------------------------------------------------------*/

var Graph = Class.create();
Graph.prototype = {
    
    // Creates a new graph in the given element,
    // which must contain a <canvas> child element.
	initialize: function(container) {
		if (container == undefined) container = document.body;
		this.container = container;
		disable_text_selection(this.container);
		this.layout = new Graph.Layout.Spring(this);
		this.renderer = new Graph.Renderer.Basic(
		    this.container.getElementsByTagName('canvas')[0], this
		);
		this._animation = null;
		this._counter = 0;
		this.empty();
	},
	
	// Clears all nodes, edges and layout.
	empty: function() {
		this.root = null;
		this.nodeSet = {};
		this.nodes = [];
		this.edges = [];
		this.layout.initialize(this);
		this.renderer.draw();
		while (this.container.childNodes.length > 2) { 
		    // Don't remove the first node (the <canvas>)
			this.container.removeChild(this.container.lastChild);
		}
	},

    // One layout iteration.
	draw: function() {
		this.layout.layout();
		this.renderer.draw();
	},
    
    // Continuous layout iterations, up until Graph.layout.iterations.
	start: function(lazy) {
		if (this._animation) this.stop();
		function _update() {
			//console.log(this);
			return;
			if (this._counter >= this.layout.iterations) clearInterval(this._animation);
			this.layout.iterate();
			this.layout.calculateBounds();
			this._counter++;
			this.renderer.draw();
		}
		if (!lazy) this.layout.prepare();
		this._counter = 0;		
		this._animation = setInterval(this._update, 100, this);
	},
	
	// Like start, but without restarting from the beginning.
	refresh: function() {
	    this.start(true);
	},
	
	// Updates the canvas with the next iteration.
	_update: function(that) {
		if (that._counter >= that.layout.iterations) clearInterval(that._animation);
		that.layout.iterate();
		that.layout.iterate();
		that.layout.calculateBounds();
		that._counter++;
		that.renderer.draw();
	},
	
	// Stops the animation.
	stop: function() {
		if (this._animation) {
			clearInterval(this._animation);
			this._animation = null;
			this._counter = 0;
		}
	},
    
    // Add a new node from a string.
    // A <div> is created with given CSS classname and link href.
    // If value is not a string, it is expected to be a <div> element with an id.
	addNode: function(value, classname, href) {
	    if (this.nodeSet[value]) return this.nodeSet[value];
		if(typeof value == 'string') {
			// Create a new <div>.
			var key = value;
			var div = document.createElement('div');
			div.innerHTML = (typeof href == 'string') ? '<a href="'+href+'">'+value+'</a>' : value;
			div.className = 'node '+ classname;
			if (!this.root) div.className += ' root';
			this.container.appendChild(div);
		} else {
			// Assuming it's a DOM <div> node with an id.
			var key = value.id;
			var div = value;
		}
		// Disable text selecting,
		// which muddles up dragging behavior.
		disable_text_selection(div);
		// Register new node.
		var node = this.nodeSet[key];
		if(!node) {
			node = new Graph.Node(div);
			node.key = key;
			this.nodeSet[key] = node;
			this.nodes.push(node);
		}
		if (!this.root) this.root = node;
		node.edges = 0;
		return node;
	},

    // Add an edge between two node strings.
    // If the edge already exists, increase its weight.
	addEdge: function(source, target, weight) {
	    if (typeof weight == 'undefined') weight= 0.75;
		var s = this.nodeSet[source];
		var t = this.nodeSet[target];
		if (!s) s = this.addNode(source);
		if (!t) t = this.addNode(target);
		for(i=0; i<this.edges.length; i++) {
		    var edge = this.edges[i];
            if (edge.source == s && edge.target == t) {
                edge.weight += 0.05;
                return;
            }
		}
		s.edges += 1;
		t.edges += 1;
		var edge = { 'source': s, 'target': t, 'weight': weight };
		this.edges.push(edge);
	},
	
	// Removes the given node.
	// Associated edges must be removed manually.
	removeNode: function(key) {
	    var node = this.nodeSet[key];
        delete this.nodeSet[key];
        this.nodes.splice(this.nodes.indexOf(node), 1);
	},
	
	// Find the edge from source to target and delete it.
	removeEdge: function(node1, node2) {
        for(var i=0; i<this.edges.length; i++) {
            var edge = this.edges[i];
            if ((edge.source == node1 && edge.target == node2) ||
                (edge.source == node2 && edge.target == node1)) {
                this.edges.splice(i, 1);
                break;
            }
        }	    
	},

    // Make a map of all the nodes and the leaves attached to them.
    // For each cluster of nodes, remove leaves beyond max.
    // Keep leaves close together.	
	prune: function(max) {
        var crown = {};
        for(i=0; i<this.edges.length; i++) {
            var source = this.edges[i].source;
            var target = this.edges[i].target;
            if (!crown[source.key]) crown[source.key] = new Array();
            if (!crown[target.key]) crown[target.key] = new Array();
            if (source.edges == 1) crown[target.key].push(source);
            if (target.edges == 1) crown[source.key].push(target);
        }
        for(key in crown) {
            for(i=max; i<crown[key].length; i++) {
                var node1 = crown[key][i];
                var node2 = this.nodeSet[key];
                this.removeNode(node1.key);
                this.removeEdge(node1, node2);
            }
        }
        for(i=0; i<this.edges.length; i++) {
            if (this.edges[i].source.edges == 1 || 
                this.edges[i].target.edges == 1) {
                this.edges[i].weight *= 2;
            }
        }
    }
	
};

/*--------------------------------------------------------------------------*/

Graph.Node = Class.create();
Graph.Node.prototype = {
	initialize: function(value) {
		this.value = value;
	}
};

/*--------------------------------------------------------------------------*/

Graph.Renderer = {};
Graph.Renderer.Basic = Class.create();
Graph.Renderer.Basic.prototype = {
    
    // Graph rendering functionality.
    // * radius: the default radius of a node (enlarged by the number edges).
    // * scale.x and scale.y: graph scale.
	initialize: function(element, graph) {
		this.element = element;
		this.graph = graph;
		this.ctx = element.getContext("2d");
		this.radius = 4;
		this.scale = { 'x': 12, 'y': 10 }
		this.arrowAngle = Math.PI/10;		
	},

    // Absolute position translation.
	translate: function(point) {
		return [
			(point[0] - this.graph.min.x) * this.scale.x-10,
			(point[1] - this.graph.min.y) * this.scale.y-10
		];
	},

    // Rotation around the given point.
	rotate: function(point, length, angle) {
		if (isNaN(angle)) angle = 0;
		var dx = length * Math.cos(angle);
		var dy = length * Math.sin(angle);
		
		return [point[0]+dx, point[1]+dy];
	},

    // The absolute center of the canvas.
	absCenter: function() {
		try {
			var x = parseInt(this.element.width) - 
			    this.graph.max.x * this.scale.x + this.graph.min.x * this.scale.x;
			var y = parseInt(this.element.height) - 
			    this.graph.max.y * this.scale.y + this.graph.min.y * this.scale.y;
			x /= 2;
			y /= 2;
		} catch(e) {
			var x = parseInt(this.element.width) / 2;
			var y = parseInt(this.element.height) / 2;
		} 
        return [x, y];
	},
	
	// Draw the graph on a transparent background, with shadows enabled.
	draw: function() {
		this.ctx.clearRect(0, 0, this.element.width, this.element.height);
		this.ctx.shadowBlur = 8;
		this.ctx.shadowOffsetX = 6;
		this.ctx.shadowOffsetY = 6;
		var point = this.absCenter();
		var dx = point[0];
		var dy = point[1];
		for (var i = 0; i < this.graph.edges.length; i++) {
			this.drawEdge(this.graph.edges[i], dx, dy);
		}		
		for (var i = 0; i < this.graph.nodes.length; i++) {
		    var node = this.graph.nodes[i];
		    var point = this.translate([node.x, node.y]);
		    // Node radius is influenced by the number of edges.
    		var r = Math.min(this.radius + node.edges*2, this.radius*3);
		    this.dragNode(node, point[0]+dx, point[1]+dy, r)
			this.drawNode(node, point[0]+dx, point[1]+dy, r);
		}		
	},
	
	// Drags the node to the mouse position.
	dragNode: function(node, x, y, r) {
	    var dx = this.graph.container.style.left || $j(this.graph.container).offset().left;
	    var dy = this.graph.container.style.top || $j(this.graph.container).offset().top;
	    dx = dx? parseInt(dx) : 0;
	    dy = dy? parseInt(dy) : 0;
	    if (mouse.down) {
	        // Node get selected.
    		if (!mouse.drag.busy && mouse.inside(x+dx, y+dy, r)) {
    		    node.dragged = true;
    		    mouse.drag.busy = true;
    		}
		} else {
		    // Node is released (or simply wasn't selected).
		    node.dragged = false;
		    mouse.drag.busy = false;
		}
		if (node.dragged) {
		    //node.x = (mouse.x-dx-this.element.width*0.5) / this.scale.x;
		    //node.y = (mouse.y-dy-this.element.height*0.5) / this.scale.y;
		    node.x = (mouse.x-dx-this.element.width*0.5) / (1.0*this.scale.x);
		    node.y = (mouse.y-dy-this.element.height*0.5) / (1.0*this.scale.y);
		    this.ctx.strokeStyle = 'rgba(255,255,255,0.3)';
		    this.ctx.beginPath();
    		this.ctx.moveTo(x, y);
    		this.ctx.lineTo(mouse.x-dx, mouse.y-dy);
    		this.ctx.arc(mouse.x-dx, mouse.y-dy, 3, 0, Math.PI*2, true);
    		this.ctx.stroke();
		}	    
	},
    
    // Draw a single node at x, y.
	drawNode: function(node, x, y, r) {
		// Node oval styling.
		this.ctx.lineWidth = 0.5;
		this.ctx.strokeStyle = 'rgba(255,255,255,0.7)';
		this.ctx.fillStyle = 'rgba(0,0,0,0.2)';
		if (node == this.graph.root) this.ctx.lineWidth = 1.5;
		if (node.dragged) this.ctx.lineWidth += 0.5;
		if (node.value.className && node.value.className.indexOf("is-property-of") > 0) {
			this.ctx.fillStyle = 'rgba(30,144,255,0.35)';
		}
		// Node text position.
		node.value.style.display    = 'inline';
		node.value.style.position   = 'absolute';
		node.value.style.top        = y-10 +'px';
		node.value.style.left       = x+2  +'px';
		this.ctx.beginPath();
		this.ctx.arc(x, y, r, 0, Math.PI*2, true);
		this.ctx.closePath();
		this.ctx.fill();
		this.ctx.stroke();
	},
    
    // Draw a single edge to dx, dy.
	drawEdge: function(edge, dx, dy) {
		var source = this.translate([edge.source.x, edge.source.y]);
		var target = this.translate([edge.target.x, edge.target.y]);
		//var tan = (target[1] - source[1]) / (target[0] - source[0]);
		//var theta = Math.atan(tan);
		//if(source[0] <= target[0]) {theta = Math.PI+theta}
		//source = this.rotate(source, -this.radius, theta);
		//source = this.rotate(source, 0, theta);
		//target = this.rotate(target, this.radius, theta);
        //
		// Edge styling.
		this.ctx.strokeStyle = 'rgba(255,255,255,0.7)';
		this.ctx.fillStyle = 'rgba(255,255,255,0.7)';
		this.ctx.lineWidth = 0.3;
		this.ctx.beginPath();
		this.ctx.moveTo(source[0]+dx, source[1]+dy);
		this.ctx.lineTo(target[0]+dx, target[1]+dy);
		this.ctx.stroke();
        // Directed arrow.
		//this.drawArrowHead(this.radius, this.arrowAngle, theta, source[0]+dx, source[1]+dy, target[0]+dx, target[1]+dy);
	},

	drawArrowHead: function(length, alpha, theta, startx, starty, endx, endy) {
		var top = this.rotate([endx, endy], length, theta + alpha);
		var bottom = this.rotate([endx, endy], length, theta - alpha);
		this.ctx.beginPath();
		this.ctx.moveTo(endx, endy);
		this.ctx.lineTo(top[0], top[1]);
		this.ctx.lineTo(bottom[0], bottom[1]);
		this.ctx.fill();
	}
};

/*--------------------------------------------------------------------------*/

Graph.Layout = {};
Graph.Layout.Spring = Class.create();
Graph.Layout.Spring.prototype = {
    
    // Graph spring-based layout.
	initialize: function(graph) {
		this.graph = graph;
		this.iterations = 300;
		this.currentIteration = 0;
		this.maxRepulsiveForceDistance = 300;
		this.k = 2.5;
		this.c = 0.0125;
		this.maxVertexMovement = 0.5;
	},
   
	layout: function() {
		this.prepare();
		for (var i = 0; i < this.iterations; i++) {
			this.iterate();
		}
		this.calculateBounds();
	},
   
	prepare: function() {
		for (var i = 0; i < this.graph.nodes.length; i++) {
			var node = this.graph.nodes[i];
			node.x = 0;
			node.y = 0;
			node.vx = 0;
			node.vy = 0;
		}
	},
       
	calculateBounds: function() {
	    var min = { 'x':  Infinity, 'y':  Infinity }
	    var max = { 'x': -Infinity, 'y': -Infinity }
		for (var i = 0; i < this.graph.nodes.length; i++) {
			var x = this.graph.nodes[i].x;
			var y = this.graph.nodes[i].y;
			if(x > max.x) max.x = x;
			if(x < min.x) min.x = x;
			if(y > max.y) max.y = y;
			if(y < min.y) min.y = y;
		}
		this.graph.min = min;
		this.graph.max = max;
	},
       
	iterate: function() {
		// Forces on nodes due to node-node repulsions.
		for (var i = 0; i < this.graph.nodes.length; i++) {
			var node1 = this.graph.nodes[i];
			for (var j = i + 1; j < this.graph.nodes.length; j++) {
				var node2 = this.graph.nodes[j];
				this.repulse(node1, node2);
			}
		}
		// Forces on nodes due to edge attractions.
		for (var i = 0; i < this.graph.edges.length; i++) {
			var edge = this.graph.edges[i];
			this.attract(edge);             
		}
		// Move by the given force.
		for (var i = 0; i < this.graph.nodes.length; i++) {
			var node = this.graph.nodes[i];
			if (node == this.graph.root) continue;
			var dx = this.c * node.vx;
			var dy = this.c * node.vy;
			var max = this.maxVertexMovement;
			if(dx >  max) dx =  max;
			if(dx < -max) dx = -max;
			if(dy >  max) dy =  max;
			if(dy < -max) dy = -max;
			node.x += dx;
			node.y += dy;
			node.vx = 0;
			node.vy = 0;
		}
		this.currentIteration += 1;
	},

	repulse: function(node1, node2) {
		var dx = node2.x - node1.x;
		var dy = node2.y - node1.y;
		var d2 = dx * dx + dy * dy;
		if(d2 < 0.01) {
			dx = 0.1 * Math.random() + 0.1;
			dy = 0.1 * Math.random() + 0.1;
			var d2 = dx * dx + dy * dy;
		}
		var d = Math.sqrt(d2);
		if(d < this.maxRepulsiveForceDistance) {
			var k = this.k;
			// Temper the initial burst.
			if (this.currentIteration < 25) {
				k = k * 0.5 + k * this.currentIteration * 0.02;
			}
			var f = k * k / d;
			node2.vx += f * dx / d;
			node2.vy += f * dy / d;
			node1.vx -= f * dx / d;
			node1.vy -= f * dy / d;
		}
	},

	attract: function(edge) {
		var node1 = edge.source;
		var node2 = edge.target;
		var dx = node2.x - node1.x;
		var dy = node2.y - node1.y;
		var d2 = dx * dx + dy * dy;
		if(d2 < 0.01) {
			dx = 0.1 * Math.random() + 0.1;
			dy = 0.1 * Math.random() + 0.1;
			var d2 = dx * dx + dy * dy;
		}
		var d = Math.sqrt(d2);
		//if(d > this.maxRepulsiveForceDistance) {
		//	d = this.maxRepulsiveForceDistance;
		//	d2 = d * d;
		//}
		var f = (d2 - this.k * this.k) / this.k * edge.weight;
		node2.vx -= f * dx / d;
		node2.vy -= f * dy / d;
		node1.vx += f * dx / d;
		node1.vy += f * dy / d;
	}
};