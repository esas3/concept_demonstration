#!/usr/bin/env ruby

host = "10.0.0.10"

queries = [
  "http://#{host}:4567/tags",
]

# queries.each do |query|
#   puts "Query: #{query}"
#   (1..80).step(10) do |c|
#     puts "Concurrency level: #{c} (concurrent users)"
#     q = query.split("/").last.split(":").last
#     `ab -n 1000 -c #{c} \
#     -e concept_results/bench_#{c}_#{q}.csv \
#     -g concept_results/plot_#{c}_#{q}.tsv \
#     #{query}`
#   end
# end

puts "Generating Graphs"
steps = (1..80).step(10).to_a
queries.each do |query|
  puts "Query: #{query}"
  q = query.split("/").last.split(":").last
  File.open(File.join("concept_results", "#{q}.plotp"), "w") do |file|
    file.puts "set title '#{query}'"
    file.puts "set xlabel 'Request'"
    file.puts "set ylabel 'Response Time (in ms)'"
    file.puts "plot " + steps.collect { |c|
      "'plot_#{c}_#{q}.tsv' using 9 smooth sbezier with lines title 'Concurrency Level #{c}'" 
    }.join(", ")
  end
  
  `pushd concept_results; gnuplot #{q}.plotp; popd`
end