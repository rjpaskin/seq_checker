require 'bio'

class FastaJob
  path_to_fasta = File.expand_path('../../bin/fasta36', __FILE__)
  @@fasta = Bio::Fasta.local(path_to_fasta, nil, '-n -W 0')
  
  attr_reader :query, :results, :report
  
  def initialize(db_file, query_file)
    @query = Bio::FlatFile.open(Bio::FastaFormat, query_file).next_entry
    @@fasta.db = db_file
  end
  
  def run!
    @results = @query.fasta(@@fasta)
    
    # Fix for new (i.e. Fasta36) format
    @results.list.split(/\n>>/)[2..-1].each do |h|
      hit = Bio::Fasta::Report::Hit.new(h)
  
      results.hits << hit
    end
    
    @report = @@fasta.output
    
    return @results
  end
end