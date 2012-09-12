require 'sinatra'
require 'erubis'
require 'seq_utils'
require 'fasta_job'

class SeqCheck < Sinatra::Base
  helpers ::SeqUtils
  
  get '/' do
    erb :index
  end
  
  get '/alignment' do    
    trial_dir = File.expand_path('../_trials/Trial_2', __FILE__)
    
    job = FastaJob.new "#{trial_dir}/RP1037/fasta.lib.txt", "#{trial_dir}/Bach1_no_BTB.fasta"
    
    job.run!
    
    @hits = []
    @report = job.report
    @query = job.query
    @protein = @query.naseq.translate
        
    job.results.each do |hit|
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
          :hit    => hit,
          :target => pad_sequence(highlight_query_insertions(query_seq, target_seq), positions, @query.nalen),
        }
      end
    end
    
    erb :alignment
  end
end