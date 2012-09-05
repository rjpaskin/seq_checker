require 'sinatra'
require 'erubis'

class SeqCheck < Sinatra::Base
  get '/' do
    require 'bio'
    prog = Bio::Fasta.local('bin/fasta36', nil, '-n -W 0')
    prog.db = '_trials/Trial_2/RP1037/fasta.lib.txt'
    
    query = prog.query File.read('_trials/Trial_2/Bach1_no_BTB.fasta')
    
    # Fix for new (i.e. Fasta36) format
    query.list.split(/\n>>/)[2..-1].each do |h|
      hit = Bio::Fasta::Report::Hit.new(h)
      
      query.hits << hit
    end
    
    @hits = []
    @report = prog.output
    
    query.each do |hit|
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
      
        @hits << {
          :hit       => hit,
          :query     => query_seq,
          :target    => target_seq,
          :consensus => consensus,
        }
      end
    end
    
    erb :index
  end
end