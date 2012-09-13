require 'bio'

class Alignment
  attr_reader   :query_sequence
  attr_accessor :db_file_path

  # query_sequence Sequence to run alignments against, either
  #                plain text or Fasta format
  # trace_files    Array of filenames used to construct FASTA
  #                database
  def initialize(query_sequence, trace_files)
    @query_sequence = Bio::FastaFormat.new(query_sequence)
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
    FastaJob.new(generate_db_file, @query_sequence).run! if valid?
  end
  
  def generate_db_file
    filename = File.join(@db_file_path, 'lib.fasta')
    
    File.open(filename, 'w') do |file|
      @trace_files.each do |trace|
        file.puts trace.to_biosequence.output_fasta(trace.sample_title.join)
      end
    end
    
    filename
  end
end