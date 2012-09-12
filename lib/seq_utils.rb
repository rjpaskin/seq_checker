module SeqUtils
  def pad_sequence(seq, positions, total_length)
    char = '-'#'&nbsp;'
    "#{char * (positions.min - 1)}#{seq}#{char * (total_length - positions.max)}"
  end
  
  def highlight_query_insertions(query, target)
    query = query.split(//)
    target = target.split(//)
    
    query.each_with_index do |na, pos|
      target[pos] = '</span><span class="insertion"><i class="arrow"></i><span>' + target[pos] + '</span></span><span>' if na == '-'
    end
    return '<span>' + target.join + '</span>'
  end
end