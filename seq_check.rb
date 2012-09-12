require 'sinatra'
require 'rack/flash'
require 'sinatra/redirect_with_flash'
require 'erubis'
require 'seq_utils'
require 'fasta_job'

class SeqCheck < Sinatra::Base
  helpers ::SeqUtils
  enable :sessions
  use Rack::Flash
  helpers Sinatra::RedirectWithFlash
  set :session_secret, 'ce555ca277fdc395a583cdde668dd9eecbd02b29ca786a85570562b087fccf51c5ac6ed91784fb34676e7edf719429a370dae1f0213ac10e2ad6c95656ec6ed0'
  
  get '/' do
    erb :index
  end
  
  post '/' do
    redirect '/', :error => 'error'
  end
  
  get '/alignment' do    
    trial_dir = File.expand_path('../_trials/Trial_2', __FILE__)
    
    job = FastaJob.new "#{trial_dir}/RP1037/fasta.lib.txt", "#{trial_dir}/Bach1_no_BTB.fasta"
    
    job.run!
    
    @report = job.report
    @query = job.query
    @protein = @query.naseq.translate
        
    job.results.threshold(0.0001).each_with_object(@hits = []) do |hit, hits|
      query_seq = Bio::Sequence::NA.new(hit.query_seq)
      target_seq, consensus = hit.target_seq.split('; al_cons:')
      
      target_seq = Bio::Sequence::NA.new(target_seq)
      
      if hit.direction == 'r'
        query_seq.reverse_complement!
        target_seq.reverse_complement!
        consensus.reverse!
      end
      
      consensus.gsub!(' ', '*')
      consensus.gsub!(':', ' ')
      
      positions = [hit.query_start, hit.query_end]
      
      hits << {
        :hit    => hit,
        :target => pad_sequence(highlight_query_insertions(query_seq, target_seq), positions, @query.nalen),
      }
    end
    
    erb :alignment
  end
end