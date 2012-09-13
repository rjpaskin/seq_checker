require File.expand_path('../../test_setup.rb', __FILE__)
require 'alignment'
require 'tmpdir'

class AlignmentTest < Test::Unit::TestCase
  def setup
    @fixtures  = File.expand_path('../../fixtures', __FILE__)
    
    @query     = File.read("#{@fixtures}/Bach1_no_BTB.fasta")
    @ab1_files = ["#{@fixtures}/A01_RP1037_F.ab1", "#{@fixtures}/B01_RP1037_R.ab1"]
    
    @tmpdir  = Dir.tmpdir
    @tmpfile = "#{@tmpdir}/lib.fasta"
  end
  
  def teardown
    File.unlink @tmpfile if File.exists? @tmpfile
  end

  def test_initializes_correctly
    aln = nil
    assert_nothing_raised do
      aln = Alignment.new(@query, @ab1_files)
    end
    
    assert_raise RuntimeError do
      Alignment.new(@query, Dir.glob("#{@fixtures}/*.fasta"))
    end
  end
  
  def test_validates_correctly
    assert Alignment.new(@query, @ab1_files).valid?
    
    assert !Alignment.new('', @ab1_files).valid?
    assert !Alignment.new('', []).valid?
    assert !Alignment.new('', []).valid?
  end
  
  def test_runs_only_if_valid
    aln = Alignment.new(@query, @ab1_files)
    
    aln.db_file_path = @tmpdir
    assert_not_nil aln.run_alignment
  end
  
  def test_does_not_run_if_invalid
    aln = Alignment.new(@query, [])
    
    aln.db_file_path = @tmpdir
    assert_nil aln.run_alignment
  end
  
  def test_generates_correct_db_file
    aln = Alignment.new(@query, @ab1_files)
    
    aln.db_file_path = @tmpdir
    
    aln.run_alignment
    
    Bio::FlatFile.foreach(Bio::FastaFormat, @tmpfile) do |entry|
      assert entry.definition =~ /^RP1037/
      assert entry.length > 0
    end
  end
end