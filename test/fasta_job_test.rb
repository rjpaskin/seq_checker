require 'test/unit'
require File.expand_path('../../lib/fasta_job', __FILE__)

class FastaJobTest < Test::Unit::TestCase
  def setup
    @fixtures = File.expand_path('../fixtures', __FILE__)
  end

  def test_initializes_correctly
    job = nil
    assert_nothing_raised do
      job = FastaJob.new "#{@fixtures}/db.fasta", "#{@fixtures}/query.fasta"
    end
    
    assert_equal job.query.class, Bio::FastaFormat, 'Query is FastaFormat'
    assert_equal job.query.to_s.chomp, File.read("#{@fixtures}/query.fasta"), 'Query sequence is correct'
    
    fasta = FastaJob.class_variable_get(:'@@fasta')
    
    assert_equal fasta.class, Bio::Fasta, 'Fasta factory is present'
    assert_equal fasta.db, "#{@fixtures}/db.fasta", 'Factory DB file is correct'
  end
  
  def test_runs_correctly
    job = FastaJob.new "#{@fixtures}/db.fasta", "#{@fixtures}/query.fasta"
    
    assert_nothing_raised do
      job.run!
    end
    
    assert_not_nil job.results, 'has results'
    assert job.results.hits.length > 0, 'has >0 results'
    assert_not_nil job.report, 'has report'
  end
end