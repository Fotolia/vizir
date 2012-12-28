class MatchData
  def to_hash(full_match_key = "match")
    hash = { full_match_key => to_s  }
    unless captures.empty?
      if names.empty?
        hash.merge!(Hash[captures.map {|x| [captures.index(x).to_s, x]}])
      else
        hash.merge!(Hash[names.zip(captures)]) unless names.empty?
      end
    end
    hash
  end
end
