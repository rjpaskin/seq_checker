require 'bio'
require 'fasta_job'

class Alignment
  attr_reader   :query_sequence, :id

  # query_sequence Sequence to run alignments against, either
  #                plain text or Fasta format
  # trace_files    Array of filenames used to construct FASTA
  #                database
  def initialize(query_sequence, trace_files)
    @query_sequence = Bio::FastaFormat.new(query_sequence)
    @id = random_token
    @trace_files = []
    
    trace_files.each do |trace|
      begin
        @trace_files << Bio::Abif.open(trace).next_entry if File.exists? trace
      rescue
        raise 'Invalid trace file'
      end
    end
  end
  
  def valid?
    !@query_sequence.nil? && @query_sequence.length > 0 && !@trace_files.empty?
  end
  
  def run_alignment
    if valid?
      generate_folder
      job = FastaJob.new(generate_db_file, @query_sequence).run!
      write_results_file(job.report)
      write_query_file(@query_sequence.to_s)
      return job
    end
  end
  
  def self.fetch(id)
    root    = File.join(@@root_path, id)
    raise 'Non-existing alignment' unless File.exists? root
    results = File.read("#{root}/results.report")
    
    FastaJob.new("#{root}/lib.fasta", "#{root}/query.fasta").parse_results(results) 
  end
  
  def self.root_path=(path)
    @@root_path = path
  end
  
  private
  
    def generate_db_file
      filename = File.join(folder, 'lib.fasta')
    
      File.open(filename, 'w') do |file|
        @trace_files.each do |trace|
          file.puts trace.to_biosequence.output_fasta(trace.sample_title.join)
        end
      end
    
      filename
    end
    
    def write_results_file(text)
      filename = File.join(folder, 'results.report')
      
      File.open(filename, 'w') do |file|
        file.puts text
      end
    end
    
    def write_query_file(text)
      filename = File.join(folder, 'query.fasta')
      
      File.open(filename, 'w') do |file|
        file.puts text
      end    
    end
  
    def generate_folder
      Dir.mkdir folder unless File.exists? folder
    end
  
    def folder
      File.join(@@root_path, @id)
    end
    
    def random_token
      rand(36**8).to_s(36)
    end
end