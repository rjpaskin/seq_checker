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
  
  def ruler(max_num)
    max = (max_num / 10).floor
    
    1.upto(max).each_with_object(output = '') do |num|
      output << "#{num.to_s.rjust(9)}<u>0</u>".gsub(' ', '&nbsp;')
    end
    
    output
  end
end