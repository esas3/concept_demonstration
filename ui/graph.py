urllib2 = ximport('urllib2')
graph = ximport('graph')
web = ximport('web')


data = urllib2.urlopen("http://localhost:4567/graphs/documents").read()

documents = web.json.read(data)["documents"]
relations = web.json.read(data)["relations"]

print relations

#Graph stuff

size(500, 500)

g = graph.create(iterations=1000, distance=1.2, layout="spring", depth=True)
g.events.popup = True


# Add nodes with a random id,
# connected to other random nodes.
for doc in documents:
    print doc["id"]
    node1 = g.add_node(doc["id"])
    #node1 = g.add_node("Bird")
    g.events.popup_text[doc["id"]]= doc["name"]
    
for rel in relations:
    g.add_edge(rel["source_id"],rel["destination_id"],1)




g.styles.apply()
#g.solve()

speed(30)
def draw():
    g.draw()
