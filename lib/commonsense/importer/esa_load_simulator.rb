module Commonsense
  module Importer
    class EsaLoadSimulator
      def self.import
      
        source_dir = File.join(File.dirname(__FILE__), "esa_corpus")
        $destination_dir = File.join(File.dirname(__FILE__), "esa_load_corpus")
        source_path = File.join(source_dir, "*.pdf")
        
        duplication_factor = 100
        
        Dir[source_path].each do |file|
          (1..duplication_factor).each do |i|
            write_mapping_file(i.to_s+File.basename(file), file)
          end
        end
        
      end
      
      def self.write_mapping_file(mapped_file_name, file_name, destination_dir = $destination_dir)
        File.open(File.join(destination_dir, "#{mapped_file_name}.txt"), "w") do |file|
          file.puts file_name
        end
      end
      
    end
  end
end