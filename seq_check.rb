require 'sinatra'
require 'erubis'
require 'seq_utils'

class SeqCheck < Sinatra::Base
  helpers ::SeqUtils
  
  get '/' do
    erb :index
  end
  
  get '/alignment' do
    require 'bio'
    prog = Bio::Fasta.local('bin/fasta36', nil, '-n -W 0')
    prog.db = '_trials/Trial_2/RP1037/fasta.lib.txt'
    
    @query = Bio::FlatFile.open(Bio::FastaFormat, '_trials/Trial_2/Bach1_no_BTB.fasta').next_entry
    @protein = @query.naseq.translate
    
    results = @query.fasta(prog)
    
    # Fix for new (i.e. Fasta36) format
    results.list.split(/\n>>/)[2..-1].each do |h|
      hit = Bio::Fasta::Report::Hit.new(h)
      
      results.hits << hit
    end
    
    @hits = []
    @report = prog.output
        
    results.each do |hit|
      # If E-value is smaller than 0.0001
      if hit.evalue < 0.0001
        query_seq = Bio::Sequence::NA.new hit.query_seq
        target_seq, consensus = hit.target_seq.split('; al_cons:')
      
        target_seq = Bio::Sequence::NA.new target_seq
      
        if hit.direction == 'r'
          query_seq.reverse_complement!
          target_seq.reverse_complement!
          consensus.reverse!
        end
      
        consensus.gsub!(' ', '*')
        consensus.gsub!(':', ' ')
        
        positions = [hit.query_start, hit.query_end]
      
        @hits << {
          :hit       => hit,
          :target    => pad_sequence(highlight_query_insertions(query_seq, target_seq), positions, @query.nalen),
        }
      end
    end
    
    erb :alignment
  end
end