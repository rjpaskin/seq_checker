require File.expand_path('../../test_setup.rb', __FILE__)

class FastaJobTest < Test::Unit::TestCase
  def setup
    @fixtures = File.expand_path('../../fixtures', __FILE__)
    
    @db_file    = "#{@fixtures}/db.fasta"
    @query_file = "#{@fixtures}/query.fasta"
  end
  
  def jobs
    {
      :file        => [@db_file, @query_file],
      :string      => [@db_file, File.read(@query_file)],
      :fastaformat => [@db_file, Bio::FlatFile.open(Bio::FastaFormat, @query_file).next_entry]
    }
  end

  def test_initializes_correctly
    job = nil
    assert_nothing_raised do
      job = FastaJob.new @db_file, @query_file
    end
    
    assert_equal job.query.class, Bio::FastaFormat, 'Query is FastaFormat'
    assert_equal job.query.to_s.chomp, File.read(@query_file), 'Query sequence is correct'
    
    fasta = FastaJob.class_variable_get(:'@@fasta')
    
    assert_equal fasta.class, Bio::Fasta, 'Fasta factory is present'
    assert_equal fasta.db, @db_file, 'Factory DB file is correct'
  end
  
  def test_handles_query_file_or_string_or_fastaformat
    jobs.each do |type, job_files|
      assert_nothing_raised("#{type} initializes ok") do
        FastaJob.new job_files[0], job_files[1]
      end
    end
  end
  
  def test_runs_with_query_file_or_string_or_fasta_format
    jobs.each do |type, job_files|
      job = FastaJob.new job_files[0], job_files[1]
          
      assert_nothing_raised("#{type} runs ok") do
        job.run!
      end
    
      assert job.results.hits.length > 0, "#{type} has >0 results"
    end
  end
  
  def test_runs_correctly
    job = FastaJob.new @db_file, @query_file
    
    assert_nothing_raised do
      job.run!
    end
    
    assert_not_nil job.results, 'has results'
    assert job.results.hits.length > 0, 'has >0 results'
    assert_not_nil job.report, 'has report'
  end
end