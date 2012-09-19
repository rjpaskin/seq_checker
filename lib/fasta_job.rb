require 'bio'

class FastaJob
  path_to_fasta = File.expand_path('../../bin/fasta36', __FILE__)
  @@fasta = Bio::Fasta.local(path_to_fasta, nil, '-n -W 0')
  
  attr_reader :query, :results, :report
  
  def initialize(db_file, query)
    if query.respond_to? :fasta
      @query = query
    elsif File.exists? query
      @query = Bio::FlatFile.open(Bio::FastaFormat, query).next_entry
    else
      @query = Bio::FastaFormat.new(query)
    end
    
    @@fasta.db = db_file
  end
  
  def parse_results(results_text)
    @report = results_text
    
    @results = Bio::Fasta::Report.new(@report)
    
    # Fix for new (i.e. Fasta36) format
    @results.list.split(/\n>>/)[2..-1].each do |hit|
      results.hits << Bio::Fasta::Report::Hit.new(hit)
    end
  end
    
  def run!
    @query.fasta(@@fasta)
    
    parse_results @@fasta.output
    
    return self
  end
end