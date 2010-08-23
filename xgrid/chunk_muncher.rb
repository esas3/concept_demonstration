#!/usr/bin/env ruby -rubygems

require 'active_support'

home_path = "/tmp/esa"
source_path = "#{home_path}/esa_load_corpus"
chunksize = 250
i = 1



Dir[source_path+"/*"].in_groups_of(chunksize, false) do |chunk|

  
  if i > 4 then
    break
  end
  
  cmd = "xgrid -h localhost -job submit /usr/bin/java -cp \
  #{home_path}:#{home_path}/lib/\*:#{home_path}/gate/bin/gate.jar:#{home_path}/gate/lib/\* \
  -Djava.awt.headless=true \
  -Dgate.home=#{home_path}/gate \
  -Dgate.plugins.home=#{home_path}/gate/plugins \
  -Dgate.site.config=#{home_path}/gate/gate.xml BatchProcessApp -g \
  #{home_path}/tmpApp.gapp -s http://10.0.0.10:8080/openrdf-sesame -r ESA \
  -w #{home_path} \
  #{chunk.join(" ")}"
  system cmd
  i = i + 1
end

